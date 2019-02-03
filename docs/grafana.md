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

- Now that influxdb is running we can create our first database. This will be for [Varken](https://github.com/Boerderij/Varken) which will be collecting data from Sonarr, Radarr, Tautulli, Ombi, and sending it to influx. So run the following command to create your varken db.

`curl -i -XPOST http://influxhostip:8086/query --data-urlencode "q=CREATE DATABSE varken`

Hopefully you got a successful response and not a 404 message.

## Setting up Varken

Without Varken, this project would have been a lot harder to get going. Make sure you go buy them a [coffee](https://buymeacoff.ee/varken)!

- Hopefully you are still ssh'd to your docker machine from the influx install. If not ssh back into it and run the following command.

`mkdir /home/username/varken`

- Now you will need to create a varken.ini file in your ~/varken directory. You can find an example of this config file [here](https://github.com/alexandzors/things/confg_files/varken.ini). To create this file you can run either:

`nano varken.ini` or `touch varken.ini && nano varken.ini`

Varken config docs can be found [here](https://github.com/Boerderij/Varken/wiki/Configuration)

- Once the config file is done you can now run the following to start Varken

`docker run -d --name=varken -v /home/username/varken:/config TZ=America/Chicago boerderij/varken`

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

## Setting up the Grafana dashboard

Now that we have Grafana, Influxdb, and Varken running we can now get the dashboard setup.

- First we need to add the Influxdb data source to Grafana. If this is the first time you are setting up Grafana, there should be a walk through. So click on Add new data source and then select Influxdb. Enter the following information:

| Setting       | Value         |
| ------------- |:-------------:|
| Name          | Varken        |
| URL           | http://ip:8086|
| Database      | varken        |

- Now that the data source is added we can add the dashboard. Again the awesome Varken fellows have an official Varken dashboard that includes pre-configured elements for reading data from your varken database. You can get the dashboard ID from [here](https://grafana.com/dashboards/9585). Paste the code into the dashboard import section and click "load."

[](https://i.imgur.com/eFbZzUh.png)

- Now my dashboard includes data from [Glances](https://nicolargo.github.io/glances/) as well as [Telegraf](https://www.influxdata.com/time-series-platform/telegraf/). Which when I get a chance, and my infant daughter allows me, I will get another guide up for importing glances and Telegraf data into your Varken dashboard to monitor system information. My dashboard is also not complete as there are a few other things I want to add to it.

## Transmission info

Now this section is for people that are using transmission as their download client. For exporting transmission data into Grafana we will need to setup [Prometheus](https://prometheus.io/).

- SSH into your docker host and make a new directory for Prometheus. 

`mkdir /home/username/prometheus`

- Now create a prometheus.yml file in the new ~/prometheus directory.

`nano prometheus.yml`

```yaml
# prometheus.yml
global:
  scrape_interval: 5s
  external_labels:
    monitor: 'prom.<hostname>'
scrape_configs:
  - job_name: 'transmission'
    scrape_interval: 10s
    static_configs:
      - targets: ['<ipoftransmissionexporter>:19091']
```

Make sure to change \<hostname\> to the hostname of the machine hosting transmission. Also \<ipoftransmissionexporter\> to the IP of the docker machine running the container in the next step.

- Setup the [transmission exporter](https://github.com/metalmatze/transmission-exporter) for Prometheus:

`docker run -d -p 19091:19091 -e TRANSMISSION_ADDR=http://<ipoftransmission>:<port> metalmatze/transmission-exporter`

Since I don't have any authentication for transmission I do not need to specify the username and password. If you need to just add `-e TRANSMISSION_USERNAME=username -e TRANSMISSION_PASSWORD=password` to the run string before `metalmatze/transmission-exporter`

- Now we can launch Prometheus:

`sudo docker run -d --name prometheus -v "/home/username/prom/prometheus.yml:/etc/prometheus/prometheus.yml" -p 9090:9090 prom/prometheus --config.file='/etc/prometheus/prometheus.yml'`

Once Prometheus is running we can add it as a data source in Grafana.

- Login to Grafana and click the settings cog on the left side. Click on Data Sources and then click Add data source.

- Select Prometheus and enter the following info:

| Setting       | Value         |
| ------------- |:-------------:|
| Name          | Prometheus    |
| URL           | http://ip:9090|
| HTTP Method   | GET           |

- Now that we have Prometheus setup, return to your dashboard you setup with Varken.

- Click Add and then find the singlestat panel and select it.

- In the edit window for the panel, select metrics and then under datasource select Prometheus.

- In the query field insert:

`transmission_session_stats_downloaded_bytes{type="cumulative"}`

- Select options and under Stat select "Average" and then under Unit select "data (metric)/bytes"

- Click General and name the panel whatever you want.

- You now have a panel that tells you the total downloaded bytes from your transmission client.

Note: If you navigate to http://ip:19091/metrics you can see what metrics can be queried for transmission.