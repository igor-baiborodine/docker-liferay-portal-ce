#!/usr/bin/env bash

docker run --name test-healthcheck \
  --health-cmd='curl -fsS "http://localhost:8080/c/portal/layout" || exit 1' \
  --health-start-period=1m \
  --health-interval=1m \
  --health-retries=3 \
  -d ibaiborodine/liferay-portal-ce
