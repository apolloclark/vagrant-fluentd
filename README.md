# fluentd-vagrant

Project to deploy a Redhat based fluentd collector, from rsyslog, to Hadoop, running on
multiple different Linux and Windows hosts.

## Deploy - fluentd-only master

```shell
git clone https://github.com/apolloclark/vagrant-fluentd

# configure Redhat subscription variables
REDHAT_USER=''
REDHAT_PASS=''

# launch fluentd master collector
cd ./vagrant-fluentd/fluentd-master/rhel7.2
vagrant up
```
<br/><br/><br/>



## OR
<br/><br/><br/>



## Deploy - fluentd + hadoop master

```shell
git clone https://github.com/apolloclark/vagrant-fluentd

# configure Redhat subscription variables
REDHAT_USER=''
REDHAT_PASS=''

# launch fluentd master collector
cd ./vagrant-fluentd/hadoop-master/rhel7.2
vagrant up

# open browser - http://127.0.0.1:9870/explorer.html#/logs
```
<br/><br/><br/>



## Logs

### fluentd

```shell
# config file
nano /etc/td-agent/td-agent.conf

# update config
\cp /vagrant/provision/fluentd/td-agent.conf /etc/td-agent/td-agent.conf

# verify config
td-agent --dry-run -c /etc/td-agent/td-agent.conf

# check version, 1.0.2
td-agent --version

# check package version, 3.1.1
yum info td-agent | grep "Version"

# check status
systemctl status td-agent

# stop
systemctl stop td-agent

# restart
systemctl restart td-agent

# log file
nano /var/log/td-agent/td-agent.log

# clear logs
systemctl stop td-agent && echo "" > /var/log/td-agent/td-agent.log && systemctl restart td-agent
watch -n 1 "tail -n 48 /var/log/td-agent/td-agent.log"

# check if selinux is blocking
grep -F "td-agent" /var/log/audit/audit.log | grep -F "success=no"

# configure selinux
semanage port -a -t syslogd_port_t -p tcp 5140
semanage port -l | grep -F "syslogd_port_t" | grep 5140
```



### rsyslogd

```shell
# config file
nano /etc/rsyslog.conf

# update config
\cp /vagrant/provision/rsyslogd/rsyslog.conf /etc/rsyslog.conf && systemctl restart rsyslog

# verify config
rsyslogd -N1

# check verstion, Linux = 8.24.0, Windows = 4.3.0.255
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



### hadoop

```shell

# startup
/vagrant/provision/hadoop/start_hadoop.sh

# get a list of running Java services
ps -aux | grep java | awk '{print $12, $2}' | cut -c 8- | head -n -1 | awk '{print $2, $1}'

# check if selinux is blocking
grep -F "java" /var/log/audit/audit.log | grep -F "success=no"

# configure selinux
semanage port -a -t http_port_t -p tcp 9870
semanage port -l | grep -F "http_port_t" | grep 9870

# try to curl the HDFS UI
curl -sSL http://127.0.0.1:9870 > /dev/null



# name node folder
/opt/hadoop/hdfs/namenode

# data node folder
/opt/hadoop/hdfs/datanod

# view data node
http://127.0.0.1:9870

# view data node folders
http://127.0.0.1:9870/explorer.html

# restart nodes
stop-dfs.sh && start-dfs.sh

# restart httpfs
hdfs --daemon stop httpfs && hdfs --daemon stop httpfs



```
