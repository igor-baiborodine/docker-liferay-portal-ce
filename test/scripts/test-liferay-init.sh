#!/usr/bin/env bash

tag=$1
docker run --name test-liferay-init -v ~/my/own/liferayinitdir:/docker-entrypoint-initliferay.d -d "$tag"
