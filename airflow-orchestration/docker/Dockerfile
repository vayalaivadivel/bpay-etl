FROM apache/airflow:2.10.0

##########################################################
# ROOT USER
##########################################################

USER root

##########################################################
# INSTALL PACKAGES
##########################################################

RUN apt-get update && \
    apt-get install -y \
    gcc \
    g++ \
    default-libmysqlclient-dev \
    curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

##########################################################
# AIRFLOW USER
##########################################################

USER airflow

##########################################################
# REQUIREMENTS
##########################################################

COPY requirements.txt /requirements.txt

RUN pip install --no-cache-dir -r /requirements.txt

##########################################################
# DAGS
##########################################################

COPY dags /opt/airflow/dags

##########################################################
# PLUGINS
##########################################################

COPY plugins /opt/airflow/plugins

##########################################################
# ENVIRONMENT
##########################################################

ENV AIRFLOW__WEBSERVER__WEB_SERVER_HOST=0.0.0.0

ENV AIRFLOW__WEBSERVER__WEB_SERVER_PORT=8080

ENV AIRFLOW__CORE__LOAD_EXAMPLES=False

##########################################################
# PORT
##########################################################

EXPOSE 8080

##########################################################
# START AIRFLOW
##########################################################

CMD ["bash", "-c", "\
airflow db migrate && \
(airflow users create \
  --username ravula \
  --password ravula \
  --firstname Airflow \
  --lastname Admin \
  --role Admin \
  --email ravulapbi@gmail.com || true) && \
airflow scheduler > /opt/airflow/logs/scheduler.log 2>&1 & \
sleep 60 && \
exec airflow webserver"]