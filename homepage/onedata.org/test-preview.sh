#!/bin/bash

cd "${0%/*}"
DOCKER_IMAGE=`cat ./homepage-docker-image.conf`
OPEN_CMD='xdg-open'
if [ `uname` == "Darwin" ]; then
  OPEN_CMD='open'
fi

COMMAND="docker run --rm -it -p 8000:8000 ${DOCKER_IMAGE}"
bash -c "sleep 2; ${OPEN_CMD} http://localhost:8000" &
echo "${COMMAND}"
eval ${COMMAND}
