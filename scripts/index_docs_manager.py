import os
import json
import requests
from dotenv import load_dotenv

load_dotenv()

es_url = os.getenv("es_url")
es_api_key = os.getenv("es_api_key")


def insert_document(index_name: str):
    url = f"{es_url}/{index_name}/_doc"
    headers = {
        "Authorization": f"ApiKey {es_api_key}",
        "Content-Type": "application/json"
    }

    doc = {
        "name": "test-doc",
        "env": "dev",
        "timestamp": "2026-03-30T12:00:00Z"
    }

    response = requests.post(url, headers=headers, data=json.dumps(doc))
    print(f"[{index_name}] Insert Status Code:", response.status_code)
    print(f"[{index_name}] Insert Response:", response.text)


def delete_all_documents(index_name: str):
    url = f"{es_url}/{index_name}/_delete_by_query"
    headers = {
        "Authorization": f"ApiKey {es_api_key}",
        "Content-Type": "application/json"
    }

    payload = {"query": {"match_all": {}}}
    response = requests.post(url, headers=headers, data=json.dumps(payload))
    print(f"[{index_name}] Delete Status Code:", response.status_code)
    print(f"[{index_name}] Delete Response:", response.text)


if __name__ == "__main__":
    index_list = [
        "python--nte--app1--d0--tf_index1_with_document",
        "python--nte--app1--d0--tf_index3_with_document",
        "python--nte--app1--d0--tf_index4_with_document",

        "http--nte--app1--d0--tf_index1_with_document",
        "http--nte--app1--d0--tf_index3_with_document",
        "http--nte--app1--d0--tf_index4_with_document"
    ]

    for index_name in index_list:
        insert_document(index_name)
        # delete_all_documents(index_name)