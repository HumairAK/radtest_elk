FROM centos:centos7

#upgrading system and install required utilities
RUN yum -y install epel-release; \
    yum -y install wget openssh-server supervisor httpd openssh-client openssl which java-1.8.0-openjdk-headless; \
    mkdir -p /var/run/sshd; \
    mkdir -p /var/log/supervisor;

#download and install elasticsearch
ENV ES=elasticsearch-6.2.3
RUN wget https://artifacts.elastic.co/downloads/elasticsearch/${ES}.rpm -O /tmp/${ES}.rpm; \
  yum -y install /tmp/${ES}.rpm;

#clean all the temporary files and yum cache
RUN rm -rf /tmp/${ES}.rpm; \
yum clean all;

#add config
ADD elasticsearch.yml /etc/elasticsearch/elasticsearch.yml

#expose ports
EXPOSE 9200 9300

#expose volume
VOLUME /var/lib/elasticsearch

USER elasticsearch

#start the init
CMD [ "/usr/share/elasticsearch/bin/elasticsearch" ]