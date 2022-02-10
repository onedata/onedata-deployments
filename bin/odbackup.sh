#!/bin/bash
# Author: Darin Nikolow <darnik22@gmail.com>
# Copyright (C) 2022 ACK Cyfronet AGH
# This software is released under the MIT license cited in 'LICENSE.txt'


# Backup multi node onedata deployments - if used live the data consistency is eventual
#
# Run time requirements:
# - s3cmd installed and configured. A sample s3cfg file can be found in samples dir
# - access to the nodes via ssh

MPATH=${MPATH:-~/mpath}                   # the base path for the ssh multiplex socket on
                                            #   the local host
S3_CONF_PATH="${S3_CONF_PATH:-~/.s3cfg-prod-test}"      # path to the s3cmd config file on
                                                        #   the remote nodes
S3_BUCKET="${S3_BUCKET:-s3://datahub-backups}"          # S3 bucket name

hosts=$*
if [ """$hosts" == "" ]; then
    echo "Usage $0 <hostname or ip> [hostname or ip ...]" 
    exit -1
fi

# Initialize ssh multiplexing conections
for i in $hosts; do
    ssh -M -S ${MPATH}_$i $i sleep 99999 &
    until [ -S ${MPATH}_$i ]; do
        sleep 1
    done
    ssh -O check -S ${MPATH}_$i $i 
done

trap finish INT 

# Run command concurrently on all ${hosts} and wait until they are finished
function sshcmd {
    warr=()
    for i in ${hosts}; do
        ssh -S ${MPATH}_$i $i bash -c \"`eval echo $*` \|\& xargs -I{} echo $i:\\\> {} \" &
        warr+=$!
        warr+=" "
    done
    wait ${warr[@]}
}

function finish {
    echo "Closing ssh connections..."
    for i in $hosts; do
        ssh -O exit -S ${MPATH}_$i $i
    done
}

# Warming up
echo "Warming up..."
sshcmd hostname

# sync twice in case of large differences in size of buffered data
# among the nodes
echo "Syncing..."
sshcmd sync
sshcmd sync

echo "Creating snapshot..."
sshcmd sudo lvcreate -s -n lvol0-snap -l10%ORIGIN /dev/onedata-vg/lvol0
sshcmd sudo mkdir -p /snapshots/opt/onedata

echo "Mounting snapshot..."
sshcmd sudo mount /dev/onedata-vg/lvol0-snap /snapshots/opt/onedata/

echo "Taring and uploading to S3..."
sshcmd "cd /snapshots\; \
        sudo tar zcf - opt/onedata \| \
        s3cmd -c ${S3_CONF_PATH} put - ${S3_BUCKET}/`date +%Y-%m-%d`_\$i.tgz"

echo "Unmounting snapshot..."
sshcmd sudo umount /dev/onedata-vg/lvol0-snap

echo "Removing snapshot..."
sshcmd sudo lvremove -y /dev/onedata-vg/lvol0-snap

finish


