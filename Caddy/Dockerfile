FROM caddy:builder AS builder

RUN xcaddy build --with github.com/caddy-dns/cloudflare --with github.com/caddyserver/ntlm-transport --with github.com/sjtug/caddy2-filter --with github.com/greenpau/caddy-auth-portal

FROM caddy:alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy