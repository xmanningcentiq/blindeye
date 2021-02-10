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

WORKDIR /build
RUN wget https://sslvpn.demo.sonicwall.com/NetExtender.x86_64.tgz && \
    tar -xvzf NetExtender.x86_64.tgz && \
    cd netExtenderClient && \
    bash -c 'echo y | ./install'

WORKDIR /
RUN rm -rf /build

COPY .scripts/launch.expect /root/launch.expect
COPY .scripts/run.sh /root/run.sh

FROM build as run

EXPOSE 22/tcp
EXPOSE 53/udp
EXPOSE 3180/tcp

WORKDIR /root
ENTRYPOINT [ "./run.sh" ]
