# fluentd-vagrant

Project to deploy a Redhat based fluentd collector, from rsyslog, running on
multiple different Linux and Windows hosts.

## Deploy - fluentd master

```shell
git clone https://github.com/apolloclark/vagrant-fluentd

# configure Redhat subscription variables
REDHAT_USER=''
REDHAT_PASS=''

# launch fluentd master collector
cd ./vagrant-fluentd/fluentd-master/rhel7.2
vagrant up
```

## Deploy - hadoop master

```shell
git clone https://github.com/apolloclark/vagrant-fluentd

# configure Redhat subscription variables
REDHAT_USER=''
REDHAT_PASS=''

# launch fluentd master collector
cd ./vagrant-fluentd/hadoop-master/rhel7.2
vagrant up

# open browser - http://127.0.0.1:9870
```


## Logs

### fluentd

```shell
# config
nano /etc/td-agent/td-agent.conf

# verify config
td-agent --dry-run -c /etc/td-agent/td-agent.conf

# check version
td-agent --version

# check package version
yum info td-agent | grep "Version"

# check status
systemctl status td-agent

# restart
systemctl restart td-agent

# logs
nano /var/log/td-agent/td-agent.log
watch -n 1 "tail -n 48 /var/log/td-agent/td-agent.log"

# check if selinux is blocking
grep -F "td-agent" /var/log/audit/audit.log | grep -F "success=no"

# configure selinux
semanage port -a -t syslogd_port_t -p tcp 5140
semanage port -l | grep -F "syslogd_port_t" | grep 5140
```



### rsyslogd

```shell
# config
nano /etc/rsyslog.conf

# verify config
rsyslogd -N1

# check verstion
rsyslogd -version | head -n 1

# check package version
yum info rsyslog | grep "Version"

# check status
systemctl status rsyslog

# restart
systemctl restart rsyslog

# check for errors
cat /var/log/messages | grep rsyslogd

# check if SELinux is blocking
grep -F "/usr/sbin/rsyslogd" /var/log/audit/audit.log | grep -F "success=no"

# configure selinux
semanage port -a -t syslogd_port_t -p tcp 5140
semanage port -l | grep -F "syslogd_port_t" | grep 5140

# test logging
logger testmessage5
grep -F "testmessage5" /var/log/messages
sleep 30s
grep -F "testmessage5" /var/log/td-agent/td-agent.log
```