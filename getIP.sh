#!/bin/bash
# check real ip for my Server

# 10 */1  * * *   root    (/root/getIP.sh)

function sendNotify() {
  # login notify via Telegram
  BOT_TOKEN="5630906286:{TOKEN}"
  CHAT_ID="5717212702"
  TEXT_TO_SEND="meet Server change IP: ${nowIP}"

  /usr/bin/curl -4 -s -S -L -w"\n" -o- \
    -H 'Content-Type: application/json' \
    -d "{\"chat_id\": \"${CHAT_ID}\", \"text\": \"${TEXT_TO_SEND}\"}" \
    -X POST https://api.telegram.org/bot${BOT_TOKEN}/sendMessage
}

nowIP=`rm -f aa; echo "ehlo a" |nc -w 3 gmail-smtp-in.l.google.com. 25 > aa; grep '250-mx.google.com' aa|cut -f2 -d'['|cut -f1 -d']'`
#echo ${nowIP}
echo ${nowIP} > ~/tmp/ip.now
# > ~/tmp/ip.now
#rm -f aa; echo "ehlo a" |nc -w 3 gmail-smtp-in.l.google.com. 25 > aa; grep '250-mx.google.com' aa|cut -f2 -d'['|cut -f1 -d']' > ~/tmp/ip.now


if [ ! -e "~/tmp/ip.orig" ]; then
    touch ~/tmp/ip.orig
fi
cnt=`diff ~/tmp/ip.now ~/tmp/ip.orig|wc -l`
if [ ${cnt} == "0" ]; then
    echo "No Change."
    rm -f ~/tmp/ip.now
    logger -t 'IP_Check' 'No Change.'
else
    echo "It's reNew..."
    mv -f ~/tmp/ip.now ~/tmp/ip.orig
    echo "Done."
    logger -t 'IP_Check' 'meet Server change IP: ${nowIP}.'
    sendNotify
fi
