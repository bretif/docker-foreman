#!/bin/bash

export APACHE_PID_FILE=/var/run/apache2/apache2.pid
export APACHE_RUN_DIR=/var/run/apache2
export APACHE_LOCK_DIR=/var/lock/apache2
/usr/sbin/apache2 -D 'FOREGROUND' -k start

