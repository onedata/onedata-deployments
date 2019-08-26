#!/bin/bash

bash -c 'sleep 2; open http://localhost:8080' &
docker-compose -f "data/test-preview/test-preview-docker-compose.yml" up