#!/usr/bin/env bash

docker run --name test-document-library -p 80:8080 -v ~/my/own/datadir:/opt/liferay/data/document_library -d ibaiborodine/liferay-portal-ce
