#!/bin/bash
/etc/init.d/cron restart
/etc/init.d/filebeat restart
/usr/local/bin/pgbouncer -d -u postgres /etc/pgbouncer/pgbouncer.ini
apache2-foreground
