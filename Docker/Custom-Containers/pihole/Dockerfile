FROM alpine as builder

LABEL MAINTAINER="Alexander Henderson <git@alexsguardian.net>"
LABEL SERVICES="piholeinflux.py"
LABEL REPOSITORY="https://github.com/janw/pi-hole-influx.git"
LABEL VERSION="1.0.0"

RUN apk add --no-cache git
WORKDIR /app
RUN git clone https://github.com/janw/pi-hole-influx.git
 
FROM python:3-alpine
WORKDIR /usr/src/app

COPY --from=builder /app/pi-hole-influx/requirements.txt /usr/src/app
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt
COPY --from=builder /app/pi-hole-influx/piholeinflux.py /usr/src/app
COPY config.ini .
 
CMD [ "python", "./piholeinflux.py" ]
