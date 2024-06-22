
#https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.7/bin/apache-tomcat-10.1.7.tar.gz



tar xf apache-tomcat-9.0.64.tar.gz -C /usr/local/
ln -s /usr/local/apache-tomcat-9.0.64/ /usr/local/tomcat
cat > /etc/profile.d/tomcat.sh << EOF
PATH=/usr/local/tomcat/bin:\$PATH
EOF
. /etc/profile.d/tomcat.sh
catalina.sh start
