#!/bin/sh

# basic

BASE=`pwd`
DOWNLOADS=$BASE/downloads
SOURCES=$BASE/sources
BUILD=$BASE/build
CONF=$BUILD/conf
DAEMON=$BUILD/sbin/nginx
MODULES=()

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
fi

HTTPREDIS2_PATH=$HTTPREDIS2_SOURCE/`ls $HTTPREDIS2_SOURCE`
MODULES+=($HTTPREDIS2_PATH)

# hello-world

HELLOWORLD_PATH=$BASE/../nginx-hello-world-module
MODULES+=($HELLOWORLD_PATH)

# basic_c_lib_based_module

BASIC_C_LIB_BASED_MODULE_PATH=$BASE/../ngx_basic_c_lib_based_module
MODULES+=($BASIC_C_LIB_BASED_MODULE_PATH)

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

CONFIGURE=./configure
CONFIGURE="$CONFIGURE --with-ld-opt='-L/usr/local/lib'"
CONFIGURE="$CONFIGURE --with-cc-opt='-I/usr/local/include'"
for module in ${MODULES[@]}; do
  CONFIGURE="$CONFIGURE --add-module=$module"
done
CONFIGURE="$CONFIGURE --prefix=$BUILD"

echo $CONFIGURE

cd $NGINX_PATH && $CONFIGURE
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
