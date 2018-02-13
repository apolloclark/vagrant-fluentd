#!/bin/bash -ex

# install Hadoop

# https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SingleCluster.html
# https://medium.com/@anmol.ganju81/configuring-hadoop-on-linux-rhel-7-cent-os-fedora-23-machine-3dc8caf57ec9

# search for potential JDK 
yum search jdk

# install OpenJDK 1.8.0
yum install -y java-1.8.0-openjdk.x86_64

# check java version
java -version



# create Hadoop user
useradd -d /opt/hadoop hadoop
echo hadoop:hadoop | chpasswd

# save Hadoop pathway
export HADOOP_HOME=/opt/hadoop

# generate SSH key
ssh-keygen -f id_rsa -t rsa -N ''
mkdir $HADOOP_HOME/.ssh
cat ./id_rsa.pub > $HADOOP_HOME/.ssh/authorized_keys
chmod 0600 $HADOOP_HOME/.ssh/authorized_keys
mv id_rsa $HADOOP_HOME/.ssh/
mv id_rsa.pub $HADOOP_HOME/.ssh/
chown -R hadoop:hadoop $HADOOP_HOME/.ssh



# download Hadoop - https://hadoop.apache.org/releases.html
cd /opt

wget -q http://mirrors.advancedhosters.com/apache/hadoop/common/hadoop-3.0.0/hadoop-3.0.0.tar.gz

tar xzf hadoop-3.0.0.tar.gz
rm -f hadoop-3.0.0.tar.gz
mv /opt/hadoop-3.0.0/* /opt/hadoop/
rm -rf /opt/hadoop-3.0.0
chown -R hadoop:hadoop /opt/hadoop

# configure Hadoop
\cp /vagrant/provision/hadoop/bashrc $HADOOP_HOME/.bashrc
\cp /vagrant/provision/hadoop/hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh
\cp /vagrant/provision/hadoop/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
\cp /vagrant/provision/hadoop/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
\cp /vagrant/provision/hadoop/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
\cp /vagrant/provision/hadoop/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml
\cp /vagrant/provision/hadoop/httpfs-site.xml $HADOOP_HOME/etc/hadoop/httpfs-site.xml



# login as the hadoop user
sudo -u hadoop -i << 'EOF'
  # make dirs
  mkdir -p /opt/hadoop/logs
  mkdir -p /opt/hadoop/temp

  # format node name
  hdfs namenode -format -nonInteractive 2>&1

  # start HDFS, Yarn, and HTTPFS
  start-dfs.sh
  start-yarn.sh
  hdfs --daemon start httpfs

  # create folders, set permissions
  hdfs dfs -mkdir /logs
  hdfs dfs -put LICENSE.txt /logs
  hdfs dfs -setfacl -m group::rwx /logs
  hdfs dfs -setfacl -m other::rwx /logs
  hdfs dfs -getfacl /logs
EOF
