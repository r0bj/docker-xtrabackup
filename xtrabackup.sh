#!/bin/bash

set -eo pipefail

mysql_user=${MYSQL_USER:-root}
mysql_password=${MYSQL_PASSWORD}
mysql_host=${MYSQL_HOST:-127.0.0.1}
s3_bucket=${S3_BUCKET}
s3_access_key=${S3_ACCESS_KEY}
s3_secret_key=${S3_SECRET_KEY}

target_dir="/backup"

function write_log {
	echo "`date +'%Y%m%d %H%M%S'`: $1"
}

if [ -z "$mysql_password" ] || [ -z "$s3_bucket" ] || [ -z "$s3_access_key" ] || [ -z "$s3_secret_key" ]; then
	write_log "One or more parameter empty"
	exit 1
fi

timestamp=$(date +'%Y%m%d_%H%M%S')
filename="xtrabackup-${timestamp}.gz"
tmpfile="/$filename"
date=$(date +'%Y%m%d')
hostname=$(hostname)
object="s3://${s3_bucket}/${date}/${hostname}/${filename}"

write_log "Running xtrabackup"

mkdir $target_dir
xtrabackup --host=$mysql_host --user=$mysql_user --password=$mysql_password --backup --target-dir=$target_dir
tar cpf $tmpfile -I pigz -C $target_dir .

write_log "Uploading archive to S3"
s3cmd --access_key=$s3_access_key --secret_key=$s3_secret_key -m binary/octet-stream put $tmpfile $object
rm -f $tmpfile
