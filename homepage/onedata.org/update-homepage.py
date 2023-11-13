#!/usr/bin/env python3
"""
Utility script used for maintaining homepage deployment - allows setting the
docker image that will be used as source of static homepage files and deploying
the static files. The process of deploying simply copies the static artifact
located in the homepage docker into the location from which the files are served
by an nginx server (STATIC_FILES_OUTPUT_PATH). The nginx server is started
in a docker with the STATIC_FILES_OUTPUT_PATH bind-mounted, which makes it
possible to simply overwrite the static artifact on the host and it will be
picked up by nginx without restarting the docker.

"""
__author__ = "Lukasz Opiola"
__copyright__ = "Copyright (C) 2019-2020 ACK CYFRONET AGH"
__license__ = "This software is released under the MIT license cited in " \
              "LICENSE.txt"

import os
import re
import sys
import tempfile
import shutil
from subprocess import call as cmd
from subprocess import check_output as output

SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))
DOCKER_IMAGE_FILE_NAME = 'homepage-docker-image.conf'
DOCKER_IMAGE_FILE_PATH = os.path.join(SCRIPT_DIR, DOCKER_IMAGE_FILE_NAME)
DOCKER_IMAGE_REGEX = re.compile('[a-z0-9]+(?:[._-]{1,2}[a-z0-9]+)*')
ARTIFACT_PATH = '/artefact'
STATIC_FILES_OUTPUT_PATH = './persistence/html'

DOCKER_IMAGE_EXAMPLE = 'docker.onedata.org/homepage:ID-c104a634b4'


def print_help():
    print('Usage: {} <option>'.format(sys.argv[0]))
    print('  help        - display help and exit')
    print('  image <id>  - update image in {}'.format(DOCKER_IMAGE_FILE_NAME))
    print('  deploy      - deploy homepage static files based on {}'.format(DOCKER_IMAGE_FILE_NAME))
    print('--------------------------------------------------------')
    print('<id> - a docker tag, e.g.: \'{}\''.format(DOCKER_IMAGE_EXAMPLE))


def print_homepage_docker_image_file_help():
    print('Error - expected valid image in \'{}\', for example: {}'.format(
        DOCKER_IMAGE_FILE_NAME, DOCKER_IMAGE_EXAMPLE
    ))


def read_image_file():
    result = None

    try:
        if os.path.isfile(DOCKER_IMAGE_FILE_PATH):
            with open(DOCKER_IMAGE_FILE_PATH, 'r') as file:
                contents = file.read()
                docker_image = ''.join(contents.split())  # trim all whitespace
                if DOCKER_IMAGE_REGEX.match(docker_image):
                    result = docker_image
    except Exception:
        pass

    if result is None:
        print_homepage_docker_image_file_help()

    return result


def deploy_static_files_from_docker(docker):
    if not os.path.isdir(STATIC_FILES_OUTPUT_PATH):
        os.makedirs(STATIC_FILES_OUTPUT_PATH)
    cmd(['docker', 'pull', docker])
    out = output(['docker', 'create', '-v', ARTIFACT_PATH, docker, '/bin/true'])
    container = out.rstrip().decode()
    temp_dir = tempfile.mkdtemp()
    artifact_copy_on_host = os.path.join(temp_dir, 'files')
    cmd(['docker', 'cp', '-L', container + ':' + ARTIFACT_PATH, artifact_copy_on_host])
    cmd(['docker', 'rm', '-f', container])

    cmd(['chmod', '-R', '+w', STATIC_FILES_OUTPUT_PATH])

    rsync_cmd = [
        'rsync', '-ah', '--delete',
        '--exclude=/.gitkeep', '--exclude=/training',
        ensure_trailing_slash(artifact_copy_on_host), 
        ensure_trailing_slash(STATIC_FILES_OUTPUT_PATH)
    ]
    print(' '.join(rsync_cmd))
    cmd(rsync_cmd)

    shutil.rmtree(temp_dir)

    print('Removing the docker image ({})...'.format(docker))
    cmd(['docker', 'rmi', docker])

    print('')
    print('All done! Visit onedata.org and make sure everything is there.')


def main():
    if len(sys.argv) == 2 and sys.argv[1] == 'help':
        print_help()

    elif len(sys.argv) == 3 and sys.argv[1] == 'image':
        new_docker_image = sys.argv[2]
        if DOCKER_IMAGE_REGEX.match(new_docker_image):
            with open(DOCKER_IMAGE_FILE_PATH, 'w+') as f:
                f.write(new_docker_image)
        else:
            print('Invalid docker image was provided')

    elif len(sys.argv) == 2 and sys.argv[1] == 'deploy':
        docker_image = read_image_file()
        if docker_image:
            deploy_static_files_from_docker(docker_image)

    else:
        print_help()


def ensure_trailing_slash(path):
    return os.path.join(path, '')


if __name__ == '__main__':
    main()
