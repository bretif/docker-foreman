#!/bin/bash

# no foreman install file? run forman installer
if [[ ! -f /.docker.install.ok ]] ; then 
  if [ -f /etc/foreman/foreman-installer-answers.yaml ]; then
    echo 'Answers found, starting quiet foreman installer'
    export HOME=/root
    foreman-installer -v
    pkill -9 apache
    touch /.docker.install.ok
#    if [ $? -ne 0 ]; then exit $?; fi
  else
    echo 'Starting interactive installer'
    foreman-installer -iv
    pkill -9 apache
    touch /etc/foreman/docker.install.ok
#    if [ $? -ne 0 ]; then exit $?; fi
  fi
fi

# install docker plugin for foreman
if [ ! `dpkg -l | grep -E '^ii' | grep ruby-foreman-docker` ]; then
  apt-get install -y ruby-foreman-docker
fi

# Install foreman-vmware
if [ ! `dpkg -l | grep -E '^ii' | grep foreman-vmware` ]; then
  apt-get install -y foreman-vmware
fi
# correct for foreman-installer bug
# see: http://projects.theforeman.org/issues/8915
if [ -f /etc/puppet/puppet.conf ]; then
  sed -i '/trusted_node_data/d' /etc/puppet/puppet.conf
fi

