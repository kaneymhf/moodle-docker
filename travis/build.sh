#!/bin/bash

DB_FLAVOR=""
case $DB_TYPE in
    "mysqli" ) DB_FLAVOR="mysql_maria" ;;
    "pgsql" ) DB_FLAVOR="postgresql" ;;
    *) DB_FLAVOR="mulitbase"
esac

VERSION_TAG="-t kaneymhf/moodle:${DB_FLAVOR}_${VERSION}"

VERSION_TYPE_TAG=""

case $VERSION in
    "${LATEST_LTS}" ) VERSION_TYPE_TAG="-t kaneymhf/moodle:${DB_FLAVOR}_lts" ;;
    "${LATEST}" ) VERSION_TYPE_TAG="-t kaneymhf/moodle:${DB_FLAVOR}_latest -t kaneymhf/moodle:${DB_FLAVOR}" 
    if [ $DB_FLAVOR = "mulitbase" ]; then
        VERSION_TYPE_TAG=" ${VERSION_TYPE_TAG} -t  kaneymhf/moodle:latest"
    fi;;
esac 


docker build -f ${DOCKERFILE} ${VERSION_TYPE_TAG} ${VERSION_TAG} --no-cache --force-rm .