#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source ${DIR}/helper/functions.sh
source ${DIR}/env.sh

#-------------------------------------------------------------------------------

# Do preflight checks
preflight_checks || exit

# Stop existing Docker containers
${DIR}/stop.sh

# Regenerate certificates and the Connect or tools Docker image if any of the following conditions are true
if [[ "$CLEAN" == "true" ]] || \
 ! [[ $(docker images --format "{{.Repository}}:{{.Tag}}" localbuild/tools:${CONFLUENT_DOCKER_TAG}) =~ localbuild ]] ;
then
  if [[ -z $CLEAN ]] || [[ "$CLEAN" == "false" ]] ; then
    echo "INFO: Setting CLEAN=true because minimum conditions not met (existing certificates, Connect tools Docker image localbuild/tools:${CONFLUENT_DOCKER_TAG})"
  fi
  CLEAN=true
  clean_demo_env
else
  CLEAN=false
fi

echo
echo "Environment parameters"
echo "  REPOSITORY=$REPOSITORY"
echo "  CLEAN=$CLEAN"
echo "  C3_KSQLDB_HTTPS=$C3_KSQLDB_HTTPS"
echo

if [[ "$CLEAN" == "true" ]] ; then
  create_certificates
fi

#-------------------------------------------------------------------------------

# Bring up openldap
docker-compose up --no-recreate -d openldap
sleep 5
if [[ $(docker-compose ps openldap | grep Exit) =~ "Exit" ]] ; then
  echo "ERROR: openldap container could not start. Troubleshoot and try again. For troubleshooting instructions see https://docs.confluent.io/platform/current/tutorials/cp-demo/docs/troubleshooting.html"
  exit 1
fi

# Build custom tools image and connect image
build_tools_image

# Bring up tools
docker-compose up --no-recreate -d tools

# Bring up base kafka cluster
docker-compose up --no-recreate -d zookeeper kafka1 kafka2

# Verify MDS has started
MAX_WAIT=150
echo "Waiting up to $MAX_WAIT seconds for MDS to start"
retry $MAX_WAIT host_check_up kafka1 || exit 1
retry $MAX_WAIT host_check_up kafka2 || exit 1

echo "Creating role bindings for principals"
docker-compose exec tools bash -c "/tmp/helper/create-role-bindings.sh" || exit 1

# Workaround for setting min ISR on topic _confluent-metadata-auth
docker-compose exec kafka1 kafka-configs \
   --bootstrap-server kafka1:12091 \
   --entity-type topics \
   --entity-name _confluent-metadata-auth \
   --alter \
   --add-config min.insync.replicas=1

#-------------------------------------------------------------------------------


# Bring up more containers
docker-compose up --no-recreate -d schemaregistry control-center

#-------------------------------------------------------------------------------

# Verify Confluent Control Center has started
MAX_WAIT=300
echo
echo "Waiting up to $MAX_WAIT seconds for Confluent Control Center to start"
retry $MAX_WAIT host_check_up control-center || exit 1

echo -e "\nConfluent Control Center modifications:"
${DIR}/helper/control-center-modifications.sh
echo

#-------------------------------------------------------------------------------

# Start more containers
docker-compose up --no-recreate -d ksqldb-server restproxy

# Verify ksqlDB server has started
echo
echo
MAX_WAIT=120
echo -e "\nWaiting up to $MAX_WAIT seconds for ksqlDB server to start"
retry $MAX_WAIT host_check_up ksqldb-server || exit 1

#-------------------------------------------------------------------------------

# Verify Docker containers started
if [[ $(docker-compose ps) =~ "Exit 137" ]]; then
  echo -e "\nERROR: At least one Docker container did not start properly, see 'docker-compose ps'. Did you increase the memory available to Docker to at least 8 GB (default is 2 GB)?\n"
  exit 1
fi

echo
echo -e "\nAvailable LDAP users:"
#docker-compose exec openldap ldapsearch -x -h localhost -b dc=confluentdemo,dc=io -D "cn=admin,dc=confluentdemo,dc=io" -w admin | grep uid:
curl -u mds:mds -X POST "http://localhost:8091/security/1.0/principals/User%3Amds/roles/UserAdmin" \
  -H "accept: application/json" -H "Content-Type: application/json" \
  -d "{\"clusters\":{\"kafka-cluster\":\"does_not_matter\"}}"
curl -u mds:mds -X POST "http://localhost:8091/security/1.0/rbac/principals" --silent \
  -H "accept: application/json"  -H "Content-Type: application/json" \
  -d "{\"clusters\":{\"kafka-cluster\":\"does_not_matter\"}}" | jq '.[]'

# Do poststart_checks
poststart_checks


cat << EOF

----------------------------------------------------------------------------------------------------
DONE! From your browser:

  Confluent Control Center (login superUser/superUser for full access):
     $C3URL

EOF

cat << EOF
Want more? Learn how to replicate data from the on-prem cluster to Confluent Cloud:

     https://docs.confluent.io/platform/current/tutorials/cp-demo/docs/hybrid-cloud.html

Use Confluent Cloud promo code CPDEMO50 to receive \$50 free usage
----------------------------------------------------------------------------------------------------

EOF
