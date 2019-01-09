# Caddyfile Information

Using:

```Caddyfile
header / {
    Content-Security-Policy 
    default-src "*"
    X-Frame-Options "DENY"
    X-Content-Type-Options "nosniff"
    X-XSS-Protection "1; mode=block"
    Strict-Transport-Security "max-age=31536000;"
    Referrer-Policy "same-origin"
    Feature-Policy "self"
}
```

Will give you:

![](https://i.imgur.com/x8zwKLp.png)

with https://securityheaders.com
