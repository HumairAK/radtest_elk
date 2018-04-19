#!/usr/bin/env bash

error() {
    printf '%s\n' "$1" >&2
    exit 1
}

case $1 in
    run)
        case $2 in
            es) cd elasticsearch
                docker run --net elk-network -p 9200:9200 -p 9300:9300 --name elasticsearch es-v1
            ;;
            ls) cd logstash
                docker run --net elk-network --add-host=elasticsearch:172.18.0.2 --name logstash ls-v1
            ;;
            kb) cd kibana
                docker run --net elk-network -p 5601:5601 --add-host=elasticsearch:172.18.0.2 --name kibana kb-v1
            ;;
            *) error 'Error: must specify an argument.' ;;
        esac
        ;;
    exec)
        case $2 in
            es) cd elasticsearch
                docker exec -it elasticsearch bash
            ;;
            ls) cd logstash
                docker exec -it logstash bash
            ;;
            kb) cd kibana
                docker exec -it kibana bash
            ;;
            *) error 'Error: must specify an argument.' ;;
        esac
        ;;
    build)
        case $2 in
            es) cd elasticsearch
                docker build -t es-v1 .
            ;;
            ls) cd logstash
                docker build -t ls-v1 .
            ;;
            kb) cd kibana
                docker build -t kb-v1 .
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