for i in {0..100}
do
 USER=`sh ../generate-user.sh $i`
 echo $USER | \
  docker exec -i ibmmq /opt/mqm/samp/bin/amqsput DEV.QUEUE.1 
done


