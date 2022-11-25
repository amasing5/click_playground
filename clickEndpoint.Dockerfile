ARG UBUNTU_VERSION=bionic-20190515
FROM ubuntu:${UBUNTU_VERSION}

ARG ENDPOINT_CLIENT_REQUIRES="\
    net-tools \
    iputils-ping \
    tcpdump \
    libpcap-dev \
    vim \
    uml-utilities \
    ethtool \
    python \
    wget \
    apache2 \
    luajit \
    iperf3 \
    iptables \
    make \
    g++ \
   "

RUN apt-get update -qqy && apt install -y --no-install-recommends ${ENDPOINT_CLIENT_REQUIRES}

RUN apt install -y python-pip && pip install scapy

COPY artifacts/server  /server
COPY artifacts/client  /client
