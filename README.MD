## Atlassian Bitbucket server diy backup (with postgres, rsync, tar)
It is a simple docker image with the [official backup scripts](https://bitbucket.org/atlassianlabs/atlassian-bitbucket-diy-backup/src/master/).

See more details at the [official wiki page](https://confluence.atlassian.com/bitbucketserver/using-bitbucket-server-diy-backup-776640056.html).

##### Environment variables:
|Name|Default|Note|
|---|---|---|
|BITBUCKET_URL|http://localhost:7990|Bitbucket Server address|
|BITBUCKET_BACKUP_USER|admin|Bitbucket Admin username|
|BITBUCKET_BACKUP_PASS|admin|Bitbucket Admin password|
|POSTGRES_HOST|localhost|Postgres database host|
|POSTGRES_PORT|5432|Postgres database port|
|POSTGRES_USERNAME|bitbucket|Postgres database username|
|PGPASSWORD|bitbucket|Postgres database password|
|BITBUCKET_DB|bitbucket|Bitbucket database name|
|CURL_OPTIONS|"-L -s -f"||

##### Volumes:
|Path|Note|
|---|---|
|/data/bitbucket_home|Bitbucket server home dir|
|/data/backup_root|Backup working dir (it have to contain a `bitbucket_home` and a `bitbucket_db` folder)|
|/data/backup_archive|Backup archive files|

### Before first run
- Create a directory for backup working dir with `bitbucket_home` and `bitbucket_db` folder.
```bash
mkdir -p /data/bitbucket/backup_root/bitbucket_home && \
mkdir -p /data/bitbucket/backup_root/bitbucket_db && \
chmod -R 777 /data/bitbucket/backup_root
```
- Create a directory for archives.
```bash
mkdir -p /data/bitbucket/backup_archive && \
chmod -R 777 /data/bitbucket/backup_archive
```

### Run
Configure the environment variables and the mounts.

```bash
docker run -it --rm \
  -e BITBUCKET_URL=https://stash.example.com \
  -e BITBUCKET_BACKUP_USER=admin \
  -e BITBUCKET_BACKUP_PASS=admin_secret_password \
  -e BITBUCKET_DB=bitbucket \
  -e POSTGRES_HOST=database.example.com \
  -e POSTGRES_USERNAME=bitbucket \
  -e PGPASSWORD=database_secret_password \
  -e POSTGRES_PORT=5432 \
  -v /data/bitbucket_home:/data/bitbucket_home \
  -v /data/bitbucket/backup_root:/data/backup_root \
  -v /data/bitbucket/backup_archive:/data/backup_archive \
  ksisu/bitbucket-diy-backup-postgres-rsync-tar
```
