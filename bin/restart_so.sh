#!/bin/sh
kill `ps -ax | grep rails | grep 3030 | grep -oe "^[0-9]*"`
sleep 3
PWD=`pwd`
cd /home/wteuber/SD/einfach_buero/host_app
  RAILS_RELATIVE_URL_ROOT=/buchhaltung rails s -p 3030 &
cd $PWD
