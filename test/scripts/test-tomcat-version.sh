#!/usr/bin/env bash

tag=$1
docker run --rm -it "$tag" | grep 'Server version'
