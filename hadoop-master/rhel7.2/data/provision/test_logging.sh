#!/bin/bash -ex


# startup Hadoop
/vagrant/provision/hadoop/start_hadoop.sh

# try to curl the HDFS UI
sleep 30s
curl -sSL http://127.0.0.1:9870 > /dev/null



# start td-agent
systemctl start td-agent

# check fluentd status
systemctl status td-agent

# test http -> file
sleep 30s
curl -sSL -X POST -d 'json={"json":"message"}' http://localhost:9880/debug.test
grep -F 'debug.test: {"json":"message"}' /var/log/td-agent/td-agent.log



# restart rsyslog
systemctl restart rsyslog

# check status
systemctl status rsyslog

# test rsyslog -> hdfs
logger TroubleshootingTest
grep -F "TroubleshootingTest" /var/log/messages
sleep 30s
curl -sL http://127.0.0.1:9870/webhdfs/v1/logs?op=LISTSTATUS | grep -F 'access.log'
