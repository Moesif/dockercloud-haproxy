FROM haproxy:2.1.5-alpine
MAINTAINER Kevin Darcel <tuxity@users.noreply.github.com>

COPY . /haproxy-src

RUN apt-get update && \
    apt-get -y install python2 python2-dev ca-certificates iptables curl && \
    curl -s https://bootstrap.pypa.io/pip/2.7/get-pip.py get-pip.py | bash -c 'python2' && \
    cp /haproxy-src/reload.sh /reload.sh && \
    cd /haproxy-src && \
    pip2 install -r requirements.txt && \
    pip2 install . && \
    apt-get -y remove python2-dev && \
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
