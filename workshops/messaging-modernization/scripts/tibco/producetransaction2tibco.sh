#!/bin/bash
set -e

DIR=`dirname $0`
source ${DIR}/utils.sh

# generate-transaction.sh produces a valid json document
# with quotes. When tibjmsMsgProducer doesn't get a quoted value, it inserts
# multiple values to tibco, which makes the demo challenging. Challenge is to 
# properly escape the quotes and pass the document without invalidating
# this script. base64 encoding it, then decoding it in the container seems
# to sidestep the problem.

TRANS=`sh ../generate-transaction.sh | base64`
log "Sending EMS messages in queue connector-quickstart"
docker exec tibco-ems bash -c '
cd /opt/tibco/ems/8.6/samples/java
export TIBEMS_JAVA=/opt/tibco/ems/8.6/lib
CLASSPATH=${TIBEMS_JAVA}/jms-2.0.jar:${CLASSPATH}
CLASSPATH=.:${TIBEMS_JAVA}/tibjms.jar:${TIBEMS_JAVA}/tibjmsadmin.jar:${CLASSPATH}
export CLASSPATH
[ -f tibjmsMsgProducer.class ] || javac *.java
TRANSACTION=`echo '$TRANS' | base64 --decode`

java tibjmsMsgProducer -user admin -queue connector-quickstart "$TRANSACTION"'
