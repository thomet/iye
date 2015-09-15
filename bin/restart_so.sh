#!/bin/sh
kill `ps -ax | grep puma | grep 3032 | tr -d " " | grep -oe "^[0-9]*"`
sleep 3
PWD=`pwd`
cd /home/wteuber/SD/sage_one_advanced/host_app
  bundle exec rake i18n:js:export
  bundle exec puma &
cd $PWD
