#!/usr/bin/env python
import sys
import json
import requests
from requests.auth import HTTPBasicAuth


def main():
    try:
        # ================= Step1: Read input parameters from Terraform =================
        query = json.load(sys.stdin)
        print("", file=sys.stderr)
        # print(f"INFO: Received query: {query}", file=sys.stderr)
        print(f"INFO: Received query: keys={list(query.keys())}", file=sys.stderr)

        yaml_existing_indices = set(json.loads(query.get("yaml_existing_indices", "[]")))
        prefix = query.get("prefix", "")
        es_url = query.get("es_url", "")
        es_user = query.get("es_user", "")
        es_password = query.get("es_password", "")

        # ================= Step2: Query existing indices from Elasticsearch =================
        r = requests.get(
            f"{es_url}/_cat/indices/{prefix}*?h=index&format=json",
            auth=HTTPBasicAuth(es_user, es_password)
        )
        r.raise_for_status()
        es_existing_indices = set(i["index"] for i in r.json())
        print(f"INFO: Existing indices in Elasticsearch: {es_existing_indices}", file=sys.stderr)

        # ================= Step3: Compute indices that will be deleted =================
        yaml_deleted_indices = es_existing_indices - yaml_existing_indices
        print(f"INFO: Indices to be deleted: {yaml_deleted_indices}", file=sys.stderr)

        # ================= Step4: Check document count for each index to be deleted =================
        index_doc_counts = {}
        non_empty = []
        for idx in yaml_deleted_indices:
            resp = requests.get(f"{es_url}/{idx}/_count", auth=HTTPBasicAuth(es_user, es_password))
            if resp.status_code == 404:
                count = 0
            else:
                resp.raise_for_status()
                count = resp.json().get("count", 0)
            index_doc_counts[idx] = str(count)
            if count > 0:
                non_empty.append(idx)

        # ================= Step5: Output results and exit if non-empty =================
        if non_empty:
            non_empty_with_counts = [f"{idx}({index_doc_counts[idx]} docs)" for idx in non_empty]
            print(f"ERROR: Cannot delete non-empty indices: {', '.join(non_empty_with_counts)}", file=sys.stderr)
            sys.exit(1)  # <-- Terraform will see this as failure and stop

        # Success case
        print(f"INFO: All deleted indices are empty or no indices to delete", file=sys.stderr)
        output = {
            "ok": "true"
        }
        print(json.dumps(output))

    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)  # Terraform will stop on any exception


if __name__ == "__main__":
    main()


# (.venv) elias@dhcp-9-112-32-238 terraform % terraform plan -target "module.use_cases_python_non_empty_index_no_delete"
# module.use_cases_python_non_empty_index_no_delete.data.external.custom_validation: Reading...
#
# Planning failed. Terraform encountered an error while generating this plan.
#
# ╷
# │ Warning: Resource targeting is in effect
# │
# │ You are creating a plan with the -target option, which means that the result of this plan may not represent all of the changes requested by the current
# │ configuration.
# │
# │ The -target option is not for routine use, and is provided only for exceptional situations such as recovering from errors or mistakes, or when Terraform
# │ specifically suggests to use it as part of an error message.
# ╵
# ╷
# │ Error: External Program Execution Failed
# │
# │   with module.use_cases_python_non_empty_index_no_delete.data.external.custom_validation,
# │   on modules/use_cases/python_non_empty_index_no_delete/main.tf line 30, in data "external" "custom_validation":
# │   30:   program = ["python", "${path.module}/custom_validation.py"]
# │
# │ The data source received an unexpected error while attempting to execute the program.
# │
# │ Program: /Users/elias/EliasLi/03.code-github/terraform-elasticstack-provider/.venv/bin/python
# │ Error Message:
# │ INFO: Received query: keys=['es_password', 'es_url', 'es_user', 'prefix', 'yaml_existing_indices']
# │ INFO: Existing indices in Elasticsearch: {'python--nte--app1--d0--tf_index2_no_document', 'python--nte--app1--d0--tf_index4_with_document',
# │ 'python--nte--app1--d0--tf_index1_with_document', 'python--nte--app1--d0--tf_index3_with_document'}
# │ INFO: Indices to be deleted: {'python--nte--app1--d0--tf_index2_no_document', 'python--nte--app1--d0--tf_index4_with_document',
# │ 'python--nte--app1--d0--tf_index3_with_document'}
# │ ERROR: Cannot delete non-empty indices: python--nte--app1--d0--tf_index4_with_document(1 docs), python--nte--app1--d0--tf_index3_with_document(1 docs)
# │
# │ State: exit status 1
