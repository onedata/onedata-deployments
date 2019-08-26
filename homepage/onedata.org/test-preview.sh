#!/bin/bash

bash -c 'sleep 2; open http://localhost:8080' &
docker-compose -f "preview-docker-compose.yml" up