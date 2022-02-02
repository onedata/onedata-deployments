#!/bin/bash

MPATH=~/mpath

trap finish INT

hosts=$*
if [ """$hosts" == "" ]; then
    echo Usage $0 '<hostname or ip> [hostname or ip ...]' 
    exit -1
fi

for i in $hosts; do
    ssh -M -S ${MPATH}_$i $i sleep 99999 &
    until [ -S ${MPATH}_$i ]; do
        sleep 1
    done
    ssh -O check -S ${MPATH}_$i $i 
done

# Run command concurrently on all ${hosts} and wait until they are finished
function sshcmd {
    warr=()
    for i in ${hosts}; do
        # echo "i=" $i
        ssh -S ${MPATH}_$i $i bash -c \"$* \|\& xargs -I{} echo $i:\\\> {} \" &
        warr+=$!
        warr+=" "
    done
    wait ${warr[@]}
}

function finish {
    echo Closing ssh connections...
    for i in $hosts; do
        ssh -O exit -S ${MPATH}_$i $i
    done
}


# Warming up
echo Warming up...
sshcmd hostname
sshcmd date +%T.%N

# sync twice in case of large differences in size of buffered data
# among the nodes
echo Syncing...
sshcmd sync
sshcmd sync
echo Creating snapshot...
sshcmd sudo lvcreate -s -n lvol0-snap -l10%ORIGIN /dev/onedata-vg/lvol0
sshcmd sudo mkdir -p /snapshots/opt/onedata
echo Mounting snapshot...
sshcmd sudo mount /dev/onedata-vg/lvol0-snap /snapshots/opt/onedata/

echo Taring and uploading to S3... 
warr=()
for i in $hosts; do
    ssh -S ${MPATH}_$i $i sh -c \"cd /snapshots\; \
        sudo tar zcf - opt/onedata \| \
        s3cmd -c ~/.s3cfg-prod-test put - s3://datahub-backups/`date +%Y-%m-%d`_$i.tgz\" &
    warr+=$!
    warr+=" "
done
wait ${warr[@]}
echo Unmounting snapshot...
sshcmd sudo umount /dev/onedata-vg/lvol0-snap
echo Removing snapshot...
sshcmd sudo lvremove -y /dev/onedata-vg/lvol0-snap

finish


