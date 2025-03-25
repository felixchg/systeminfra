#!/bin/bash
# This is check & get the SSL from autoSSL server, and deploy to local servers

# printf(%s\n, "10 */1	* * *	root	(/root/chkSSLrenew.sh)");

function sendNotify() {
  # login notify via Telegram
  BOT_TOKEN="5630906286:{TOKEN}"
  CHAT_ID="5717212702"
  TEXT_TO_SEND="my220 fetch new SSL and deploy OK"

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
    tar zxf ~/tmp/ssl-now.tgz -C /etc/nginx/SSL/
    systemctl reload nginx
    scp -i /home/adm/.ssh/id_rsa ~/tmp/ssl-now.tgz adm@10.0.1.101:/home/adm/tmp/
    scp -i /home/adm/.ssh/id_rsa ~/tmp/ssl-now.tgz adm@11.0.1.102:/home/adm/tmp/
    rm -f ~/tmp/ssl-now.tgz
    mv -f ~/tmp/ssl-server.md5 ~/tmp/ssl-local.md5
    echo "Done."
    logger -t 'SSLCheck' 'fetch new SSL and deploy OK.'
    sendNotify
fi
