#!/bin/bash
# This is check & get the SSL from autoSSL server for jitsi meet 
# Ver. 20250325

# printf(%s\n, "10 */1	* * *	root	(/root/chkSSLrenew-meet.sh)");

function sendNotify() {
  # login notify via Telegram
  BOT_TOKEN="5630906286:{TOKEN}"
  CHAT_ID="5717212702"
  TEXT_TO_SEND="meet fetch new SSL and deploy OK"

  /usr/bin/curl -4 -s -S -L -w"\n" -o- \
    -H 'Content-Type: application/json' \
    -d "{\"chat_id\": \"${CHAT_ID}\", \"text\": \"${TEXT_TO_SEND}\"}" \
    -X POST https://api.telegram.org/bot${BOT_TOKEN}/sendMessage
}

if [ ! -e "~/tmp/ssl-local.md5" ]; then
    touch ~/tmp/ssl-local.md5
fi
curl -sSL https://www.mysite.com/ssl-now.md5 -o ~/tmp/ssl-server.md5
cnt=`diff ~/tmp/ssl-local.md5 ~/tmp/ssl-server.md5|wc -l`
if [ ${cnt} == "0" ]; then
    echo "No Change."
    rm -f ~/tmp/ssl-server.md5
    logger -t 'SSLCheck' 'No Change.'
else
    echo "It's reNew..."
    curl -sSL https://www.mysite.com/ssl-now.tgz -o ~/tmp/ssl-now.tgz
    tar zxf ~/tmp/ssl-now.tgz -C /root/tmp
    chown root:root /root/tmp/ssl*
    mv -f /root/tmp/ssl.crt /etc/jitsi/meet/meet.mysite.com.crt
    mv -f /root/rmp/ssl.key /etc/jitsi/meet/meet.mysite.com.key
    chown root:root /etc/jitsi/meet/*
    systemctl reload nginx
    rm -f ~/tmp/ssl-now.tgz
    mv -f ~/tmp/ssl-server.md5 ~/tmp/ssl-local.md5
    echo "Done."
    logger -t 'SSLCheck' 'fetch new SSL and deploy OK.'
    sendNotify
fi
