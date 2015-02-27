#!/bin/bash

# no foreman install log? run forman installer
if [[ ${INSTALL} = "True" ]] && [[ ! -f /etc/foreman/docker.install.ok ]] ; then 
  if [ -f /etc/foreman/foreman-installer-answers.yaml ]; then
    echo 'Answers found, starting quiet foreman installer'
    foreman-installer -v
    if [ $? -ne 0 ]; then exit $?; fi
  else
    echo 'Starting interactive installer'
    foreman-installer -iv
    if [ $? -ne 0 ]; then exit $?; fi
  fi
fi

# install docker plugin for foreman
if [ ! `dpkg -l | grep -E '^ii' | grep ruby-foreman-docker` ]; then
  apt-get install -y ruby-foreman-docker
fi

# Install foreman-vmware
if [ ! `dpkg -l | grep -E '^ii' | grep ruby-foreman-vmware` ]; then
  apt-get install -y ruby-foreman-vmware
fi
# correct for foreman-installer bug
# see: http://projects.theforeman.org/issues/8915
if [ -f /etc/puppet/puppet.conf ]; then
  sed -i '/trusted_node_data/d' /etc/puppet/puppet.conf
fi

# normal startup
/usr/local/bin/supervisord --nodaemon -c /etc/supervisord.conf
