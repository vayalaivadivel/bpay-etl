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
    curl \
    unzip && \
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
        -o "/tmp/awscliv2.zip" && \
    unzip /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    curl -fsSL \
        "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" \
        -o /tmp/session-manager-plugin.deb && \
    dpkg -i /tmp/session-manager-plugin.deb && \
    rm -rf /tmp/aws /tmp/awscliv2.zip /tmp/session-manager-plugin.deb && \
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

COPY --chown=airflow:root docker/airflow-entrypoint.sh /opt/airflow/airflow-entrypoint.sh
RUN chmod +x /opt/airflow/airflow-entrypoint.sh
CMD ["bash", "/opt/airflow/airflow-entrypoint.sh"]