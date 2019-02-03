---
layout: default
---

# THE GRAFANA MONITOR GUIDE
*Monitoring your homelab like a pro!*

--

## Before we get started

When I first went to setup Grafana for homelab monitoring I quickly came to the realization that most of the guides out there kind of suck. So with a nudge from a few fellows in the 'plexaholics' Facebook group, I decided to write up this guide.

*Note: My environment consists of both Linux and Windows virtual machines running on a 2xE5-2670v2 x 128GB RAM server. So your mileage may very.*

Also this tutorial is not designed for people that wish to run Grafana outside of their network on a cloud hosted instance. So do not expect any sort of guide on SSL except for running Grafana behind a reverse proxy powered by [Caddy](https://caddyserver.com/)! If you wish to setup SSL/TLS/Encryption for your database calls and collectors, you will have to find a different guide for that. Sorry!

## Pre-Requisites

- You will need to know how to edit config files from the Linux command line. I recommend using Nano as that's what this tutorial will use. If you don't have Nano installed you can get it by running `apt-get install nano -y` or `yum install nano -y`. For editing config files on Windows I recommend using [Visual Studio Code](https://code.visualstudio.com/). Its awesome, open source, and has a dark theme by default!
- You will need at least one Linux machine running Docker.
- You will need a few hours of dedicated time.
- You will need to know how to query databases. *Don't worry ill guide you through some basics!*
- You will need to SSH access to your Linux machine(s). If you are SSHing from Windows, I recommend installing the Windows Subsystem for Linux (WSL) feature and either enabling straight BASH or installing the Ubuntu image from the Windows Store.

Since this tutorial includes Plex services monitoring you will need the following installed somewhere:

- [Sonarr](https://sonarr.tv)
- [Radarr](https://radarr.video/)
- [Plex Media Server](https://plex.tv)
- [Tautulli](https://tautulli.com/)
- [Ombi](https://ombi.io/)
- [Transmission](https://github.com/haugene/docker-transmission-openvpn)

Draft 2, 2/3/2019 - 12:04PM

## Setting up Influxdb

Now for this guide we will be setting up influxdb in docker. Grafana supports a few different data sources however for this guide we will only be using influxdb and prometheus.

- ssh to your linux docker machine and run the following commands. (You can change the volume mapping to match your setup).

`mkdir /home/username/influxdb`

`docker run -p 8086:8086 -v /home/username/influxdb:/var/lib/influxdb influxdb`

If you get a permission denied error just append `sudo` to the beginning of your commands.

- Now that influxdb is running we can create our first database. This will be for [Varken](https://github.com/Boerderij/Varken) which will be collecting data from Sonarr, Radarr, Tautulli, and sending it to influx. So run the following command to create your varken db.

`curl -i -XPOST http://influxhostip:8086/query --data-urlencode "q=CREATE DATABSE varken`

Hopefully you got a successful response and not a 404 message.

## Setting up Varken

- Hopefully you are still ssh'd to your docker machine from the influx install. If not ssh back into it and run the following command.

`mkdir /home/username/varken`

- Now you will need to create a varken.ini file in your ~/varken directory. You can find an example of this config file [here](https://github.com/alexandzors/things/confg_files/varken.ini). To create this file you can run either:

`nano varken.ini` or `touch varken.ini && nano varken.ini`

Varken config docs can be found [here](https://github.com/Boerderij/Varken/wiki/Configuration)

- Once the config file is done you can now run the following to start Varken

`docker run -d --name=varken -v /home/username/varken:/config TZ=America/Chicago boerderij/varken`

Change `TZ` to match your timezone.