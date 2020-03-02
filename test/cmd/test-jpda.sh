#!/usr/bin/env bash

docker run --name test-jpda -p 80:8080 -d ibaiborodine/liferay-portal-ce catalina.sh jpda run
