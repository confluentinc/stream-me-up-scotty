TRANSACTION=`sh ../generate-transaction.sh`
echo $TRANSACTION | \
 docker exec -i ibmmq /opt/mqm/samp/bin/amqsput DEV.QUEUE.1 
