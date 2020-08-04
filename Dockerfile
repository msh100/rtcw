FROM ubuntu:14.04
MAINTAINER Marcus Hughes <hello@msh100.uk>

ENV DEBIAN_FRONTEND noninteractive
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y wget libc6-i386 libc6:i386 unzip

RUN wget http://archive.debian.org/debian/pool/main/g/gcc-2.95/libstdc++2.10-glibc2.2_2.95.4-27_i386.deb && \
    md5sum libstdc++2.10-glibc2.2_2.95.4-27_i386.deb | cut -d' ' -f1 | grep fa8e4293fa233399a2db248625355a77 && \
    dpkg -i libstdc++2.10-glibc2.2_2.95.4-27_i386.deb && \
    rm -rf libstdc++2.10-glibc2.2_2.95.4-27_i386.deb

RUN useradd -ms /bin/bash game
USER game
WORKDIR /home/game

RUN wget https://msh100.uk/files/rtcw.tar.gz && \
    md5sum rtcw.tar.gz | cut -d' ' -f1 | grep 847a03b34546e947c104435320eab035 && \
    tar --strip-components=1 -xvf rtcw.tar.gz && \
    rm -rf rtcw.tar.gz

RUN wget http://osp.dget.cc/orangesmoothie/downloads/osp-wolf-0.9.zip && \
    md5sum osp-wolf-0.9.zip | cut -d' ' -f1 | grep 835eea094b832dc48a4d8329ce5290ba && \
    unzip osp-wolf-0.9.zip && \
    rm -rf rm -rf osp-wolf-0.9.zip osp/Docs/ osp/*.txt osp/*.cfg

RUN wget https://msh100.uk/files/libnoquery.so && \
    md5sum libnoquery.so | cut -d' ' -f1 | grep 91d9c6fd56392c60461c996ca29d6467

RUN wget https://msh100.uk/files/rtcw-mapscripts.tar.gz && \
    md5sum rtcw-mapscripts.tar.gz | cut -d' ' -f1 | grep 3dc50ff0b318cb9e0fbe9d6f511b12e3 && \
    tar -xvf rtcw-mapscripts.tar.gz && \
    mkdir -p osp/maps/ && \
    mv maps/*.bsp osp/maps/ && \
    rm -rf rtcw-mapscripts.tar.gz maps/

COPY --chown=game:game mapscripts/* /home/game/osp/maps/
COPY --chown=game:game server.cfg /home/game/main/server.cfg.tpl

COPY --chown=game:game entrypoint.sh /home/game/start
RUN chmod +x /home/game/start

EXPOSE 27960/udp

ENTRYPOINT ["/home/game/start"]
