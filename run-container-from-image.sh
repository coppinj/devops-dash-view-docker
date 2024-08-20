#!/bin/bash

docker run -d \
  -e AUTH_TOKEN="0e35103f-bc39-43ad-baea-cd613204caa5" \
  -e API_URL="http://host.docker.internal:49001" \
  -e BUDGET="20" \
  -e MAX_ITERATIONS="0" \
  -v ./projects:/devops/projects \
  --name cling-ci-cd-container \
  cling-ci-cd
