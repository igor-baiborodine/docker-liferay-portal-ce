#!/usr/bin/env bash

tag=$1
# test copying portal-ext.properties and tomcat/bin/setenv.sh
docker run --name test-liferay-base -v ~/my/own/liferaybasedir:/etc/opt/liferay -d "$tag"
