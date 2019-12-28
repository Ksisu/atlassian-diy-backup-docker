FROM postgres:12.1

ENV APPLICATION_DB=confluence
ENV POSTGRES_HOST=localhost
ENV POSTGRES_USERNAME=confluence
ENV PGPASSWORD=confluence
ENV POSTGRES_PORT=5432

VOLUME /data/application_home
VOLUME /data/backup_root
VOLUME /data/backup_archive

RUN apt update && apt install -y \
  bash \
  rsync \
  tar \
  rm -rf /var/lib/apt/lists/*
WORKDIR /atlassian-diy-backup
COPY . .
CMD ["./diy-backup.sh"]
