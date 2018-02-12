#!/bin/bash -eux

# get the REDHAT variables
REDHAT_USER=${1:-}
if [[ -z "$REDHAT_USER" ]]; then
    echo "ERROR: Missing <REDHAT_USER>"
    echo "usage: $0 <REDHAT_USER> <REDHAT_PASS>"
    exit 1
fi

REDHAT_PASS=${2:-}
if [[ -z "$REDHAT_PASS" ]]; then
    echo "ERROR: Missing <REDHAT_PASS>"
    echo "usage: $0 <REDHAT_USER>  <REDHAT_PASS>"
    exit 1
fi

echo "REDHAT_USER = $REDHAT_USER";
echo "REDHAT_PASS = $REDHAT_PASS";



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

# register with Redhat
subscription-manager register --username "$REDHAT_USER" --password "$REDHAT_PASS"

# register with self-serve virtual subscription
subscription-manager subscribe --pool=8a85f98c615810120161582177020497

# apply security updates
yum update-minimal --security -y -e 0

# install basic tools
yum install -y -q -e 0 nano git net-tools policycoreutils-python





# install td-agent
# https://docs.fluentd.org/v1.0/articles/install-by-rpm
curl -sSL https://toolbelt.treasuredata.com/sh/install-redhat-td-agent3.sh | sh

# configure
cp /vagrant/provision/fluentd/td-agent.conf /etc/td-agent/td-agent.conf

# test configuration
td-agent --dry-run -c /etc/td-agent/td-agent.conf

# start fluentd
systemctl start td-agent

# check fluentd status
systemctl status td-agent

# enable fluentd auto-start
systemctl enable td-agent 2>&1

# test fluentd
sleep 30s
curl -sSL -X POST -d 'json={"json":"message"}' http://localhost:9880/debug.test
grep -F 'debug.test: {"json":"message"}' /var/log/td-agent/td-agent.log





# install rsyslog
yum install -y -q -e 0 rsyslog.x86_64

# configure selinux
semanage port -a -t syslogd_port_t -p tcp 5140
semanage port -l | grep -F "syslogd_port_t" | grep 5140

# configure rsyslog
cp /vagrant/provision/rsyslogd/rsyslog.conf /etc/rsyslog.conf

# verify configuration
rsyslogd -N1 2>&1

# start rsyslog
systemctl restart rsyslog

# check status
systemctl status rsyslog

# enable auto-start
systemctl enable rsyslog 2>&1

# test rsyslog
logger TroubleshootingTest
grep -F "TroubleshootingTest" /var/log/messages
sleep 30s
grep -F "TroubleshootingTest" /var/log/td-agent/td-agent.log
