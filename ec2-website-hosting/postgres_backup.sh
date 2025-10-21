#!/bin/bash

DUMP_DIR=/home/ubuntu/pg-dumps
APP_DIR=/app/ghostfolio
CONTAINER_NAME=gf-postgres
STAMP="$(date +%F_%H%M%S)"
DUMP_OUT="pg-${STAMP}.dump.gz"
S3_BUCKET="temp-pg-dumps-upload"

export $(grep -v '^#' ${APP_DIR}/.env | grep -E '^POSTGRES' | xargs)

docker exec -i $CONTAINER_NAME pg_dump -U $POSTGRES_USER -d $POSTGRES_DB -F c | gzip | aws s3 cp - s3://${S3_BUCKET}/${DUMP_OUT}