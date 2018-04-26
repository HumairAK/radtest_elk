#!/usr/bin/env bash

error() {
    printf '%s\n' "$1" >&2
    exit 1
}

if [ "$#" -ne 2 ]; then
    printf 'Must specify 2 arguments \n' >&2
    exit 1
fi

NETWORK=elk-network
PORTS=""
APP=""
HOST=""
ES_IP=172.18.0.2
PROJECT_NAME=radtest-elk

PRIMARY_ERR='Error: must specify a primary argument.[run|exec|build|stop|launch]'
SECONDARY_ERR='Error: must specify a second argument [es|ls|kb]'

assign_app(){
    case $1 in
        es) APP=elasticsearch;;
        ls) APP=logstash;;
        kb) APP=kibana;;
        *) error "${SECONDARY_ERR}";;
    esac
}

case $1 in
    run)
        case $2 in
            es) PORTS=" -p 9200:9200 -p 9300:9300";;
            ls) HOST=" --add-host=elasticsearch:${ES_IP}";;
            kb) PORTS=" -p 5601:5601"; HOST=" --add-host=elasticsearch:${ES_IP}";;
            *) error "${SECONDARY_ERR}";;
        esac
        assign_app $2
        docker run --net ${NETWORK}${HOST}${PORTS} --name ${APP}-docker humair88/${APP}
        ;;
    exec)
        assign_app $2
        docker exec -it ${APP}-docker bash
        ;;
    stop)
        assign_app $2
        docker stop ${APP}-docker
        docker rm ${APP}-docker
        ;;
    build)
        assign_app $2
        docker build -t humair88/${APP}
        ;;
    launch)
        oc new-project ${PROJECT_NAME}
        if [ "$2" == "all" ]; then
            oc new-app elasticsearch/resources.yaml
            oc new-app kibana/resources.yaml
            oc new-app logstash/resources.yaml
        else
            assign_app $2
            oc new-app `${APP}`/resources.yaml
        fi
        ;;
    *) error "${PRIMARY_ERR}";;
esac

