## Atlassian Confluence/Jira diy backup (with postgres, rsync, tar)
It is based on the [official Bitbucket backup scripts](https://bitbucket.org/atlassianlabs/atlassian-bitbucket-diy-backup/src/master/), 
just copy the necessary scripts and remove the Bitbucket specific parts.

##### Confluence
See more details at the [official wiki page](https://confluence.atlassian.com/doc/production-backup-strategy-38797389.html).

##### Jira
See more details at the [official wiki page](https://confluence.atlassian.com/adminjiraserver/backing-up-data-938847673.html).

##### Environment variables:
|Name|Default|Note|
|---|---|---|
|POSTGRES_HOST|localhost|Postgres database host|
|POSTGRES_PORT|5432|Postgres database port|
|POSTGRES_USERNAME|confluence|Postgres database username|
|PGPASSWORD|confluence|Postgres database password|
|APPLICATION_DB|confluence|Application database name|

##### Volumes:
|Path|Note|
|---|---|
|/data/application_home|Confluence/Jira home dir|
|/data/backup_root|Backup working dir (it have to contain a `home` and a `db` folder)|
|/data/backup_archive|Backup archive files|

### Before first run
- Create a directory for backup working dir.
```bash
mkdir -p /data/application/backup_root && \
chmod -R 777 /data/application/backup_root
```
- Create a directory for archives.
```bash
mkdir -p /data/application/backup_archive && \
chmod -R 777 /data/application/backup_archive
```

### Run
Configure the environment variables and the mounts.

```bash
docker run -it --rm \
  -e APPLICATION_DB=confluence \
  -e POSTGRES_HOST=database.example.com \
  -e POSTGRES_USERNAME=confluence \
  -e PGPASSWORD=database_secret_password \
  -e POSTGRES_PORT=5432 \
  -v /data/application_home:/data/application_home \
  -v /data/application/backup_root:/data/backup_root \
  -v /data/application/backup_archive:/data/backup_archive \
  ksisu/atlassian-common-diy-backup-postgres-rsync-tar
```
