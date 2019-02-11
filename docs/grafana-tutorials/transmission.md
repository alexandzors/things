---
layout: default
---

# Transmission - Prometheus Exporter

For exporting transmission data into Grafana we will need to setup [Prometheus](https://prometheus.io/).

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

Since I don't have any authentication for transmission I do not need to specify the username and password. If you need to, just add `-e TRANSMISSION_USERNAME=username -e TRANSMISSION_PASSWORD=password` to the run string before `metalmatze/transmission-exporter`

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

Note: If you navigate to http://ipoftransmissionexporter:19091/metrics you can see what metrics can be queried for transmission. Also typing into a query field with the Prometheus data source selected will show a list of possible queries aswell!

--< [Back to Grafana](https://alexandzors.github.io/things/grafana)

--< [Back to landing page](https://alexandzors.github.io/things/)
