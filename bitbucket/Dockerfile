FROM postgres:12.1

ARG BACKUP_SCRIPT_VERSION=0d4431c97bb067c226aaed5e27a59bdb56d33c27
ENV BITBUCKET_BACKUP_SCRIPT_VERSION=$BACKUP_SCRIPT_VERSION

ENV BITBUCKET_URL=http://localhost:7990

ENV BITBUCKET_BACKUP_USER=admin
ENV BITBUCKET_BACKUP_PASS=admin

ENV BITBUCKET_DB=bitbucket
ENV POSTGRES_HOST=localhost
ENV POSTGRES_USERNAME=bitbucket
ENV PGPASSWORD=bitbucket
ENV POSTGRES_PORT=5432

ENV CURL_OPTIONS="-L -s -f"

VOLUME /data/bitbucket_home
VOLUME /data/backup_root/bitbucket_home
VOLUME /data/backup_root/bitbucket_db
VOLUME /data/backup_archive

RUN apt update && apt install -y \
  bash \
  jq \
  rsync \
  tar \
  curl \
  git && \
  rm -rf /var/lib/apt/lists/*
RUN git clone https://bitbucket.org/atlassianlabs/atlassian-bitbucket-diy-backup.git && cd atlassian-bitbucket-diy-backup && git checkout $BITBUCKET_BACKUP_SCRIPT_VERSION
WORKDIR /atlassian-bitbucket-diy-backup
COPY bitbucket.diy-backup.vars.sh .
CMD ["./bitbucket.diy-backup.sh"]
