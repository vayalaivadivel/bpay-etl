
import logging
import xml.etree.ElementTree as ET
from datetime import datetime, timedelta
from urllib.parse import urlencode, urlsplit, urlunsplit
from urllib.request import Request, urlopen
from urllib.error import HTTPError, URLError
import base64

from airflow import DAG
from airflow.hooks.base import BaseHook
from airflow.operators.python import PythonOperator

logger = logging.getLogger(__name__)

CONNECTION_ID = "hop_server"

WORKFLOW_PATH = (
    "/files/workflows/raw_to_replicated.hwf"
)

RUN_CONFIGURATION = "local"


def execute_hop_workflow():

    connection = BaseHook.get_connection(CONNECTION_ID)

    base_url = connection.host.rstrip("/")

    if not base_url.startswith(("http://", "https://")):
        base_url = f"http://{base_url}"

    parsed = urlsplit(base_url)

    if connection.port and not parsed.port:
        netloc = f"{parsed.hostname}:{connection.port}"
        base_url = urlunsplit(
            (
                parsed.scheme,
                netloc,
                parsed.path,
                parsed.query,
                parsed.fragment,
            )
        )

    endpoint = f"{base_url}/hop/execWorkflow/"

    params = {
        "workflow": WORKFLOW_PATH,
        "runConfig": RUN_CONFIGURATION,
        "level": "Basic",
        "xml": "Y",
    }

    url = f"{endpoint}?{urlencode(params)}"

    credentials = base64.b64encode(
        f"{connection.login}:{connection.password}".encode()
    ).decode()

    request = Request(
        url,
        headers={
            "Authorization": f"Basic {credentials}",
            "Accept": "application/xml",
        },
        method="GET",
    )

    logger.info("Executing Hop workflow: %s", WORKFLOW_PATH)

    try:
        with urlopen(request, timeout=3600) as response:
            response_body = response.read().decode("utf-8")
            status_code = response.status

    except HTTPError as exc:
        error_body = exc.read().decode("utf-8", errors="replace")
        logger.error("Hop HTTP error %s: %s", exc.code, error_body)
        raise

    except (URLError, TimeoutError) as exc:
        logger.exception("Unable to execute Hop workflow")
        raise RuntimeError(
            f"Hop workflow execution request failed: {exc}"
        ) from exc

    logger.info("Hop HTTP status: %s", status_code)
    logger.info("Hop execution response: %s", response_body)

    try:
        root = ET.fromstring(response_body)
        result = root.findtext("result")
        message = root.findtext("message", default="No message")
    except ET.ParseError as exc:
        raise RuntimeError(
            f"Unexpected Hop response format: {response_body}"
        ) from exc

    if status_code != 200 or result != "OK":
        raise RuntimeError(
            f"Hop workflow execution failed: {message}"
        )

    logger.info("Hop workflow completed successfully: %s", message)


with DAG(
    dag_id="hop_workflow_execution_test",
    description="Test execution of RAW to REPLICATED through Hop Server",
    start_date=datetime(2026, 1, 1),
    schedule=None,
    catchup=False,
    max_active_runs=1,
    default_args={
        "owner": "bpay-etl",
        "retries": 0,
    },
    tags=["bpay-etl", "hop", "execution-test"],
) as dag:

    execute_raw_to_replicated = PythonOperator(
        task_id="execute_raw_to_replicated",
        python_callable=execute_hop_workflow,
        execution_timeout=timedelta(hours=2),
    )