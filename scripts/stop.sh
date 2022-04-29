#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source ${DIR}/../env_files/config.env
source ${DIR}/env.sh

docker-compose down --volumes

(cd "${DIR}/logs/kafka2/data/" && rm -rf *)
(cd "${DIR}/logs/kafka1/data/" && rm -rf *)
(cd "${DIR}/logs/zookeeper/data/" && rm -rf *)
(cd "${DIR}/logs/zookeeper/log/" && rm -rf *)

cat << EOF

-----------------------------------------------------------------------------------------------------------
If you ran the Hybrid Cloud portion of this tutorial, which included creating resources in Confluent Cloud,
follow the clean up procedure to destroy those resources to avoid unexpected charges.

     https://docs.confluent.io/platform/current/tutorials/cp-demo/docs/teardown.html

-----------------------------------------------------------------------------------------------------------

EOF
