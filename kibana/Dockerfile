FROM centos:centos7

#upgrading system and install required utilities
RUN yum -y install epel-release; \
    yum -y install wget openssh-server supervisor httpd openssh-client openssl which java-1.8.0-openjdk-headless; \
    mkdir -p /var/run/sshd; \
    mkdir -p /var/log/supervisor;

#download and install kibana
ENV KIBANA=kibana-6.2.3-x86_64
RUN wget https://artifacts.elastic.co/downloads/kibana/${KIBANA}.rpm -O /tmp/${KIBANA}.rpm; \
  yum -y install /tmp/${KIBANA}.rpm;

#clean all the temporary files and yum cache
RUN rm -rf /tmp/${KIBANA}.rpm; \
yum clean all;

#entrypoint
ADD start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

#expose ports
EXPOSE 80 5601 9200 9300 9092 9111

#expose volume
#VOLUME /var/lib/elasticsearch

#start the init
CMD [ "/usr/share/kibana/bin/kibana" ]