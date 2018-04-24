FROM centos:centos7

RUN mkdir -p /tmp/access_log;

# Install Java and the "which" command, which is needed by Logstash's shell
# scripts.
RUN yum install -y java-1.8.0-openjdk-headless unzip which && \
    yum clean all

# Provide a non-root user to run the process.
RUN groupadd --gid 1000 logstash && \
    adduser --uid 1000 --gid 1000 \
      --home-dir /usr/share/logstash --no-create-home \
      logstash

# Add Logstash itself.
ENV URL_ROOT https://artifacts.elastic.co/downloads/logstash
ENV TARBALL logstash-6.2.4
RUN curl -Lo - ${URL_ROOT}/${TARBALL}.tar.gz | \
    tar zxf - -C /usr/share

RUN mv /usr/share/${TARBALL} /usr/share/logstash && \
    chown --recursive logstash:logstash /usr/share/logstash/ && \
    ln -s /usr/share/logstash /opt/logstash

WORKDIR /usr/share/logstash

ENV ELASTIC_CONTAINER true
ENV PATH=/usr/share/logstash/bin:$PATH

# Provide a minimal configuration, so that simple invocations will provide
# a good experience.
ADD config/logstash.conf config/
ADD config/temp.txt /tmp/access_log

ADD config/pipelines.yml config/pipelines.yml
ADD config/logstash.yml config/logstash.yml
ADD config/log4j2.properties config/
RUN chown --recursive logstash:logstash config/

# Ensure Logstash gets a UTF-8 locale by default.
ENV LANG='en_US.UTF-8' LC_ALL='en_US.UTF-8'

ADD start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh
#RUN chgrp 0 . && \
#    chmod 0775 . && \
#    chmod 0777 data

WORKDIR /usr/share
RUN chown -R logstash:0 logstash && \
    chmod -R g=u logstash

# Expose ports
EXPOSE 9600 5044

USER 185
ENTRYPOINT ["/usr/local/bin/start.sh"]