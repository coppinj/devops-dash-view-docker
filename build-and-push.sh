#!/bin/bash

docker build -t cling-ci-cd -f build.Dockerfile .

docker tag cling-ci-cd jucoppinunamur/cling-ci-cd:latest
docker login -u jucoppinunamur
docker push jucoppinunamur/cling-ci-cd:latest
