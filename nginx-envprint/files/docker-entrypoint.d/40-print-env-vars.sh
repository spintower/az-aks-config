#!/bin/sh

HTML_ROOT=/usr/share/nginx/html

LOG_FILE=${HTML_ROOT}/log.txt
OUTPUT_FILE=${HTML_ROOT}/env.txt

date >> ${LOG_FILE}
echo Running 40 file >> ${LOG_FILE}

env > ${OUTPUT_FILE}

date >> ${LOG_FILE}
echo Done running 40 file >> ${LOG_FILE}
