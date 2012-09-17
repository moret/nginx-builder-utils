#!/bin/sh

NGINX_PORT=9911
NGINX_VERSION=nginx-1.0.10
NGINX_BASEPATH=$WORKSPACE/../nginx_source
NGINX_PROJECTPATH=$NGINX_BASEPATH/$JOB_NAME-build
NGINX_PATH=$NGINX_PROJECTPATH/$NGINX_VERSION
NGINX_EXEC=$NGINX_PATH/objs/nginx

export NGINX_EXEC;
export NGINX_PORT;
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/lib;

mkdir -p $NGINX_PROJECTPATH;


if [ ! -f $NGINX_BASEPATH/$NGINX_VERSION.tar.gz ]; then 
  wget -c http://nginx.org/download/$NGINX_VERSION.tar.gz -O $NGINX_BASEPATH/$NGINX_VERSION.tar.gz;
fi

if [ ! -d $NGINX_PATH ]; then
  tar xzf $NGINX_BASEPATH/$NGINX_VERSION.tar.gz -C $NGINX_PROJECTPATH;
fi

if [ ! -f $NGINX_PATH/Makefile ]; then
  cd $NGINX_PATH && ./configure \
    --add-module=$WORKSPACE \
    --with-cc-opt='-I /opt/include' \
    --with-ld-opt='-L /opt/lib' \
    --prefix=$NGINX_PATH;

  if [ ! $? -eq 0 ]; then
    rm -f $NGINX_PATH/Makefile;
  fi
fi

if [ -d $NGINX_PATH/objs/addon ]; then
  find $NGINX_PATH/objs/addon -name "*.o" -delete;
fi

if [ ! -d $NGINX_PATH/logs ]; then
  mkdir $NGINX_PATH/logs;
fi

cd $NGINX_PATH && make;

rvm ruby-1.9.2-p290@nginx-modules --create;
cd $WORKSPACE/test && rvm ruby-1.9.2-p290@nginx-modules exec "bundle install";
cd $WORKSPACE/test && rvm ruby-1.9.2-p290@nginx-modules exec "rspec --format documentation --color .";
