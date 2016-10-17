#!/bin/bash
/etc/init.d/cron restart
/usr/sbin/pgbouncer -d -u postgres /etc/pgbouncer/pgbouncer.ini
apache2-foreground
