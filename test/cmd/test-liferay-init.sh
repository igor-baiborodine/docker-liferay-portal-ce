#!/usr/bin/env bash

docker run --name test-liferay-init -v ~/my/own/liferayinitdir:/docker-entrypoint-initliferay.d -d ibaiborodine/liferay-portal-ce
