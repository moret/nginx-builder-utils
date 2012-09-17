#!/bin/sh

BASE=`pwd`
DOWNLOADS=$BASE/downloads
SOURCES=$BASE/sources
BUILD=$BASE/build

if [ ! -d $DOWNLOADS ]; then
  mkdir $DOWNLOADS
fi

rm -rf $SOURCES
mkdir $SOURCES
rm -rf $BUILD
mkdir $SOURCES


HTTPREDIS2_VERSION=v0.09
HTTPREDIS2_REMOTE=https://github.com/agentzh/redis2-nginx-module/zipball/v0.09
HTTPREDIS2_TAR=$DOWNLOADS/$HTTPREDIS2_VERSION.tar.gz
HTTPREDIS2_SOURCE=$SOURCES/redis2-nginx-module

if [ ! -f $HTTPREDIS2_TAR ]; then
  wget $HTTPREDIS2_REMOTE -O $HTTPREDIS2_TAR
fi

mkdir $HTTPREDIS2_SOURCE
tar xvzf $HTTPREDIS2_TAR -C $HTTPREDIS2_SOURCE
HTTPREDIS2_PATH=$HTTPREDIS2_SOURCE/`ls $HTTPREDIS2_SOURCE`


NGINX_VERSION=nginx-1.3.6
NGINX_REMOTE=http://nginx.org/download/$NGINX_VERSION.tar.gz
NGINX_TAR=$DOWNLOADS/$NGINX_VERSION.tar.gz
NGINX_PATH=$SOURCES/$NGINX_VERSION

if [ ! -f $NGINX_TAR ]; then
  wget $NGINX_REMOTE -O $NGINX_TAR
fi

tar xvzf $NGINX_TAR -C $SOURCES

cd $NGINX_PATH && ./configure \
  --with-ld-opt='-L/usr/local/lib' \
  --with-cc-opt='-I/usr/local/include' \
  --add-module=$HTTPREDIS2_PATH \
  --prefix=$BUILD

cd $NGINX_PATH && make -j2
cd $NGINX_PATH && make install
