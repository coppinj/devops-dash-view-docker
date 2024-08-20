#!/bin/bash

source /devops/scripts/vars.sh

cd /devops || exit

# Check if AUTH_TOKEN is set
if [ -z "$AUTH_TOKEN" ]; then
  echo "Error: AUTH_TOKEN is not set."
  exit 1
fi

# Check if API_URL is set
if [ -z "$API_URL" ]; then
  echo "Error: API_URL is not set."
  exit 1
fi

# Check if BUDGET is set
if [ -z "$BUDGET" ]; then
  echo "Error: BUDGET is not set."
  exit 1
fi

# Check if MAX_ITERATIONS is set
if [ -z "$MAX_ITERATIONS" ]; then
  echo "Error: MAX_ITERATIONS is not set."
  exit 1
fi

echo "All environment variables are set."

API_RESPONSE=$(curl -X 'POST' "$API_URL/v1/pipelines" -H 'accept: */*' -H "api-key: $AUTH_TOKEN")
UUID=$(echo $API_RESPONSE | jq -r '.uuid')

if [ ! -d "$LOG_DIR" ]; then
  mkdir "$LOG_DIR"
fi

./scripts/bash/subject-filtering.sh

python ./scripts/python/generate.py

./scripts/bash/test-generation.sh 6

if [ ! -d "$RESULT_DIR" ]; then
  mkdir "$RESULT_DIR"
fi

cd "$RESULT_DIR" || exit

zip -r results.zip .

if [ $? -eq 0 ]; then
  echo "Uploading results"

  curl -X 'POST' "$API_URL/v1/pipelines/$UUID/test-classes/upload" -H 'accept: */*' -H "api-key: $AUTH_TOKEN" -H 'Content-Type: multipart/form-data'  -F 'files=@results.zip;type=application/x-zip-compressed'
fi

cd ..

curl -X 'POST' "$API_URL/v1/pipelines/$UUID/complete" -H 'accept: */*' -H "api-key: $AUTH_TOKEN"
