#!/bin/bash -ex

# install rsyslog
yum install -y -q -e 0 rsyslog.x86_64

# configure selinux
semanage port -a -t syslogd_port_t -p tcp 5140
semanage port -l | grep -F "syslogd_port_t" | grep 5140

# configure rsyslog
\cp /vagrant/provision/rsyslogd/rsyslog.conf /etc/rsyslog.conf

# verify configuration
rsyslogd -N1 2>&1

# enable auto-start
systemctl enable rsyslog 2>&1
