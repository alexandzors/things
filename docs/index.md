---
layout: default
---
# Before we get started

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

Draft 1, 2/3/2019 - 1:26AM