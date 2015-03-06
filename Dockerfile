FROM phusion/baseimage:0.9.16
MAINTAINER Bertrand Retif <bertrand@sudokeys.com>

### ports
# puppet (via apache)
EXPOSE 8140

# foreman-proxy
EXPOSE 8443

# foreman (via apache)
EXPOSE 443
EXPOSE 80

ENV DEBIAN_FRONTEND noninteractive

### install prereqs and other userful bits
RUN apt-get -y update   && \
    apt-get -y install  curl \
                        wget \
                        vim \
                        git

### set up puppet repos
WORKDIR /tmp
RUN wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
RUN dpkg -i puppetlabs-release-trusty.deb

### install foreman installer
RUN echo "deb http://deb.theforeman.org/ trusty 1.7" > /etc/apt/sources.list.d/foreman.list
RUN echo "deb http://deb.theforeman.org/ plugins 1.7" >> /etc/apt/sources.list.d/foreman.list
RUN wget -q http://deb.theforeman.org/pubkey.gpg -O- | apt-key add -
RUN apt-get -y update && apt-get -y install foreman-installer

#Deploy scripts
COPY scripts/deploy-foreman.sh /etc/my_init.d/10_deploy-foreman.sh
RUN chmod +x /etc/my_init.d/10_deploy-foreman.sh

# Start tftpd
RUN mkdir /etc/service/tftpd
COPY scripts/start_tftpd.sh /etc/service/tftpd/run
RUN chmod +x /etc/service/tftpd/run

# Start foreman_proxy
RUN mkdir /etc/service/foreman-proxy
COPY scripts/start_foreman-proxy.sh /etc/service/foreman-proxy/run
RUN chmod +x /etc/service/foreman-proxy/run

# Start puppet agent
#RUN mkdir /etc/service/puppet-agent
#COPY scripts/start_puppet_agent.sh /etc/service/puppet-agent/run
#RUN chmod +x /etc/service/puppet-agent/run

# Start apache
RUN mkdir /etc/service/apache
COPY scripts/start_apache.sh /etc/service/apache/run
RUN chmod +x /etc/service/apache/run

VOLUME [ "/etc/foreman", "/etc/foreman-proxy", "/etc/puppet", "/var/lib/puppet/ssl" ]

# Baseimage init process
ENTRYPOINT ["/sbin/my_init"]

