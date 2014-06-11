#!/bin/bash

cd /telepresence/
[ ! -d ffmpeg ] && git clone -b release/1.2 git://source.ffmpeg.org/ffmpeg.git ffmpeg &
[ ! -d doubango ] && ( while ps aux | grep -v grep | grep -q "source.ffmpeg.org/ffmpeg.git"; do sleep 5; done; svn checkout http://doubango.googlecode.com/svn/branches/2.0/doubango doubango ) &
[ ! -d telepresence ] && ( while ps aux | grep -v grep | grep -q "doubango.googlecode.com/svn/branches/2.0/doubango"; do sleep 5; done; svn checkout http://telepresence.googlecode.com/svn/trunk/ telepresence ) &

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

cd /telepresence/

[ -d libyuv ] || mkdir -p libyuv 
cd libyuv
[ -f gclient ] || {
    svn co http://src.chromium.org/svn/trunk/tools/depot_tools .
    ./gclient config http://libyuv.googlecode.com/svn/trunkr
}
./gclient sync && cd trunk
CXXFLAGS="-O3 -Wall -pedantic -fomit-frame-pointer -fPIC" make -f linux.mk

cp libyuv.a /usr/local/lib
mkdir --parents /usr/local/include/libyuv/libyuv
cp -rf include/libyuv.h /usr/local/include/libyuv
cp -rf include/libyuv/*.h /usr/local/include/libyuv/libyuv
ln -s /usr/local/include/libyuv/libyuv /usr/local/include/libyuv/libyuv/

while ps aux | grep -v grep | grep -e "source.ffmpeg.org/ffmpeg.git"
do
	sleep 5
done

cd /telepresence/

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

cd /telepresence/

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

cd /telepresence/

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
