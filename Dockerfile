FROM ubuntu:20.04 AS basegame
MAINTAINER Marcus Hughes <hello@msh100.uk>

ENV DEBIAN_FRONTEND noninteractive

ARG STEAM_USER
ARG STEAM_PASS

RUN : "${STEAM_USER:?STEAM_USER is required.}"
RUN : "${STEAM_PASS:?STEAM_PASS is required.}"

RUN echo steam steam/question select "I AGREE" | debconf-set-selections && \
    echo steam steam/license note '' | debconf-set-selections

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y lib32gcc1 steamcmd libcurl4:i386 wget unzip bbe jq

RUN /usr/games/steamcmd \
    +@sSteamCmdForcePlatformType windows \
    +login "${STEAM_USER}" "${STEAM_PASS}" \
    +force_install_dir /gamefiles/ \
    +app_update 9010 \
    +quit

RUN mkdir -p /output/main/ && \
    cp /gamefiles/Main/mp_*.pk3 /output/main/ && \
    cp /gamefiles/Main/pak0.pk3 /output/main/

RUN wget http://osp.dget.cc/orangesmoothie/downloads/osp-wolf-0.9.zip && \
    md5sum osp-wolf-0.9.zip | cut -d' ' -f1 | grep 835eea094b832dc48a4d8329ce5290ba && \
    unzip osp-wolf-0.9.zip && \
    rm -rf osp-wolf-0.9.zip osp/Docs/ osp/*.txt osp/*.cfg && \
    mv osp /output/

ADD fetchRtcwPro.sh /output/fetchRtcwPro.sh
RUN datapath="/output/rtcwpro-data" bash /output/fetchRtcwPro.sh "36772867"

RUN wget https://msh100.uk/files/rtcw-pb.tar.gz && \
    md5sum rtcw-pb.tar.gz | cut -d' ' -f1 | grep 6f462200f4793502b1e654d84cf79d3c && \
    tar -xvf rtcw-pb.tar.gz && \
    mv pb /output/

RUN unzip /output/main/mp_bin.pk3 -d /output/main && \
    rm -rf /output/main/*.dll

RUN wget https://msh100.uk/files/rtcw-binaries.tar.gz && \
    md5sum rtcw-binaries.tar.gz | cut -d' ' -f1 | grep 29ecb883c5657d3620a7d2dec7a0657f && \
    tar -xvf rtcw-binaries.tar.gz && \
    cp -r binaries/* /output/

RUN wget https://msh100.uk/files/libnoquery.so && \
    md5sum libnoquery.so | cut -d' ' -f1 | grep 91d9c6fd56392c60461c996ca29d6467

FROM ubuntu:14.04
MAINTAINER Marcus Hughes <hello@msh100.uk>

ENV DEBIAN_FRONTEND noninteractive
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y wget libc6-i386 libc6:i386 unzip bbe git

RUN wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 && \
    md5sum jq-linux64 | cut -d' ' -f1 | grep 1fffde9f3c7944f063265e9a5e67ae4f && \
    mv jq-linux64 /usr/bin/jq && \
    chmod +x /usr/bin/jq

RUN wget http://archive.debian.org/debian/pool/main/g/gcc-2.95/libstdc++2.10-glibc2.2_2.95.4-27_i386.deb && \
    md5sum libstdc++2.10-glibc2.2_2.95.4-27_i386.deb | cut -d' ' -f1 | grep fa8e4293fa233399a2db248625355a77 && \
    dpkg -i libstdc++2.10-glibc2.2_2.95.4-27_i386.deb && \
    rm -rf libstdc++2.10-glibc2.2_2.95.4-27_i386.deb

RUN useradd -ms /bin/bash game

USER game
WORKDIR /home/game

COPY --chown=game:game --from=basegame /output/ /home/game

RUN mkdir -p /home/game/rtcwpro && \
    ln -s /home/game/osp/maps /home/game/rtcwpro/maps
RUN git clone --depth 1 "https://github.com/msh100/rtcw-config.git" \
    /home/game/settings/

COPY --chown=game:game entrypoint.sh /home/game/start
RUN chmod +x /home/game/start

EXPOSE 27960/udp

ENTRYPOINT ["/home/game/start"]
