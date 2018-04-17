#!/usr/bin/env bash

error() {
    printf '%s\n' "$1" >&2
    exit 1
}

case $1 in
    run)
        docker run -p 9200:9200 -p 9300:9300 es-v1
        ;;
    exec)
        docker exec -it `docker ps -q -l` bash
        ;;
    build)
        docker build -t radtest-v1 .
        ;;
    stop)
        docker stop `docker ps -ql`
        ;;
    *)
        error 'Error: must specify an argument.'
esac