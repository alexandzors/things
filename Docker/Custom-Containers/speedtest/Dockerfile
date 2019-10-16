FROM python:alpine
LABEL MAINTAINER="Alexander Henderson <git@alexsguardian.net>"
LABEL SERVICES="influxspeedtest.py"
LABEL REPOSITORY="https://github.com/atribe/Speedtest-for-InfluxDB-and-Grafana"
LABEL VERSION="1.0.0"

VOLUME /src/
COPY influxspeedtest.py requirements.txt config.ini /src/
ADD influxspeedtest /src/influxspeedtest
WORKDIR /src

RUN pip install --upgrade pip
RUN pip install -r requirements.txt

CMD ["python", "-u", "/src/influxspeedtest.py"]
