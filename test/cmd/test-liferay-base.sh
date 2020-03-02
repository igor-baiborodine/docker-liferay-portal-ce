#!/usr/bin/env bash

# test copying portal-ext.properties and tomcat/bin/setenv.sh
docker run --name test-liferay-base -v ~/my/own/liferaybasedir:/etc/opt/liferay -d ibaiborodine/liferay-portal-ce
