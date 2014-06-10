FROM ubuntu:trusty
MAINTAINER randall@mason.ch

#Use local apt-cacher-ng
RUN  echo 'Acquire::http { Proxy "http://192.168.128.138:3142"; };' >> /etc/apt/apt.conf.d/01proxy

RUN echo "dash    dash/sh boolean false" | sudo debconf-set-selections && sudo dpkg-reconfigure --frontend=noninteractive dash

RUN sed -i "/^deb.*universe$/ s/\(.*\)universe/\1universe\n\1multiverse/" /etc/apt/sources.list
RUN sed -i "/^deb.*trusty universe$/ s/\(.*\)ubuntu.com\(.*\)universe/\1ubuntu.com\2universe\n\1canonical.com\2partner/" /etc/apt/sources.list

RUN apt-get update -q

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y install git subversion libopenal-dev libxml2-dev pkg-config cmake wget libtool autoconf automake build-essential libreoffice-dev libfreetype6-dev libfaac-dev libmp3lame-dev libass-dev libgpac-dev libsrtp0-dev srtp-utils libspeex-dev libspeexdsp-dev libogg-dev libvorbis-dev libtheora-dev yasm libvpx-dev libopencore-amrwb-dev libopencore-amrnb-dev libgsm1-dev libopus-dev libx264-dev libncurses5-dev openssl libssl-dev libfdk-aac-dev 

ADD ./bootstrap_ubuntu.sh /telepresence/

CMD ["/telepresence/bootstrap_ubuntu.sh"]
