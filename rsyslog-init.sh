#!/bin/bash
# This script use to enable Log Server to accept other server's log

sed -i.bak 's|#input(type="imudp" port="514")|input(type="imudp" port="514")|' /etc/rsyslog.conf

cat > /etc/rsyslog.d/log.conf << END
$template PerHostLog,"/var/log/%fromhost-ip%.log"
:fromhost-ip, !isequal, "127.0.0.1" ?PerHostLog
& stop
END

systemctl reload rsyslog

echo "Reload rsyslog config OK. It is need add firewall rule manual!"

