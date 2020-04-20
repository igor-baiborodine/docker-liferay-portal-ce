#!/usr/bin/env bash

tag=$1
docker run --name test-document-library -p 80:8080 -v ~/my/own/datadir:/opt/liferay/data/document_library -d "$tag"
