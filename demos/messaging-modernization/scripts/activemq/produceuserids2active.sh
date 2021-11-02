for i in {0..100}
do
 USER=`sh ../generate-user.sh $i`
 curl -XPOST -u admin:admin -d "body=$USER" http://localhost:8161/api/message/DEV.QUEUE.1?type=queue
done


