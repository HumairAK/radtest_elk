FROM centos:centos7

#upgrading system and install required utilities
RUN yum -y install epel-release; \
    yum -y install wget openssh-server httpd openssh-client openssl which java-1.8.0-openjdk-headless; \
    mkdir -p /var/run/sshd; \
    mkdir -p /var/log/supervisor;

RUN mkdir -p /tmp/access_log;

#download and install logstash
ENV LS=logstash-6.2.3
RUN wget https://artifacts.elastic.co/downloads/logstash/${LS}.rpm -O /tmp/${LS}.rpm; \
  yum -y install /tmp/${LS}.rpm;

#clean all the temporary files and yum cache
RUN rm -rf /tmp/${LS}.rpm; \
yum clean all;

#add config
ADD logstash.conf /etc/logstash/conf.d/
ADD logstash.yml /etc/logstash/
ADD temp.txt /tmp/access_log
ADD start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

#start the init
CMD [ "/usr/local/bin/start.sh" ]