TRANSACTION=`sh ../generate-transaction.sh`

curl -XPOST -u admin:admin -d "body=$TRANSACTION" http://localhost:8161/api/message/DEV.QUEUE.1?type=queue
