#!/bin/bash

echo "dash    dash/sh boolean false" | sudo debconf-set-selections ; sudo dpkg-reconfigure --frontend=noninteractive dash

sudo sed -i "/^# deb.*multiverse/ s/^# //" /etc/apt/sources.list
sudo sed -i "/^# deb.*partner/ s/^# //" /etc/apt/sources.list

sudo apt-get update  

mkdir -p /vagrant/ubuntu_archives

cd /vagrant/ubuntu_archives

find *deb -type f -a -not -type l | while read file; do sudo ln -sf $PWD/$file /var/cache/apt/archives/$file; done

sudo apt-get -y install git subversion

cd /vagrant/
[ ! -d ffmpeg ] && git clone -b release/1.2 git://source.ffmpeg.org/ffmpeg.git ffmpeg &
[ ! -d doubango ] && ( while ps aux | grep -v grep | grep -q "source.ffmpeg.org/ffmpeg.git"; do sleep 5; done; svn checkout http://doubango.googlecode.com/svn/branches/2.0/doubango doubango ) &
[ ! -d telepresence ] && ( while ps aux | grep -v grep | grep -q "doubango.googlecode.com/svn/branches/2.0/doubango"; do sleep 5; done; svn checkout https://telepresence.googlecode.com/svn/trunk/ telepresence ) &

sudo apt-get -y install libopenal-dev libxml2-dev pkg-config cmake wget libtool autoconf automake build-essential libreoffice-dev libfreetype6-dev libfaac-dev libmp3lame-dev libass-dev libgpac-dev libsrtp0-dev srtp-utils libspeex-dev libspeexdsp-dev libogg-dev libvorbis-dev libtheora-dev yasm libvpx-dev libopencore-amrwb-dev libopencore-amrnb-dev libgsm1-dev libopus-dev libx264-dev libncurses5-dev openssl libssl-dev
sudo apt-get -y install libfdk-aac-dev 

find /var/cache/apt/archives/*deb -type f -a -not -type l | while read file; do sudo mv $file .; sudo ln -sf $PWD/${file/*archives\//} $file; done

export LD_LIBRARY_PATH=/usr/local/lib/

#cd /vagrant/
#[ ! -d g729b ] && svn co http://g729.googlecode.com/svn/trunk/ g729b
#cd g729b
#svn up
#svn status | grep ^? | awk '{print $2}'  | xargs rm -rf
#sed -i '1,/==/s/==/=/' autogen.sh
#./autogen.sh && ./configure --enable-static --enable-shared && make && sudo make install || exit 1

#cd /vagrant/
#[ ! -d ilbc ] && svn co http://doubango.googlecode.com/svn/branches/2.0/doubango/thirdparties/scripts/ilbc
#cd ilbc
#svn up
#svn status | grep ^? | awk '{print $2}'  | xargs rm -rf
#sed -i '1,/==/s/==/=/' autogen.sh
#[ ! -f rfc3951.txt ] && ( wget http://www.ietf.org/rfc/rfc3951.txt && awk -f extract.awk rfc3951.txt )
#./autogen.sh && ./configure
#make && sudo make install || exit 1

cd /vagrant/

while ps aux | grep -v grep | grep "source.ffmpeg.org/ffmpeg.git"
do
	sleep 5
done

cd ffmpeg
git pull

./configure \
--extra-cflags="-fPIC" \
--extra-ldflags="-lpthread" \
--enable-pic --enable-memalign-hack --enable-pthreads \
--enable-shared --enable-static \
--disable-network --enable-pthreads \
--disable-ffmpeg --disable-ffplay --disable-ffserver --disable-ffprobe \
--enable-gpl \
--disable-debug \
--enable-libfreetype \
--enable-libfaac --enable-libfdk-aac --enable-libass --enable-libmp3lame --enable-libopus --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libx264 \
--enable-nonfree
make && sudo make install || exit 1

cd /vagrant/

while ps aux | grep -v grep | grep "doubango.googlecode.com/svn/branches/2.0/doubango"
do
	sleep 5
done

cd doubango 
svn status | grep ^? | awk '{print $2}'  | xargs rm -rf
svn up; sed -i '1,/==/s/==/=/' autogen.sh
sed -i 's/TDAV_VP8_DISABLE_EXTENSION       0/TDAV_VP8_DISABLE_EXTENSION       1/' tinyDAV/src/codecs/vpx/tdav_codec_vp8.c
#./autogen.sh && ./configure --with-speexdsp --with-ffmpeg && make && sudo make install || exit 1
./autogen.sh && ./configure --with-ssl --with-srtp --with-vpx --with-yuv --with-amr --with-speex --with-speexdsp --enable-speexresampler --enable-speexdenoiser --with-opus --with-gsm --with-ffmpeg && make && sudo make install || exit 1

cd /vagrant/

while ps aux | grep -v grep | grep "telepresence.googlecode.com/svn/trunk/"
do
	sleep 5
done

cd telepresence
svn status | grep ^? | awk '{print $2}'  | xargs rm -rf
svn up
sed -i '1,/==/s/==/=/' autogen.sh
sed -i 's/tsk_thread_sleep/sleep/' source/main.cc
./autogen.sh && ./configure --with-doubango=/usr/local CXXFLAGS="$(grep include telepresence.vcproj  | grep tiny | head -1 | tr '\\' '/' | sed -e 's/;/ -I/g' -e 's#/branches/2.0/Doubango/#/#g' -e 's#.*thirdparties/win32/include##g' -e 's/-I&quot.*//g')"
make && sudo make install || exit 1
sudo make samples
