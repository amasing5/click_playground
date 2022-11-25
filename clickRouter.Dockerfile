ARG UBUNTU_VERSION=bionic-20190515
FROM ubuntu:${UBUNTU_VERSION}

ENV CLICK_DIR=/click

# Install required debian packages for building click
ENV CLICK_REQUIRES=" \
    git \
    ca-certificates=20180409 \
    automake \
    cmake \
    make \
    g++ \
    doxygen \
    checkinstall \
    libtool \
    pkg-config \
    autoconf \
    net-tools \
    iputils-ping \
    uml-utilities \
    tcpdump \
    libpcap-dev \
    ruby \
    ruby-dev \
    rubygems \
    build-essential \
    "
RUN apt-get update -qqy && apt install -y --no-install-recommends ${CLICK_REQUIRES}

########## Basic click install begins here along with doxygen builds
# Clone click repo and build it
RUN git clone https://github.com/kohler/click.git
WORKDIR ${CLICK_DIR}
RUN /click/configure && make install



FROM ubuntu:${UBUNTU_VERSION}
ENV BUILD_DEPS="\
    cmake \
    make \
    g++ \
    build-essential \
    telnet \
    tcpdump \
    python2.7 \
    python-pip \
    iptables \
    net-tools \
    iputils-ping \
    tcpdump \
    libpcap-dev \
    "
COPY --from=0 /click /click_playground/click
RUN apt-get update -qqy && apt-get -y install ${BUILD_DEPS} && \
    rm -rf /var/lib/apt/lists/*

RUN pip install chevron

COPY artifacts/router/bin /click_playground/bin
COPY artifacts/router/confs /click_playground/confs
