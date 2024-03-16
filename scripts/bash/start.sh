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

curl -X 'POST' "$API_URL/v1/pipelines/$UUID/test-classes/upload" -H 'accept: */*' -H "api-key: $AUTH_TOKEN" -H 'Content-Type: multipart/form-data'  -F 'files=@results.zip;type=application/x-zip-compressed'
curl -X 'POST' "http://host.docker.internal:49001/v1/pipelines/c89b2ed3-738c-4535-91a1-f9c8ddd6e187/test-classes/upload" -H 'accept: */*' -H "api-key: 0e35103f-bc39-43ad-baea-cd613204caa5" -H 'Content-Type: multipart/form-data'  -F 'files=@results.zip;type=application/x-zip-compressed'

cd ..

exit 0
