FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install nsjail
RUN apt-get -y update && apt-get install -y \
    autoconf \
    bison \
    flex \
    gcc \
    g++ \
    git \
    libprotobuf-dev \
    libnl-route-3-dev \
    libtool \
    make \
    pkg-config \
    protobuf-compiler \
    uidmap \
    cmake \
    iptables \
    net-tools \
    iproute2 \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/google/nsjail.git
RUN cd /nsjail && make && mv /nsjail/nsjail /bin && rm -rf -- /nsjail

RUN apt-get update && \
apt-get install -y \
gcc uidmap netcat cmake && \
rm -rf /var/lib/apt/lists/* && \
useradd -m ctf && \
mkdir -p /home/ctf/challenge/

RUN mkdir /chroot/ && \
chown root:ctf /chroot && \
chmod 770 /chroot

# venv for POW
RUN python3 -m venv /venv
RUN bash -c "source /venv/bin/activate && pip3 install ecdsa requests proxy-protocol"

WORKDIR /home/ctf/
COPY instancer/ instancer/
COPY chal/ chal/

## BEGIN CHALLENGE SETUP

RUN chmod +x chal/start.sh

## END CHALLENGE SETUP

RUN mv chal/jail.cfg instancer/server.py instancer/pow.py instancer/setup.sh instancer/nsjail.sh / && \
rm -rf src/ && \
chown -R root:ctf . && \
chown root:ctf / /home /home/ctf/ && \
chmod +x /setup.sh /nsjail.sh && \
chmod 440 /home/ctf/chal/flag


EXPOSE 9000
ENTRYPOINT ["/setup.sh"]
