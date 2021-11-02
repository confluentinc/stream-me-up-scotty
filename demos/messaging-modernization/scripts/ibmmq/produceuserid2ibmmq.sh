USER=`sh ../generate-user.sh 999`
echo $USER | \
 docker exec -i ibmmq /opt/mqm/samp/bin/amqsput DEV.QUEUE.1 
