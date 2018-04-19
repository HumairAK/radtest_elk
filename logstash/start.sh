#!/usr/bin/env bash
echo "Starting Logstash"
/usr/share/logstash/bin/logstash --path.settings /etc/logstash -f /etc/logstash/conf.d/logstash.conf