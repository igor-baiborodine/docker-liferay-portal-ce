#!/usr/bin/env bash

docker run --name test-env-var -p 80:8080 -it --env LIFERAY_SETUP_PERIOD_WIZARD_PERIOD_ENABLED=false ibaiborodine/liferay-portal-ce
