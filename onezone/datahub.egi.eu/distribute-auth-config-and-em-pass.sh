#!/usr/bin/env bash
set -e

source ./common-config.sh

AUTH_CONFIG_PATH="${PWD}/data/secret/auth.config"
EMERGENCY_PASSPHRASE_PATH="${PWD}/data/secret/emergency-passphrase.txt"

for NODE in ${ALL_NODES}; do
    echo "Copying auth.config and emergency-passphrase.txt to ${NODE}:"
    scp ${AUTH_CONFIG_PATH} ${NODE}:${AUTH_CONFIG_PATH}
    scp ${EMERGENCY_PASSPHRASE_PATH} ${NODE}:${EMERGENCY_PASSPHRASE_PATH}
done
