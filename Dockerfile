FROM perconalab/percona-xtrabackup:2.4.11

RUN apt-get update \
  && apt-get install -y curl python3-pip pigz \
  && apt-get clean && rm -rf /var/lib/apt/lists/* \
  && pip3 install s3cmd

COPY xtrabackup.sh /
COPY backup.sh /

ENTRYPOINT []
CMD [ "/backup.sh" ]
