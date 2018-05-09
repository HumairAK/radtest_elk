# Radanalytics Test Dockerfiles

This repo contains dockerfiles that will allow one to quickly deploy the elk stack onto openshift.

All configuration files used to launch each app can be found within this github repo.


# Running on Docker

Each ELK container communicates with each other over the same docker network. 
As such we create a user-defined for all 3 container: 

```
docker network create elk-network
```

Run the elasticsearch container. Replace <container-name> with your preferred
container name. 

```
docker run --net elk-network -p 9200:9200 -p 9300:9300 --name <container-name> humair88/elasticsearch
```

Run the Logstash container with the following command, replace <es-ip> 
with your elasticsearch's container ip. 

```
docker run --net elk-network --add-host=elasticsearch:<es-ip> --name <container-name> humair88/logstash
```

Run the Kibana container

```
docker run --net elk-network -p 5601:5601 --add-host=elasticsearch:<es-ip> --name <container-name> humair88/kibana
```

You should now be able to access the Kibana dashboard via http://localhost:5601

# Running on Openshift

The following commands will launch the entire elk stack on Openshift in a 
newly created project called `radtest-elk`. Ensure you are logged into an 
Openshift instance via `oc`. 

```
git clone https://github.com/HumairAK/radtest_elk.git
cd radtest_elk
./rtcmd.sh launch all
```

### Configuring your stack
Within each file folder (elasticsearch, kibana, logstash), you will find example configuration files
that are mounted as config map volumes within the Openshift cluster. You can change these files dynamically
and restart your deployment for the changes to take affect. For example, suppose you want to consume messages
from a kafka broker into your logstash, simply edit the logstash.conf within the example-logstash-config configmap 
to something like: 

```
input {
  kafka {
    bootstrap_servers => "my-cluster-kafka:9092"
    topics => ["logs"]
  }
}

filter {
  kv { }
  mutate {
    convert => { "time" => "integer" }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
  }
  stdout {
    codec => rubydebug
  }
}
```

Re-deploying your logstash on Openshift will now use the updated config. The same can be done 
for all the configuration files that come with elasticsearch and kibana.
