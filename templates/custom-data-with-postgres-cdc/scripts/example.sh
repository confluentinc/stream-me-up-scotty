#!/bin/sh

# Add the right configs before restarting, Postgres startup creates it's own default 'postgresql.conf', so we need to edit it
# rather than copying a config file into the data directory when creating the container image. 
sed -i "s/shared_preload_libraries = 'decoderbufs,wal2json'/shared_preload_libraries = 'decoderbufs,wal2json,pg_cron'/g" /var/lib/postgresql/data/postgresql.conf

# Restart Postgres for the new configs to take effect 
pg_ctl -D "$PGDATA" -m fast -w restart
