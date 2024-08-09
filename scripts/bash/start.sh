#!/bin/bash

cd /devops || exit

AUTH_TOKEN='0e35103f-bc39-43ad-baea-cd613204caa5'
API_URL='http://host.docker.internal:49001'

API_RESPONSE=$(curl -X 'POST' "$API_URL/v1/pipelines" -H 'accept: */*' -H "api-key: $AUTH_TOKEN")
UUID=$(echo $API_RESPONSE | jq '.uuid')

./scripts/bash/subject-filtering.sh

python ./scripts/python/generate.py

./scripts/bash/test-generation.sh 6

cd results || exit

zip -r results.zip .

curl -X 'POST' "http://$API_URL/v1/pipelines/$UUID/test-classes/upload" -H 'accept: */*' -H "api-key: $AUTH_TOKEN" -H 'Content-Type: multipart/form-data'  -F 'files=@results.zip;type=application/x-zip-compressed'

cd ..

curl -X 'POST' "http://$API_URL/v1/pipelines/$UUID/complete" -H 'accept: */*' -H "api-key: $AUTH_TOKEN"

exit 0
