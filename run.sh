#!/usr/bin/env bash

error() {
    printf '%s\n' "$1" >&2
    exit 1
}

case $1 in
    run)
        case $2 in
            es) docker run --net elk-network -p 9200:9200 -p 9300:9300 --name elasticsearch humair88/elasticsearch
            ;;
            ls) docker run --net elk-network --add-host=elasticsearch:172.18.0.2 --name logstash humair88/logstash
            ;;
            kb) docker run --net elk-network -p 5601:5601 --add-host=elasticsearch:172.18.0.2 --name kibana humair88/kibana
            ;;
            *) error 'Error: must specify an argument.' ;;
        esac
        ;;
    exec)
        case $2 in
            es) docker exec -it elasticsearch bash
            ;;
            ls) docker exec -it logstash bash
            ;;
            kb) docker exec -it kibana bash
            ;;
            *) error 'Error: must specify an argument.' ;;
        esac
        ;;
    build)
        case $2 in
            es) cd elasticsearch
                docker build -t humair88/elasticsearch .
            ;;
            ls) cd logstash
                docker build -t humair88/logstash .
            ;;
            kb) cd kibana
                docker build -t humair88/kibana .
            ;;
            *) error 'Error: must specify an argument.' ;;
        esac
        ;;
    stop)
        case $2 in
            es) docker stop elasticsearch
                docker rm elasticsearch
            ;;
            ls) docker stop logstash
                docker rm logstash
            ;;
            kb) docker stop kibana
                docker rm kibana
            ;;
            *) error 'Error: must specify an argument.' ;;

        esac
        ;;
    *)
        error 'Error: must specify an argument.'
esac