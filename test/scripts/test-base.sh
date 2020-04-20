#!/usr/bin/env bash

tag=$1
docker run --name test-base -p 80:8080 -d "$tag"
