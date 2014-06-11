OpenTelepresence on Docker
==========================

This is a docker file and a bootstrap file that will build and install OpenTelepresence from https://code.google.com/p/telepresence/.

It works as of 2014-06-11 and uses the latest version of libyuv, ffmpeg 1.2, doubango, and telepresence based off of the rest of the requirements being packages in Ubuntu Trusty Tahr.

Run:

```bash
git clone https://github.com/ClashTheBunny/telepresence-vagrant.git -b docker
cd telepresence-vagrant
docker build -t "clashthebunny/telepresence-build" .
docker run -v /telepresence/ -v /usr/share/nginx/html/ --name telepresence-source busybox true
docker run --rm -i -t --volumes-from telepresence-source --name telepresence clashthebunny/telepresence-build:latest
```

and you should end up with a fully built telepresence in the container in /usr/local/sbin/.

Run ./telepresence from that directory and you should be running the software:
docker run --rm -i -t --volumes-from telepresence-source --name telepresence clashthebunny/telepresence-build:latest "cd /usr/local/sbin; ./telepresence"

Run NGINX on the /usr/share/nginx/html/ directory and you're serving up the frontend:
docker run --rm -i -t --volumes-from telepresence-source --name telepresence-nginx crosbymichael/nginx -c /etc/nginx/nginx.conf
