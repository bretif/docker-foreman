docker-foreman
==============

This Dockerfile create a working instance of foreman. foreman, foreman-proxy and tftp server are running inside the container.
The container do not run the DB.

A specific hostname should be passed as the default hostname won't match facter's fqdn. Otherwise, this image will start you off with the Foreman Installer defaults and install away. For most purposes, the defaults will do. If you want something other than the defaults, use an answers file. An answers file can be provided by running the image with `docker run -it ... -v /path/to/answers:/etc/foreman/foreman-installer-answers.yaml inhumantsar/foreman /usr/sbin/foreman-installer -i`

*TL;DR: Love the defaults or else use an answers file.* 

Some things you'll probably want to think about changing:
  - `foreman-proxy / daemon`: Even if you don't set this to false, the start script will attempt to itself anyway.

Puppet is installed from the latest stable versions from the Puppet Labs apt repo. Should install 3.7.3 at time of writing. The [Docker Foreman plugin](https://github.com/theforeman/foreman-docker) is installed post-setup before the first launch.


# Run commands

`docker run -it -h foreman.example.com -p 443:443 -p 80:80 -p 8443:8443 -p 8140:8140 -p 69:69/udp bretif/foreman`

## Optional volumes

 - `-v /path/to/answers.yaml:/etc/foreman/foreman-installer-answers.yaml`
 - `-v /path/to/etc/foreman:/etc/foreman`
 - `-v /path/to/etc/foreman-proxy:/etc/foreman-proxy`
 - `-v /path/to/etc/puppet:/etc/puppet`

# Tags Available
    
 - `latest`, `1.7` -- latest stable
 - `1.6` -- available but not supported

## Upgrade
    
All your important data must be on the host or in volumes. In this example we use data stored on host.

Step 1 - Stop container
    docker stop foremanOLD

Step 2 - Start new container

    docker run -d --name foremanNEW -h foreman.example.com \
        -v /srv/foreman/etc/foreman-installer-answers.yaml:/srv/foreman/etc/foreman-installer-answers.yaml \
        -v /srv/foreman/etc:/etc/foreman \
        -v /srv/foreman-proxy/etc:/etc/foreman-proxy \
        -v /srv/puppet/etc:/etc/puppet \
        -v /srv/puppet/ssl:/var/lib/puppet/ssl \
        -p 443:443 -p 80:80 -p 8443:8443 -p 8140:8140 -p 69:69/udp bretif/foreman

Step 3 - Follow foreman installation 'docker logs', and when completed, connect to the new container and change database settings in '/etc/forman/database.yml'

    docker exec -ti foremanNEW bash

    adapter: postgresql
    host: hostname
    database: foreman
    username: foreman
    password: "XXXXXX"

Step 4 - restart container

    docker restart foremanNEW

Step 5 - Apply db upgrade in container

    docker exec -ti foremanNEW bash

    foreman-rake db:migrate
    foreman-rake db:seed
    

Step 6 - You can stop and disable old container
    docker rm foremanOLD

# BUGS #

There is an error during forman instalaltion about tftp. I do not know how to fix it. However I do not have any issues with the container....
