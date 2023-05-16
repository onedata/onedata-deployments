#!/usr/bin/env python3

# Author: Darin Nikolow <darnik22@gmail.com>
# Copyright (C) 2022 ACK Cyfronet AGH
# This software is released under the MIT license cited in 'LICENSE.txt'

# odcleanup.py removes from s3 old backups done by odbackup.sh
# Fo more details about the structure of the backups see odbackup.sh
# The script keeps by default the 60 most recent backups.
# --number-of-backups arg can be used to change the default value.
# The number of backup to keep can not be less than 10.
# The s3 credentials should be placed in ~/.aws/credential

import boto3
import argparse

def parse_args():
    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
        description='Push build artifacts.')

    parser.add_argument(
        '--number-of-backups', '-n',
        type=int,
        default=60,
        help='Number of backups to keep for each cluster',
        required=False)

    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Do not remove objects. Only list what will be removed.',
        required=False)

    return parser.parse_args()

args = parse_args()
if args.number_of_backups < 10:
    print('The number of backups to keep can not be less than 10.')
    quit()
    
session = boto3.Session()
s3 = session.client('s3', endpoint_url='https://storage.cloud.cyfronet.pl')
bucket_name = 'datahub-backups'
continuation_token = ''
all_objects = []
backups = {}
while True:
    response = s3.list_objects_v2(Bucket=bucket_name, ContinuationToken=continuation_token)
    # add objects to list
    if 'Contents' in response:
        all_objects.extend(response['Contents'])
    # check if there are more objects to retrieve
    if response['IsTruncated']:
        continuation_token = response['NextContinuationToken']
    else:
        break

# Prepare backups dict: backup_key => [s3obj1, s3obj2, ...]
# the key is the substring left of '_' from the object name
# Example:
# plg-cyfronet-01/2022-05-08_10.20.30.13.tgz -> plg-cyfronet-01/2022-05-08
backups = {}
for obj in all_objects:
    key_parts = obj['Key'].split('_')
    if len(key_parts) > 1:
        backup_key = key_parts[0]
        if backup_key not in backups:
            backups[backup_key] = []
        backups[backup_key].append(obj)

# Prepare clusters dict. cluster_key => [backup1, backup2, ...]
# cluster_key is the substring left of '/' from the backup_key
clusters = {}
for key, objects in backups.items():
    key_parts = key.split('/')
    if len(key_parts) > 1:
        cluster_key = key_parts[0]
        if cluster_key not in clusters:
            clusters[cluster_key] = []
        clusters[cluster_key].append({key: objects})

# Prepare list of objects to delete
objects_to_delete = []
for key, objects in clusters.items():
    if len(objects) > args.number_of_backups:
        for backup_object in sorted(objects, key=lambda x: list(x.keys())[0])[:len(objects)-args.number_of_backups]:
            for dictionary in backup_object[next(iter(backup_object))]:
                objects_to_delete.append({'Key': dictionary['Key']})

if args.dry_run:
    print("Objects to delete:")
    print('==================')
    for obj in objects_to_delete:
        print(obj)
else:
    response = s3.delete_objects(Bucket=bucket_name, Delete={'Objects': objects_to_delete})
    print(response)
