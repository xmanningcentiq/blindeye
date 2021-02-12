FROM alpine:3.13 as build

ARG VPN_USER
ARG VPN_PASS
ARG VPN_DOMAIN
ARG VPN_SERVER

RUN apk add \
    bash \
    dnsmasq \
    dropbear \
    expect \
    gcompat \
    iptables \
    file \
    libc-dev \
    openjdk8-jre \
    ppp \
    squid

RUN mkdir /etc/dropbear && \
    chmod 0700 /etc/dropbear && \
    adduser -h /home/null -D null && \
    mkdir /home/null/.ssh && \
    touch /home/null/.ssh/authorized_keys && \
    chown -R null /home/null/.ssh && \
    chmod 0700 /home/null/.ssh && \
    chmod 0600 /home/null/.ssh/authorized_keys

WORKDIR /build
RUN wget https://sslvpn.demo.sonicwall.com/NetExtender.x86_64.tgz && \
    tar -xvzf NetExtender.x86_64.tgz && \
    cd netExtenderClient && \
    bash -c 'echo y | ./install'

WORKDIR /
RUN rm -rf /build

COPY .scripts/launch.expect /root/launch.expect
COPY .scripts/keepalive.sh /root/keepalive.sh
COPY .scripts/run.sh /root/run.sh
COPY .scripts/dropbear /etc/conf.d/dropbear
COPY .scripts/squid.conf /etc/squid/squid.conf

FROM build as run

EXPOSE 22/tcp
EXPOSE 3128/tcp

WORKDIR /root
ENTRYPOINT [ "./run.sh" ]
