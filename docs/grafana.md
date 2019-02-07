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

>I plan to make this as detailed as possible in the coming weeks. Right now its a start to what I hope will be a fully featured guide. So bare with me!

-----

## Pre-Requisites

- You will need to know how to edit config files from the Linux command line. I recommend using Nano as that's what this tutorial will use. If you don't have Nano installed you can get it by running `apt-get install nano -y` or `yum install nano -y`. For editing config files on Windows I recommend using [Visual Studio Code](https://code.visualstudio.com/). Its awesome, open source, and has a dark theme by default!
- You will need at least one Linux machine running Docker.
- You will need a few hours of dedicated time.
- You will need to know how to query databases. *Don't worry ill guide you through some basics!*
- You will need SSH access to your Linux machine(s). If you are SSHing from Windows, I recommend installing the Windows Subsystem for Linux (WSL) feature and either enabling straight BASH or installing the Ubuntu image from the Windows Store.

> If you don't have a docker system running on a Linux box you can check out my installdocker.sh and updateubuntu.sh shell scripts [here](https://github.com/alexandzors/things/tree/master/Scripts/shell_scripts)

Since this tutorial includes Plex services monitoring you will need the following installed somewhere:

- [Sonarr](https://sonarr.tv)
- [Radarr](https://radarr.video/)
- [Plex Media Server](https://plex.tv)
- [Tautulli](https://tautulli.com/)
- [Ombi](https://ombi.io/)
- Optional: [Transmission](https://github.com/haugene/docker-transmission-openvpn)

Draft 3, 2/3/2019 - 9:11PM

-----

## Setting up Influxdb

Now for this guide we will be setting up influxdb in docker. Grafana supports a few different data sources however for this guide we will only be using influxdb and prometheus.

- ssh to your linux docker machine and run the following commands. (You can change the volume mapping to match your setup).

`mkdir /home/username/influxdb`

`docker run -d -p 8086:8086 -v /home/username/influxdb:/var/lib/influxdb influxdb`

If you get a permission denied error just append `sudo` to the beginning of your commands.

- Now that influxdb is running we can create our first database. This will be for [Varken](https://github.com/Boerderij/Varken) which will be collecting data from Sonarr, Radarr, Tautulli, Ombi, and sending it to influx. So run the following command to create your varken db.

`curl -i -XPOST http://influxhostip:8086/query --data-urlencode 'q=CREATE DATABASE "varken"'`

You should see something like this, if it works:

```
HTTP/1.1 200 OK
Content-Type: application/json
Request-Id: feeb7689-289a-11e9-8759-0242ac110003
X-Influxdb-Build: OSS
X-Influxdb-Version: 1.7.3
X-Request-Id: feeb7689-289a-11e9-8759-0242ac110003
Date: Mon, 04 Feb 2019 16:36:17 GMT
Transfer-Encoding: chunked

{"results":[{"statement_id":0}]}
```

## Setting up Varken

Without Varken, this project would have been a lot harder to get going. Make sure you go buy them a [coffee](https://buymeacoff.ee/varken)!

- Hopefully you are still ssh'd to your docker machine from the influx install. If not ssh back into it and run the following command.

`mkdir /home/username/varken`

- Now you will need to create a varken.ini file in your ~/varken directory. You can find an example of this config file [here](https://github.com/Boerderij/Varken/blob/master/data/varken.example.ini). To create this file you can run either:

`nano varken.ini` or `touch varken.ini && nano varken.ini`

Varken config docs can be found [here](https://github.com/Boerderij/Varken/wiki/Configuration).

*You can find my exact varken.ini file [here](https://github.com/alexandzors/things/blob/master/config_files/varken.ini) if you are stuck.*
- Once the config file is done you can now run the following to start Varken

`docker run -d --name=varken -v /home/username/varken:/config -e TZ=America/Chicago boerderij/varken`

Change `TZ` to match your timezone.

So now your docker system should have two running containers. One for varken and one for Influxdb. Now if you didn't append `--name` to your docker run commands they will be under randomly generated names.

## Setting up Grafana

So now that we have our first data source setup and our first data collector, we are now ready to setup Grafana to aggregate and graph it!

- SSH into your docker system again and create a directory for Grafana and a directory for Grafana configs.

`mkdir /home/username/grafana && mkdir /home/username/grafana/conf`

- Now create a grafana.ini file inside the ~/conf folder.

`nano grafana.ini`

- Now you can c/p the sample.ini into the grafana.ini file which can be found [here](https://raw.githubusercontent.com/grafana/grafana/master/conf/sample.ini). Now you can edit these settings per your environment. For mine, I only changed a few settings in /[server/] to allow Grafana to work behind my caddy reverse proxy.

```ini
domain = mydoamin.net
root_url = http://mydomain.net/grafana
```

and my caddy config for grafana looks like:

```caddyfile
www.domain.net, domain.net {
    gzip
    index index.hmtl index.htm
    tls certs@domain.net
    header / {
        Content-Security-Policy
        default-src "*"
        X-Frame-Options "DENY"
        X-Content-Type-Options "nosniff"
        X-XSS-Protection "1; mode=block"
        Strict-Transport-Security "max-age=31536000;"
        Referrer-Policy "same-origin"
    }
    proxy /grafana/ http://10.9.9.132:3000 {
        without /grafana/
        transparent
        websocket
    }
}
```

- Once your grafana.ini is setup, we can setup Grafana.

`docker run -d --user 1000 --volume "/home/user/grafana:/var/lib/grafana" --volume "/home/user/grafana/conf:/etc/grafana" -p 3000:3000 -e "GF_SECURITY_ADMIN_PASSWORD=admin" -e "GF_INSTALL_PLUGINS=natel-influx-admin-panel,ryantxu-annolist-panel,jdbranham-diagram-panel,grafana-worldmap-panel,grafana-piechart-panel" grafana/grafana`

Make sure that you have both the grafana-world-panel and grafana-piechart-panel are included in your plugins install otherwise you won't be able to use a few Varken features.

- Once Grafana is running navigate to it using your browser. If you didn't edit any settings in the grafana.ini it should be http://ip:3000. The login should be admin/admin. 

> If you get a permissions error while Grafana is starting. run `chmod 777` against your Grafana directory.

## Setting up the Grafana dashboard

Now that we have Grafana, Influxdb, and Varken running we can now get the dashboard setup.

- First we need to add the Influxdb data source to Grafana. If this is the first time you are setting up Grafana, there should be a walk through. So click on Add new data source and then select Influxdb. Enter the following information:

| Setting       | Value         |
| ------------- |:-------------:|
| Name          | Varken        |
| URL           | http://ip:8086|
| Database      | varken        |

- Now that the data source is added we can add the dashboard. Again the awesome Varken fellows have an official Varken dashboard that includes pre-configured elements for reading data from your varken database. You can get the dashboard ID from [here](https://grafana.com/dashboards/9585). Paste the code into the dashboard import section and click "load."

![My Dashboard](https://i.imgur.com/WfCEpNd.png)

> Now my dashboard includes data from [Glances](https://nicolargo.github.io/glances/) as well as [Telegraf](https://www.influxdata.com/time-series-platform/telegraf/). Which when I get a chance, and my infant daughter allows me, I will get another guide up for importing glances and Telegraf data into your Varken dashboard to monitor system information. My dashboard is also not complete as there are a few other things I want to add to it.

**This guide is incomplete and is still a WIP. Please feel free to reach out with any issues!**

Please make sure to check out the repos for Varken and Transmission-exporter! A lot of the credit goes to them for making this easy for media server setups.:

- [https://github.com/Boerderij/Varken](https://github.com/Boerderij/Varken)
- [https://github.com/metalmatze/transmission-exporter](https://github.com/metalmatze/transmission-exporter)


# More Guides (WIP)

- [Telegraf for Grafana on Windows](https://alexandzors.github.io/things/telegraf)
- [Glances for Grafana on Linux](https://alexandzors.github.io/things/glances)
- [Speedtest Graph in Grafana](https://alexandzors.github.io/things/speedtest)
- [Transmission - Prometheus Exporter](https://alexandzors.github.io/things/transmission)

-----

--< [Back to landing page](https://alexandzors.github.io/things/)
