# Caddy Info

"Caddy 2 is a powerful, enterprise-ready, open source web server with automatic HTTPS written in Go" - Caddy

- [https://caddyserver.com/docs](https://caddyserver.com/docs) for more Caddy server documentation as well as extra plugins that can be used in the docker build script.
- [https://caddy.community/](https://caddy.community/) for help regarding Caddy server.
- [https://hub.docker.com/alexandzors/caddy] for this docker image info.

## How to use alexandzors/caddy:

### Step 1.

Setup your domain and subdomains to point to your WAN IP.
If you have a DHCP enabled WAN IP you should setup DynDNS to keep the records updated with IP changes.

### Step 2.

Forward port `tcp/80` and `tcp/443` to your docker host via your router/firewall

### Step 3.

`sudo docker pull alexandzors/caddy`

`sudo mkdir /opt/docker/caddy`
`sudo mkdir /opt/docker/auth/local/`
`sudo touch /opt/docker/auth/local/users.json`

`sudo chown -r uruser:uruser /opt/docker/`

`wget https://raw.githubusercontent.com/alexandzors/things/master/Caddy/docker-compose.yml /opt/docker/caddy/docker-compose.yml`

`wget https://raw.githubusercontent.com/alexandzors/things/master/Caddy/Caddyfile /opt/docker/caddy/Caddyfile`


Edit Caddyfile to your needs. The example is setup for env variables. Replace any {$variable}'s with your information if you don't plan on using them. Comment out or delete any unneeded configs.