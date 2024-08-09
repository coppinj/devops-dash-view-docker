#!/bin/bash

AUTH_TOKEN='0e35103f-bc39-43ad-baea-cd613204caa5'

API_URL='http://host.docker.internal:49001'

API_RESPONSE=$(curl -X 'POST' "$API_URL/v1/pipelines" -H 'accept: */*' -H "api-key: $AUTH_TOKEN")

UUID=$(echo $API_RESPONSE | jq -r '.uuid')

echo $UUID

cd debug || exit

curl -X 'POST' "$API_URL/v1/pipelines/$UUID/test-classes/upload" -H 'accept: */*' -H "api-key: $AUTH_TOKEN" -H 'Content-Type: multipart/form-data'  -F 'files=@debug.zip;type=application/x-zip-compressed'

curl -X 'POST' "$API_URL/v1/pipelines/$UUID/complete" -H 'accept: */*' -H "api-key: $AUTH_TOKEN"

cd ..
