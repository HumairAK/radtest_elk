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
SECONDARY_ERR='Error: must specify a second argument [es|ls|kb|kafka]'

assign_app(){
    case $1 in
        es) APP=elasticsearch;;
        ls) APP=logstash;;
        kb) APP=kibana;;
        *) error "${SECONDARY_ERR}";;
    esac
}

# Pre-condition, oc is logged into the project
launch_logstash(){
    set -e
    oc create configmap example-logstash-config \
        --from-file=logstash-config=logstash/examples/logstash.conf \
        --from-file=logstash-yml=logstash/examples/logstash.yml \
        --from-file=log4j2-properties=logstash/examples/log4j2.properties \
        --from-file=pipelines-yml=logstash/examples/pipelines.yml
    oc new-app logstash/resources.yaml
}

# Pre-condition, oc is logged into the project
launch_elasticsearch(){
    set -e
    oc create configmap example-es-config \
        --from-file=jvm-options=elasticsearch/examples/jvm.options \
        --from-file=elasticsearch-yml=elasticsearch/examples/elasticsearch.yml \
        --from-file=log4j2-properties=elasticsearch/examples/log4j2.properties
    oc new-app elasticsearch/resources.yaml
}

# Pre-condition, oc is logged into the project
launch_kibana(){
    set -e
    oc create configmap example-kb-config \
        --from-file=kibana-yml=kibana/examples/kibana.yml
    oc new-app kibana/resources.yaml
}

launch_kafka(){
    pushd ~
    git clone https://github.com/strimzi/strimzi.git && cd strimzi
    oc create -f examples/install/cluster-controller
    oc create -f examples/templates/cluster-controller
    oc new-app strimzi-ephemeral
    popd
    rm ~/strimzi -rf
}

# $1 /in {run, exec, stop, build, launch}
# $2 /in {es, ls, kb. kafka}

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
        cd ${APP}
        docker build -t humair88/${APP} .
        ;;
    launch)
        oc get project ${PROJECT_NAME} || oc new-project ${PROJECT_NAME}
        if [ "$2" == "all" ]; then
            launch_kafka
            launch_elasticsearch
            launch_kibana
            launch_logstash
        elif [ "$2" == "kafka" ]; then
            launch_kafka
        else
            case $2 in
                es) launch_elasticsearch;;
                ls) launch_logstash;;
                kb) launch_kibana;;
                *) error "${SECONDARY_ERR}";;
            esac
        fi
        ;;
    *) error "${PRIMARY_ERR}";;
esac