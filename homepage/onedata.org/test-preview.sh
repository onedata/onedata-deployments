#!/bin/bash

cd "${0%/*}"
DOCKER_IMAGE=`cat ./homepage-docker-image.cfg`

COMMAND="docker run --rm -it -p 8000:8000 ${DOCKER_IMAGE}"
bash -c 'sleep 2; open http://localhost:8000' &
echo "${COMMAND}"
eval ${COMMAND}
