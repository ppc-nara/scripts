#!/bin/bash

SYSADMINS=nara-sysadmins@ppc.com
NOREPLY=noreply@nara.ppc-cloud.com
S3DIR=s3://nara-logs/aidechecks
DATE=$(date +"%m%d%y")
AIDEDIR=/aidechecks


/usr/sbin/aide --check > $AIDEDIR/aidecheck.out
sleep 3m
cd $AIDEDIR
mv aidecheck.out $HOSTNAME-$DATE-aidereport.out

tar -cpzf $HOSTNAME_$DATE_aidecheck.tar.gz $HOSTNAME-$DATE-aidereport.out
mv .tar.gz $HOSTNAME-$DATE-aidereport.tar.gz

s3cmd --config=/root/.s3cfg put $AIDEDIR/$HOSTNAME-$DATE-aidereport.tar.gz $S3DIR/
s3cmd --config=/root/.s3cfg info $S3DIR/$HOSTNAME-$DATE-aidereport.tar.gz >/dev/null 2>&1
if [ $? -eq 0 ]
then
rm -rf $AIDEDIR/*
exit
else "AIDE Daily Integrity Check for system $HOSTNAME has failed to upload." | mail -s "AIDE Upload Failure - $HOSTNAME" -r $NOREPLY $SYSADMINS
fi
