#!/usr/bin/env bash

tag=$1
docker run --name test-deploy -v ~/my/own/deploydir:/opt/liferay/deploy -d "$tag"
