---
layout: default
---

# Speedtest Graph in Grafana.

First check out [Speedtest-for-InfluxDB-and-Grafana](https://github.com/barrycarey/Speedtest-for-InfluxDB-and-Grafana) which is pretty straight forward for setting up the docker container to run the speedtests. Make sure to follow along with the guide!

Now that you have the speedtest container running in docker and sending the info to influxdb (I recommend changing the `delay = 300` to someting more infrequent so its not testing every 5 minutes) we can set up the graph to plot the data.

- Open Grafana and in your dashboard of choice and select "Add Panel"
- Select "Graph"
- Now on the new graph panel, select edit in the drop down menu and enter the following info under the metrics tab:

| Setting       | Value         |
| ------------- |:-------------:|
| Data Source   | speedtest (or whatever your speedtest db is called     |
| A:            | default "speed_test_results" |
| SELECT        | field (download)        |
| Alias         | Down |
| B:            | default "speed_test_results" |
| SELECT        | field (upload) |
| Alias         | Up |

- On the Axes tab:

| Setting | Value |
| ------- |:-----:|
| Left Y - Unit | bits/sec |
| Left Y - Decimals | 1 |

- Enable the Legend if you want
- Under Display tab I recommend using lines with staircase enabled.
- If you want you can setup an alert under the "alert" tab to fire an alert when a certain query goes under a certain threshold.
- Time Range set "override relative time" to whatever you want. I have mine set to 30 days (30d).

--< [Back to Grafana](https://alexandzors.github.io/things/grafana)

--< [Back to Landing Page](https://alexandzors.github.io/things)
