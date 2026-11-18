import base64
import json
import os
from datetime import datetime
from urllib.request import Request, urlopen

from airflow import DAG
from airflow.hooks.base import BaseHook
from airflow.operators.python import PythonOperator


def check_hop_connection():
    connection = BaseHook.get_connection("hop_server")

    base_url = connection.host.rstrip("/")
    if not base_url.startswith(("http://", "https://")):
        base_url = f"http://{base_url}"

    if connection.port:
        from urllib.parse import urlsplit, urlunsplit

        parsed = urlsplit(base_url)
        base_url = urlunsplit(
            (parsed.scheme, f"{parsed.hostname}:{connection.port}",
             parsed.path, parsed.query, parsed.fragment)
        )

    username = connection.login
    password = connection.password

    credentials = base64.b64encode(
        f"{username}:{password}".encode()
    ).decode()

    url = f"{base_url}/hop/status/?json=Y"

    request = Request(
        url,
        headers={
            "Authorization": f"Basic {credentials}",
            "Accept": "application/json",
        },
        method="GET",
    )

    with urlopen(request, timeout=20) as response:
        status_code = response.status
        result = json.loads(response.read().decode("utf-8"))

    print(f"HTTP Status: {status_code}")
    print(f"Hop Response: {result}")

    if status_code != 200:
        raise RuntimeError(f"Hop returned HTTP {status_code}")

    if result.get("statusDescription") != "Online":
        raise RuntimeError(
            f"Hop is not Online: {result.get('statusDescription')}"
        )

    print("Hop connectivity test successful.")


with DAG(
    dag_id="hop_connectivity_test",
    start_date=datetime(2026, 1, 1),
    schedule=None,
    catchup=False,
    tags=["bpay-etl", "hop", "connectivity"],
) as dag:

    test_hop = PythonOperator(
        task_id="check_hop_connection",
        python_callable=check_hop_connection,
    )
