FROM a1fred/docker-python-phantomjs
LABEL MAINTAINER="Alexander Henderson <git@alexsguardian.net>"
LABEL SERVICES="InfluxdbComcast.py"
LABEL REPOSITORY="https://github.com/billimek/comcastUsage-for-influxdb"
LABEL VERSION="1.0.0"

ADD . /src
WORKDIR /src

RUN pip install -r requirements.txt

COPY ./config.ini /srv/

CMD ["python", "-u", "/src/InfluxdbComcast.py"]
