#!/bin/bash
/etc/init.d/cron restart
/etc/init.d/filebeat restart
if [ -f "/var/run/postgresql/pgbouncer.pid" ]; then
    rm /var/run/postgresql/pgbouncer.pid
fi
/usr/local/bin/pgbouncer -d -u postgres /etc/pgbouncer/pgbouncer.ini
apache2-foreground
