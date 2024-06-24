#!/bin/sh
echo "[$(date)]" >>/var/log/cron.log 2>&1
echo "This is a script running every minute" >>/var/log/cron.log 2>&1
cd /usr/src/app || {
    echo "Failed to change directory to /usr/src/app" >>/var/log/cron.log 2>&1
    exit 1
}

./bin/rake rooms:delete_expired >>/var/log/cron.log 2>&1
echo "Finished rake task delete rooms" >>/var/log/cron.log 2>&1
./bin/rake users:block_inactive >>/var/log/cron.log 2>&1
echo "Finished rake task block users" >>/var/log/cron.log 2>&1
