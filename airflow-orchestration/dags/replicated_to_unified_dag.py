import json
import logging
import re
import shutil
import subprocess

from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.python import PythonOperator


logger = logging.getLogger(__name__)

AWS_REGION = "ap-south-1"

ECS_CLUSTER = "bpay-etl-ecs-dev"
HOP_SERVICE = "bpay-etl-hop-service-dev"
HOP_CONTAINER = "bpay-etl-hop"

WORKFLOW_PATH = "/files/workflows/replicated_to_unified.hwf"
PROJECT_NAME = "card-rewards-etl"

EXECUTION_TIMEOUT_SECONDS = 7100


def run_command(command, timeout=60):
    """Execute a local command and return its output."""

    result = subprocess.run(
        command,
        capture_output=True,
        text=True,
        timeout=timeout,
        check=False,
    )

    output = (result.stdout or "") + (result.stderr or "")

    if result.returncode != 0:
        raise RuntimeError(
            f"Command failed with exit code {result.returncode}: "
            f"{output}"
        )

    return output


def execute_replicated_to_unified():

    # Verify required executables inside the Airflow container.
    for executable in ("aws", "session-manager-plugin"):
        if shutil.which(executable) is None:
            raise RuntimeError(
                f"Required executable not found in Airflow container: "
                f"{executable}"
            )

    logger.info("Discovering the running Hop ECS task")

    # Discover the current running Hop task.
    list_command = [
        "aws",
        "ecs",
        "list-tasks",
        "--cluster", ECS_CLUSTER,
        "--service-name", HOP_SERVICE,
        "--desired-status", "RUNNING",
        "--region", AWS_REGION,
        "--output", "json",
    ]

    task_response = json.loads(run_command(list_command))
    task_arns = task_response.get("taskArns", [])

    if len(task_arns) != 1:
        raise RuntimeError(
            f"Expected exactly one running Hop task, "
            f"but found {len(task_arns)}: {task_arns}"
        )

    hop_task_arn = task_arns[0]

    logger.info("Discovered Hop task: %s", hop_task_arn)

    # Verify the expected container is running.
    describe_command = [
        "aws",
        "ecs",
        "describe-tasks",
        "--cluster", ECS_CLUSTER,
        "--tasks", hop_task_arn,
        "--region", AWS_REGION,
        "--output", "json",
    ]

    describe_response = json.loads(run_command(describe_command))
    tasks = describe_response.get("tasks", [])

    if len(tasks) != 1:
        raise RuntimeError(
            f"Unable to describe Hop task: {hop_task_arn}"
        )

    containers = tasks[0].get("containers", [])

    hop_container = next(
        (
            container
            for container in containers
            if container.get("name") == HOP_CONTAINER
        ),
        None,
    )

    if not hop_container or hop_container.get("lastStatus") != "RUNNING":
        raise RuntimeError(
            f"Container {HOP_CONTAINER} is not running in task "
            f"{hop_task_arn}"
        )

    logger.info(
        "Starting Hop workflow: project=%s, workflow=%s",
        PROJECT_NAME,
        WORKFLOW_PATH,
    )

    # Execute Hop CLI inside the running ECS container.
    remote_command = (
        f"cd /files || exit 1; "
        f"/opt/hop/hop-run.sh "
        f"-j {PROJECT_NAME} "
        f"-f {WORKFLOW_PATH}; "
        f"rc=$?; "
        f"echo HOP_EXIT_CODE=$rc; "
        f"exit 0"
    )

    execute_command = [
        "aws",
        "ecs",
        "execute-command",
        "--cluster", ECS_CLUSTER,
        "--task", hop_task_arn,
        "--container", HOP_CONTAINER,
        "--region", AWS_REGION,
        "--interactive",
        "--command", f"/bin/sh -c '{remote_command}'",
    ]

    result = subprocess.run(
        execute_command,
        capture_output=True,
        text=True,
        timeout=EXECUTION_TIMEOUT_SECONDS,
        check=False,
    )

    output = (result.stdout or "") + (result.stderr or "")

    logger.info("Hop ECS Exec output:\n%s", output)

    if result.returncode != 0:
        raise RuntimeError(
            f"ECS Exec failed with exit code {result.returncode}: "
            f"{output}"
        )

    # Read the actual Hop CLI exit code from the remote container.
    matches = re.findall(
        r"HOP_EXIT_CODE=(\d+)",
        output,
    )

    if not matches:
        raise RuntimeError(
            "Hop execution exit-code marker was not found. "
            "Unable to confirm workflow completion."
        )

    hop_exit_code = int(matches[-1])

    if hop_exit_code != 0:
        raise RuntimeError(
            f"Replicated to Unified Hop workflow failed "
            f"with exit code {hop_exit_code}"
        )

    logger.info(
        "Replicated to Unified workflow completed successfully."
    )


with DAG(
    dag_id="replicated_to_unified_dag",
    description="Manually execute Replicated to Unified ETL through Apache Hop ECS Exec",
    start_date=datetime(2026, 1, 1),
    schedule=None,
    catchup=False,
    max_active_runs=1,
    default_args={
        "owner": "bpay-etl",
        "retries": 0,
    },
    tags=[
        "bpay-etl",
        "hop",
        "replicated",
        "unified",
    ],
) as dag:

    execute_replicated_to_unified_task = PythonOperator(
        task_id="execute_replicated_to_unified",
        python_callable=execute_replicated_to_unified,
        execution_timeout=timedelta(hours=2),
    )