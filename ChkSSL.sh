
#!/bin/bash
# This is install on server that have config auto SSL
# crontab daily check it

if [ ! -e "~/tmp/ssl-old.txt" ]; then
    touch ~/tmp/ssl-old.txt
fi
SSL_Chk=`cat ~/tmp/ssl-old.txt`
SSL_Now=`ls -laort ~/ssl/certs/ssl_*.crt|tail -1|awk '{print $8}'`
#echo $SSL_Chk
#echo $SSL_Now
if [ ${SSL_Now} == ${SSL_Chk} ]; then
    echo "`date +%Y-%m-%d` No Changed."
else
    echo "`date +%Y-%m-%d` Changed!"
    rm -f ~/tmp/ssl-old.txt ~/www/ssl-now.tgz ~/www/ssl-now.md5
    cp ${SSL_Now} ~/tmp/ssl/ssl.crt
    SSK_Key=`ls -laort ~/ssl/keys/*.key|tail -1|awk '{print $8}'`
    cp ${SSK_Key} ~/tmp/ssl/ssl.key
    echo ${SSL_Now} > ~/tmp/ssl-old.txt
    cd ~/tmp/ssl; tar zcf ~/www/ssl-now.tgz *
    md5sum ssl.crt > ~/www/ssl-now.md5
    rm -f ~/tmp/ssl/*
fi
