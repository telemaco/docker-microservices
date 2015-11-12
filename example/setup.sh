#!/bin/bash

docker-machine create -d virtualbox devel
eval "$(docker-machine env devel)"
SWARM_TOKEN=$(docker run swarm create)
echo $SWARM_TOKEN

docker-machine create -d virtualbox  --swarm --swarm-master \
               --swarm-discovery token://$SWARM_TOKEN       \
               master

eval "$(docker-machine env master)"
CONSUL_MASTER_IP=$(docker-machine ip master)
docker run -d --name consul -h consul                 \
        -p $CONSUL_MASTER_IP:8300:8300                    \
        -p $CONSUL_MASTER_IP:8301:8301                    \
        -p $CONSUL_MASTER_IP:8301:8301/udp                \
        -p $CONSUL_MASTER_IP:8302:8302                    \
        -p $CONSUL_MASTER_IP:8302:8302/udp                \
        -p $CONSUL_MASTER_IP:8400:8400                    \
        -p $CONSUL_MASTER_IP:8500:8500                    \
        -p $CONSUL_MASTER_IP:53:53                        \
        -p $CONSUL_MASTER_IP:53:53/udp                    \
        progrium/consul                                   \
        -server                                           \
        -advertise $CONSUL_MASTER_IP                      \
        -bootstrap

REGISTRATOR_MASTER_IP=$(docker-machine ip master)
docker run -d --name registrator -h registrator       \
    -v /var/run/docker.sock:/tmp/docker.sock          \
    gliderlabs/registrator                            \
    consul://$CONSUL_MASTER_IP:8500                   \
    -ip $REGISTRATOR_MASTER_IP

docker build -t microservice/nginx-consul dockers/nginx-consul
docker run -d --name nginx-consul -p 80:80 -p 443:443 --dns $CONSUL_MASTER_IP \
       microservice/nginx-consul

docker-machine create -d virtualbox   --swarm                    \
                    --swarm-discovery token://$SWARM_TOKEN       \
                    nodo-1
docker-machine create -d virtualbox   --swarm                    \
                    --swarm-discovery token://$SWARM_TOKEN       \
                    nodo-2

eval "$(docker-machine env nodo-1)"
NODO1_IP=$(docker-machine ip nodo-1)
docker run --name consul1 -d -h consul1      \
    -p $NODE1_IP:8300:8300                   \
    -p $NODE1_IP:8301:8301                   \
    -p $NODE1_IP:8301:8301/udp               \
    -p $NODE1_IP:8302:8302                   \
    -p $NODE1_IP:8302:8302/udp               \
    -p $NODE1_IP:8400:8400                   \
    -p $NODE1_IP:8500:8500                   \
    -p $NODE1_IP:53:53                       \
    -p $NODE1_IP:53:53/udp                   \
    progrium/consul                          \
    -server                                  \
    -advertise $NODO1_IP                     \
    -join $CONSUL_MASTER_IP

eval "$(docker-machine env nodo-2)"
NODO2_IP=$(docker-machine ip nodo-2)
docker run --name consul2 -d -h consul2      \
    -p $NODE2_IP:8300:8300                   \
    -p $NODE2_IP:8301:8301                   \
    -p $NODE2_IP:8301:8301/udp               \
    -p $NODE2_IP:8302:8302                   \
    -p $NODE2_IP:8302:8302/udp               \
    -p $NODE2_IP:8400:8400                   \
    -p $NODE2_IP:8500:8500                   \
    -p $NODE2_IP:53:53                       \
    -p $NODE2_IP:53:53/udp                   \
    progrium/consul                          \
    -server                                  \
    -advertise $NODO2_IP                     \
    -join $CONSUL_MASTER_IP

eval "$(docker-machine env nodo-1)"
docker run --name registrator-1 -d -h registrator-1   \
        -v /var/run/docker.sock:/tmp/docker.sock      \
        gliderlabs/registrator                        \
        consul://$NODO1_IP:8500                       \
        -ip $NODO1_IP

eval "$(docker-machine env nodo-2)"
docker run --name registrator-2 -d -h registrator-2   \
        -v /var/run/docker.sock:/tmp/docker.sock      \
        gliderlabs/registrator                        \
        consul://$NODO2_IP:8500                       \
        -ip $NODO2_IP

SWARM_NODES=("master" "nodo-1" "nodo-2" )
for NODE_NAME in "${SWARM_NODES[@]}"; do
  DOCKER_FILES=$(find $(pwd dockers) -name Dockerfile | grep -v nginx-consul)
  for DOCKER_FILE in $DOCKER_FILES; do
    eval "$(docker-machine env $NODE_NAME)"
    DOCKER_NAME=$(basename $(dirname $DOCKER_FILE))
    docker build -t microservice/$DOCKER_NAME $(dirname $DOCKER_FILE)
  done
done


