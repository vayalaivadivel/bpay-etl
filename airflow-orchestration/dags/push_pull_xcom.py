from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime

# Task 1 - Push value to XCom
def push_data(ti):
    ti.xcom_push(key="message", value="Hello XCom from Ravula")

# Task 2 - Pull value from XCom
def pull_data(ti):
    value = ti.xcom_pull(
        task_ids="push_task",
        key="message"
    )

    print(f"Received value from xcom: {value}")

with DAG(
    dag_id="xcom_example_dag",
    start_date=datetime(2026, 1, 1),
    schedule=None,
    catchup=False,
) as dag:

    push_task = PythonOperator(
        task_id="push_task",
        python_callable=push_data
    )

    pull_task = PythonOperator(
        task_id="pull_task",
        python_callable=pull_data
    )

    push_task >> pull_task