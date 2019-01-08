#!/bin/bash
#Use this shell script to build a custom docker image for Caddy server based on abiosoft/caddy with no telemetery stats
#$PLUGINS should be a comma seperated list.
$PLUGINS=filemanager,git,cloudflare,geoip,realip,nobots

docker build --build-arg -f Dockerfile-no-stats plugins=$PLUGINS github.com/abiosoft/caddy-docker.git