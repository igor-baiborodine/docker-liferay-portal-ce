#!/usr/bin/env bash

docker run --rm -it ibaiborodine/liferay-portal-ce version.sh | grep 'Server version'
