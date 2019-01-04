FROM haproxy:1.9.0-alpine
MAINTAINER Kevin Darcel <tuxity@users.noreply.github.com>

COPY . /haproxy-src

RUN apk update && \
    apk --no-cache add py-pip build-base python-dev ca-certificates iptables && \
    cp /haproxy-src/reload.sh /reload.sh && \
    cd /haproxy-src && \
    pip install -r requirements.txt && \
    pip install . && \
    apk del build-base python-dev && \
    rm -rf "/tmp/*" "/root/.cache" `find / -regex '.*\.py[co]'`

ENV RSYSLOG_DESTINATION=127.0.0.1 \
    MODE=http \
    BALANCE=roundrobin \
    MAXCONN=4096 \
    OPTION="redispatch, httplog, dontlognull, forwardfor" \
    TIMEOUT="connect 5000, client 50000, server 50000" \
    STATS_PORT=1936 \
    STATS_AUTH="stats:stats" \
    SSL_BIND_OPTIONS=no-sslv3 \
    SSL_BIND_CIPHERS="ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:AES128-GCM-SHA256:AES128-SHA256:AES128-SHA:AES256-GCM-SHA384:AES256-SHA256:AES256-SHA:DHE-DSS-AES128-SHA:DES-CBC3-SHA" \
    HEALTH_CHECK="check inter 2000 rise 2 fall 3" \
    NBPROC=1

EXPOSE 80 443 1936
CMD ["dockercloud-haproxy"]
