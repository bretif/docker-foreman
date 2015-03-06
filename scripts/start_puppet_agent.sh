#!/bin/bash

if [[ ! -d /var/run/puppet/ ]]; then
    mkdir /var/run/puppet/
fi

/usr/bin/puppet agent --no-daemonize --verbose

