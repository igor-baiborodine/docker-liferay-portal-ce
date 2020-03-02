#!/usr/bin/env bash

cd ~/my/own/extended-dockerfile \
  && docker build -t test-extended . \
  && docker run --name test-extended -p 80:8080 -d test-extended

