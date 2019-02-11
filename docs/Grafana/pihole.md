---
layout: default
---

# Graphing data from Pi-hole in Grafana.

*This one is "rather easy."*

If you dont know what [Pi-hole](https://pi-hole.net/) I recommend checking it out as well as setting up your own instance. :)

For this tutorial I am going to be assuming your Pi-hole instance is running on a Linux VM by itself. aka nothing else is running on the same VM with it.

-----

## Getting Started

We will be using the script from this [repo](https://github.com/janw/pi-hole-influx) to scrape the Pi-hole admin API located at `http://piholeip/admin/api.php`

- First SSH to your Pi-hole host.
- Create a directory for the new script repo:

`mkdir /home/username/pihole-influx`

- Now we need to install python-pip:
  - First update your apt repository: `apt-get update`
  - Then run: `apt-get install python-pip -y`
> Remember, if you get a permission denied error make sure to append `sudo` to the beginning of your commands!

- After python-pip is installed we need to clone the repo.

`git clone https://github.com/janw/pi-hole-influx.git /home/username/pihole-influx

- Now navigate to `/pihole-influx` and run: `pip install -r requirements.txt`

- Then copy the example config to config.ini `cp config.example.ini config.ini`

- Edit the config.ini with your influxdb info and change the /[pihole/] section to your Pi-hole's IP (machine IP) and the instance_name to your Pi-hole's machine hostname.

- Now create the db for the Pi-hole stats in influxdb: 

`curl -i -XPOST http://ip-of-influx:8086/query --data-urlencode "q=CREATE DATABASE pihole"`

>If you get anything other than an HTTP 200 status, check your database connection info!

## Running piholeinflux.py as a service

- Navigate back to the /pihole-influx directory and run:

`nano piholeinflux.service`

- Change:

```s
User=pi #YOUR USERNAME
ExecStart=/usr/bin/python /home/USERNAME/pihole-influx/piholeinflux.py
```

- Save the service file (CTRL+X then type y).

- Now run:

`sudo ln -s /home/USERNAME/pihole-influx/piholeinflux.server /etc/systemd/system`

`sudo systemctl enable piholeinflux.service`

`sudo systemctl daemon-reload`

`sudo systemctl start piholeinflux.service`

> If you get an error while running make sure you can A: communicateto influxdb and B: the "USER=" in the .service file is set to a user that can run it (ie root or you).

## Setting up the Grafana Dashboard

![](https://i.imgur.com/RrIRWQo.png)

### Pi-Hole Data Source

If you have followed any of the other Tutorials from this guide you should already know what to do. If not here is how to do it.

- Select the cog on the left hand side and click "data sources"

- Click "add data source"

- Click influxdb

- Enter the following information and hit "Save & Test"
> If you get an error, double check your connection info for typos!

| Setting | Value |
| ----- |:----:|
| Name | pihole |
| URL | http://ip-of-influx:8086|
| Database | pihole |

### Dashboard Setup

Now you can import a basic dashboard using the ID from the script's repo. This will give you some basic info from your Pi-hole data source. The Dashboard ID: 6603 

HOWEVER, there are a few issues with it. First you will want to edit the Realtime Queries and add: `non_negative_derivative` to each of the queries, under "Metrics", so the Y-Axis has no negative values. And also if you don't really have lines, make sure to select "Stacked" under the Display tab.

This one is setup by personal preference so have at it!

-----

--< [Back to Grafana](https://alexandzors.github.io/things/grafana)

--< [Back to landing page](https://alexandzors.github.io/things/)
