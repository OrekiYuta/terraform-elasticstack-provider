import sys
import json
import requests
from requests.auth import HTTPBasicAuth

def main():
    try:
        query = json.load(sys.stdin)
        print(f"DEBUG: Received query: {query}", file=sys.stderr)
        sys.stderr.flush()

        new_indices = set(json.loads(query.get("new_indices", "[]")))
        prefix = query.get("prefix", "")
        es_url = query.get("es_url")
        es_user = query.get("es_user")
        es_password = query.get("es_password")

        r = requests.get(f"{es_url}/_cat/indices/{prefix}*?h=index&format=json", auth=HTTPBasicAuth(es_user, es_password))
        r.raise_for_status()
        existing_indices = set([i["index"] for i in r.json()])
        print(f"DEBUG: Existing indices: {existing_indices}", file=sys.stderr)
        sys.stderr.flush()

        deleted_indices = existing_indices - new_indices
        print(f"DEBUG: Deleted indices: {deleted_indices}", file=sys.stderr)
        sys.stderr.flush()

        non_empty = []
        for idx in deleted_indices:
            resp = requests.get(f"{es_url}/{idx}/_count", auth=HTTPBasicAuth(es_user, es_password))
            if resp.status_code == 404:
                continue
            resp.raise_for_status()
            count = resp.json().get("count", 0)
            if count > 0:
                non_empty.append((idx, count))

        if non_empty:
            print(f"DEBUG: Non-empty indices: {non_empty}", file=sys.stderr)
            sys.stderr.flush()
            print(json.dumps({
                "error": "Cannot delete non-empty indices: " + ", ".join([f"{i}:{c}" for i,c in non_empty])
            }))
            sys.exit(1)

        print(json.dumps({"ok": "true"}))
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.stderr.flush()
        sys.exit(1)

if __name__ == "__main__":
    main()