#!/bin/bash
cd "$(dirname "$0")"

EM_PASSPHRASE_FILE="data/secret/emergency-passphrase.txt"
EMERGENCY_PASSPHRASE=""

# Try to reuse (or generate new) emergency passphrase
if [ -f ${EM_PASSPHRASE_FILE} ]; then
    EMERGENCY_PASSPHRASE=`cat ${EM_PASSPHRASE_FILE}`
fi

if [[ -z "${EMERGENCY_PASSPHRASE}" ]]; then
    EMERGENCY_PASSPHRASE=`openssl rand -base64 14`
    echo ${EMERGENCY_PASSPHRASE} > ${EM_PASSPHRASE_FILE}
    echo "WARNING: generated a new emergency passphrase: ${EMERGENCY_PASSPHRASE}"
    echo "         stored in ${EM_PASSPHRASE_FILE}"
fi

# EMERGENCY_PASSPHRASE env is referenced in docker-compose.yml
case ${1} in
    start)
        EMERGENCY_PASSPHRASE=${EMERGENCY_PASSPHRASE} docker-compose up -d
        ;;
    stop)
        EMERGENCY_PASSPHRASE=${EMERGENCY_PASSPHRASE} docker-compose down
        ;;
    restart)
        EMERGENCY_PASSPHRASE=${EMERGENCY_PASSPHRASE} docker-compose down
        EMERGENCY_PASSPHRASE=${EMERGENCY_PASSPHRASE} docker-compose up -d
        ;;
    logs)
        # Displays container logs
        docker logs onezone
        ;;
    exec)
        docker exec -it onezone bash
        ;;
    worker)
        # Attaches to oz-worker's erlang console (exit with Ctrl + D)
        docker exec -it onezone oz_worker attach-direct
        ;;
    panel)
        # Attaches to oz-panel's erlang console (exit with Ctrl + D)
        docker exec -it onezone oz_panel attach-direct
        ;;
    worker-logs)
        # Displays oz-worker logs
        docker exec -it onezone cat /var/log/oz_worker/info.log
        ;;
    panel-logs)
        # Displays oz-panel logs
        docker exec -it onezone cat /var/log/oz_panel/info.log
        ;;
    *)
        echo "Unknown command '${1}'"
        echo "Available commands: start | stop | restart | logs | exec | worker | panel"
        exit 1
        ;;
esac
