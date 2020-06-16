#!/usr/bin/env bash

tag=$1
docker run --name test-jpda -p 80:8080 -d "$tag" catalina.sh jpda run
