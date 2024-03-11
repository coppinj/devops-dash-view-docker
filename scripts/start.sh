#!/bin/bash

cd /devops || exit

./scripts/subject-filtering.sh

python ./scripts/generate.py
