#!/bin/bash -ex

# increase max # of file descriptors
cat << EOF > /etc/security/limits.conf
root soft nofile 65536
root hard nofile 65536
* soft nofile 65536
* hard nofile 65536
EOF


# increase network parameters
cat << EOF > /etc/sysctl.conf
net.core.somaxconn = 1024
net.core.netdev_max_backlog = 5000
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_wmem = 4096 12582912 16777216
net.ipv4.tcp_rmem = 4096 12582912 16777216
net.ipv4.tcp_max_syn_backlog = 8096
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 10240 65535
EOF

# reload settings
sysctl -p > /dev/null

# install td-agent
# https://docs.fluentd.org/v1.0/articles/install-by-rpm
curl -sSL https://toolbelt.treasuredata.com/sh/install-redhat-td-agent3.sh | sh

# configure
\cp /vagrant/provision/fluentd/td-agent.conf /etc/td-agent/td-agent.conf

# test configuration
td-agent --dry-run -c /etc/td-agent/td-agent.conf

# enable fluentd auto-start
systemctl enable td-agent 2>&1
