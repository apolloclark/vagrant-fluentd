#!/bin/bash -ex

# must be a sudoer user to run this
# login as the hadoop user
sudo -u hadoop -i << 'EOF'
  # start HDFS, Yarn, and HTTPFS
  start-dfs.sh
  start-yarn.sh
  hdfs --daemon start httpfs

  # get a list of running Java services
  ps -auxww | grep java | awk '{print $12, $2}' | cut -c 8- | head -n -1 | awk '{print $2, $1}'
EOF
