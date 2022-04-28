#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source ${DIR}/../env_files/config.env

#-------------------------------------------------------------------------------

# REPOSITORY - repository (probably) for Docker images
# The '/' which separates the REPOSITORY from the image name is not required here
export REPOSITORY=${REPOSITORY:-confluentinc}

# Control Center and ksqlDB server must both be HTTP or both be HTTPS; mixed modes are not supported
# C3_KSQLDB_HTTPS=false: set Control Center and ksqlDB server to use HTTP (default)
# C3_KSQLDB_HTTPS=true : set Control Center and ksqlDB server to use HTTPS
export C3_KSQLDB_HTTPS=${C3_KSQLDB_HTTPS:-false}
if [[ "$C3_KSQLDB_HTTPS" == "false" ]]; then
  export CONTROL_CENTER_KSQL_URL="http://ksqldb-server:8088"
  export CONTROL_CENTER_KSQL_ADVERTISED_URL="http://localhost:8088"
  C3URL=http://localhost:9021
else
  export CONTROL_CENTER_KSQL_URL="https://ksqldb-server:8089"
  export CONTROL_CENTER_KSQL_ADVERTISED_URL="https://localhost:8089"
  C3URL=https://localhost:9022
fi

