#!/usr/bin/env bash

mkdir -p app/config && cd app/config && rm -fr shared_public

git clone -b aboriginal-pasta https://github.com/scr-be/project-build-knowledge.git shared_public
