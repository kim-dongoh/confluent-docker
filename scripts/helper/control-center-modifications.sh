#!/bin/bash

# With RBAC enabled, C3 communication thru its REST endpoint requires JSON Web Tokens (JWT)
JWT_TOKEN=$(curl -s -u controlcenterAdmin:controlcenterAdmin http://localhost:9021/api/metadata/security/1.0/authenticate | jq -r .auth_token)

# If you have 'jq'
clusterId=$(curl -s -X GET -H "Authorization: Bearer ${JWT_TOKEN}" http://localhost:9021/2.0/clusters/kafka/ | jq --raw-output '.[0].clusterId')

echo -e "\nRename the cluster in Control Center from ${clusterId} to Kafka Raleigh"
curl -X PATCH -H "Authorization: Bearer ${JWT_TOKEN}" -H "Content-Type: application/merge-patch+json" -d '{"displayName":"Kafka Raleigh"}' http://localhost:9021/2.0/clusters/kafka/$clusterId

