#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source ${DIR}/../env_files/config.env
source ${DIR}/env.sh

docker-compose down --volumes

docker rm -f $(docker ps -aq)
docker rmi -f $(docker images)

# docker rmi ubuntu:18.04
# docker rmi osixia/openldap:1.3.0
# docker rmi localbuild/tools:${CONFLUENT_DOCKER_TAG}
# docker rmi $REPOSITORY/cp-ksqldb-server:${CONFLUENT_DOCKER_TAG}
# docker rmi $REPOSITORY/cp-schema-registry:${CONFLUENT_DOCKER_TAG}
# docker rmi $REPOSITORY/cp-server:${CONFLUENT_DOCKER_TAG}
# docker rmi $REPOSITORY/cp-zookeeper:${CONFLUENT_DOCKER_TAG}
# docker rmi $REPOSITORY/cp-kafka-rest:${CONFLUENT_DOCKER_TAG}
# docker rmi $REPOSITORY/cp-enterprise-control-center:${CONFLUENT_DOCKER_TAG}


(cd "${DIR}/logs/kafka2/data/" && rm -rf *)
(cd "${DIR}/logs/kafka1/data/" && rm -rf *)
(cd "${DIR}/logs/zookeeper/data/" && rm -rf *)
(cd "${DIR}/logs/zookeeper/log/" && rm -rf *)
