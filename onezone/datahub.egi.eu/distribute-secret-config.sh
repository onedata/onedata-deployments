#!/usr/bin/env bash
set -e

source ./common-config.sh

AUTH_CONFIG_PATH="${PWD}/data/secret/auth.config"
MAILER_CONFIG_PATH="${PWD}/data/secret/mailer.config"
EMERGENCY_PASSPHRASE_PATH="${PWD}/data/secret/emergency-passphrase.txt"

for NODE in ${ALL_NODES}; do
    echo "Copying auth.config, mailer.config and emergency-passphrase.txt to ${NODE}:"
    scp ${AUTH_CONFIG_PATH} ${NODE}:${AUTH_CONFIG_PATH}
    scp ${MAILER_CONFIG_PATH} ${NODE}:${MAILER_CONFIG_PATH}
    scp ${EMERGENCY_PASSPHRASE_PATH} ${NODE}:${EMERGENCY_PASSPHRASE_PATH}
done
