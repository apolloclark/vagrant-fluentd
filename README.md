# fluentd-vagrant

Project to deploy a Redhat based fluentd collector, from rsyslog, running on
multiple different Linux and Windows hosts.

## Deploy

```shell
git clone https://github.com/apolloclark/vagrant-fluentd

# configure Redhat subscription variables
REDHAT_USER=''
REDHAT_PASS=''

# launch master collector
cd ./vagrant-fluentd/fluentd-master-rhel6.9
vagrant up
```


## Logs
```shell

# fluentd
nano /var/log/td-agent/td-agent.log

watch -n 1 "tail -n 48 /var/log/td-agent/td-agent.log"

grep -F "td-agent" /var/log/audit/audit.log | grep -F "success=no"



# rsyslogd

## check for errors
cat /var/log/messages | grep rsyslogd

## check if SELinux is blocking rsyslog
grep -F "/usr/sbin/rsyslogd" /var/log/audit/audit.log | grep -F "success=no"

## test logging
logger testmessage5
grep -F "testmessage5" /var/log/messages
grep -F "testmessage5" /var/log/td-agent/td-agent.log
```