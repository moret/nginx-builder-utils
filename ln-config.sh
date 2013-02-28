#!/bin/sh

rm build/conf/nginx.conf
ln -s $1 build/conf/nginx.conf
