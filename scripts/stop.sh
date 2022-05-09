#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source ${DIR}/../env_files/config.env
source ${DIR}/env.sh

docker-compose down --volumes

(cd "${DIR}/logs/kafka2/data/" && rm -rf *)
(cd "${DIR}/logs/kafka1/data/" && rm -rf *)
(cd "${DIR}/logs/zookeeper/data/" && rm -rf *)
(cd "${DIR}/logs/zookeeper/log/" && rm -rf *)
