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

#download and install logstash
ENV LS=logstash-6.2.3
RUN wget https://artifacts.elastic.co/downloads/logstash/${LS}.rpm -O /tmp/${LS}.rpm; \
  yum -y install /tmp/${LS}.rpm;

#download and install kibana
ENV KIBANA=kibana-6.2.3-x86_64
RUN wget https://artifacts.elastic.co/downloads/kibana/${KIBANA}.rpm -O /tmp/${KIBANA}.rpm; \
  yum -y install /tmp/${KIBANA}.rpm;

#clean all the temporary files and yum cache
RUN rm -rf /tmp/${ES}.rpm; \
rm -rf /tmp/${LS}.rpm; \
rm -rf /tmp/${KIBANA}.rpm; \
yum clean all;

#add config
ADD supervisor/ /etc/
ADD logstash/ /usr/share/logstash/config/
ADD elasticsearch/ /usr/share/elasticsearch/config/

#entrypoint
ADD start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

#expose ports
#kibana:5601, elasticsearch:9200/9300, kafka:9092
EXPOSE 80 5601 9200 9300 9092 9111

#expose volume
#VOLUME /var/lib/elasticsearch

#start the init
CMD [ "/usr/local/bin/start.sh" ]