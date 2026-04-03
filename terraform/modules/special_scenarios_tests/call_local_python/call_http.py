import json
import sys
import requests

def main():
    query = json.load(sys.stdin)

    api_url = query.get("api_url")
    payload = json.loads(query.get("payload", "{}"))

    resp = requests.post(
        api_url,
        json=payload,
        headers={"Content-Type": "application/json"},
        timeout=10
    )

    result = {
        "result": json.dumps(resp.json())
    }

    print(json.dumps(result))

if __name__ == "__main__":
    main()