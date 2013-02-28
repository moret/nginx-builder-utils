#!/bin/sh

# basic

BASE=`pwd`
DOWNLOADS=$BASE/downloads
SOURCES=$BASE/sources
BUILD=$BASE/build
CONF=$BUILD/conf
DAEMON=$BUILD/sbin/nginx

if [ -f $DAEMON ]; then
  echo 'will try to stop nginx, this will require sudo access'
  sudo $DAEMON -s stop
fi

mkdir -p $DOWNLOADS
mkdir -p $SOURCES
mkdir -p $BUILD

# httpredis2

HTTPREDIS2_VERSION=v0.09
HTTPREDIS2_REMOTE=https://github.com/agentzh/redis2-nginx-module/zipball/v0.09
HTTPREDIS2_TAR=$DOWNLOADS/$HTTPREDIS2_VERSION.tar.gz
HTTPREDIS2_SOURCE=$SOURCES/redis2-nginx-module

if [ ! -f $HTTPREDIS2_TAR ]; then
  wget $HTTPREDIS2_REMOTE -O $HTTPREDIS2_TAR
fi

if [ ! -d $HTTPREDIS2_SOURCE ]; then
  mkdir $HTTPREDIS2_SOURCE
  tar xvzf $HTTPREDIS2_TAR -C $HTTPREDIS2_SOURCE
  HTTPREDIS2_PATH=$HTTPREDIS2_SOURCE/`ls $HTTPREDIS2_SOURCE`
fi

# hello-world

HELLOWORLD_PATH=$BASE/../nginx-hello-world-module

# downloads

NGINX_VERSION=nginx-1.3.6
NGINX_REMOTE=http://nginx.org/download/$NGINX_VERSION.tar.gz
NGINX_TAR=$DOWNLOADS/$NGINX_VERSION.tar.gz
NGINX_PATH=$SOURCES/$NGINX_VERSION

if [ ! -f $NGINX_TAR ]; then
  wget $NGINX_REMOTE -O $NGINX_TAR
fi

# open and build

if [ ! -d $NGINX_PATH ]; then
  tar xvzf $NGINX_TAR -C $SOURCES
fi

cd $NGINX_PATH && ./configure \
  --with-ld-opt='-L/usr/local/lib' \
  --with-cc-opt='-I/usr/local/include' \
  --add-module=$HTTPREDIS2_PATH \
  --add-module=$HELLOWORLD_PATH \
  --prefix=$BUILD

cd $NGINX_PATH && make -j2
cd $NGINX_PATH && make install

cd $BASE

if [ -f $BASE/nginx.conf ]; then
 rm $CONF/nginx.conf
 ln -s $BASE/nginx.conf $CONF/nginx.conf
fi

if [ -f $DAEMON ]; then
  echo 'will try to start nginx on port 80, this will require sudo access'
  sudo $DAEMON
fi
