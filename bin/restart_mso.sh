#!/bin/sh
kill `ps -ax | grep rails | grep 3010 | grep -oe "^[0-9]*"`
sleep 3
PWD=`pwd`
cd /home/wteuber/SD/mysageone_de/host_app
  bundle exec script/rails s -p 3010 &
cd $PWD
