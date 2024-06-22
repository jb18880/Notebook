#!/bin/bash
#please put the jdk package in the same folder with this script

#下载地址
#https://www.oracle.com/java/technologies/downloads/

wget https://download.oracle.com/java/22/latest/jdk-22_linux-x64_bin.tar.gz
tar xf jdk-8u333-linux-x64.tar.gz -C /usr/local/
ln -s /usr/local/jdk1.8.0_333/ /usr/local/jdk
cat > /etc/profile.d/jdk.sh <<EOF
export JAVA_HOME=/usr/local/jdk
export PATH=\$PATH:\$JAVA_HOME/bin
EOF
. /etc/profile.d/jdk.sh 
java -version
echo "jdk path = /usr/local/jdk"
