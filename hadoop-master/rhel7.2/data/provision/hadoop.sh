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

# configure Hadoop user env vars
cat << 'EOF' >> $HADOOP_HOME/.bashrc
export HADOOP_HOME=/opt/hadoop
export HADOOP_INSTALL=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export YARN_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export HADOOP_OPTS="$HADOOP_OPTS -Djava.library.path=$HADOOP_HOME/lib/native"
export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk
export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
EOF

source $HADOOP_HOME/.bashrc

# configure Java Home
cat << 'EOF' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk/
EOF

# configure core-site.xml
cat << 'EOF' > $HADOOP_HOME/etc/hadoop/core-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
<property>
  <name>fs.default.name</name>
    <value>hdfs://localhost:9000</value>
</property>
</configuration>
EOF

# configure hdfs-site.xml
cat << 'EOF' > $HADOOP_HOME/etc/hadoop/hdfs-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
<property>
 <name>dfs.replication</name>
 <value>1</value>
</property>

<property>
  <name>dfs.name.dir</name>
    <value>file:///opt/hadoop/hdfs/namenode</value>
</property>

<property>
  <name>dfs.data.dir</name>
    <value>file:///opt/hadoop/hdfs/datanode</value>
</property>
</configuration>
EOF

# configure mapred-site.xml
cat << 'EOF' > $HADOOP_HOME/etc/hadoop/mapred-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
 <property>
  <name>mapreduce.framework.name</name>
   <value>yarn</value>
 </property>
</configuration>
EOF

# configure yarn-site.xml
cat << 'EOF' > $HADOOP_HOME/etc/hadoop/yarn-site.xml
<?xml version="1.0" encoding="UTF-8"?>

<configuration>
 <property>
  <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
 </property>
</configuration>
EOF

# configure httpfs-site.xml
cat << 'EOF' > $HADOOP_HOME/etc/hadoop/httpfs-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<!--
  http://archive.cloudera.com/cdh5/cdh/5/hadoop/hadoop-hdfs-httpfs/httpfs-default.html
  https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/HttpAuthentication.html
  https://hadoop.apache.org/docs/current/hadoop-hdfs-httpfs/ServerSetup.html
-->
<configuration>
  <property>
    <name>hadoop.security.authorization</name>
    <value>false</value>
    <description>Is service-level authorization enabled?</description>
  </property>
</configuration>
EOF



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

# try to curl the HDFS UI
curl -sSL http://127.0.0.1:9870 > /dev/null

# get a list of running Java services
ps -aux | grep java | awk -v OFS='\t' '{print $12, $2}' | cut -c 8- | head -n -1 | awk '{print $2, $1}'

EOF
