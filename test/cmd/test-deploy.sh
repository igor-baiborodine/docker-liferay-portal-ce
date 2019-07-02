#!/usr/bin/env bash

docker run --name test-deploy -v ~/my/own/deploydir:/opt/liferay/deploy -d ibaiborodine/liferay-portal-ce
