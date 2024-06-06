#!/bin/sh
echo "This is a script running every minute" >>/var/log/cron.log 2>&1
cd /usr/src/app || {
    echo "Failed to change directory to /usr/src/app" >>/var/log/cron.log 2>&1
    exit 1
}

./bin/rake rooms:delete_expired >>/var/log/cron.log 2>&1
echo "Finished rake task" >>/var/log/cron.log 2>&1
