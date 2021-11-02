for i in {0..100}
do
 USER64=`sh ../generate-user.sh $i | base64`
 docker exec tibco-ems bash -c '
 cd /opt/tibco/ems/8.6/samples/java
 export TIBEMS_JAVA=/opt/tibco/ems/8.6/lib
 CLASSPATH=${TIBEMS_JAVA}/jms-2.0.jar:${CLASSPATH}
 CLASSPATH=.:${TIBEMS_JAVA}/tibjms.jar:${TIBEMS_JAVA}/tibjmsadmin.jar:${CLASSPATH}
 export CLASSPATH
 [ -f tibjmsMsgProducer.class ] || javac *.java
 USER=`echo '$USER64' | base64 --decode`

 java tibjmsMsgProducer -user admin -queue connector-quickstart "$USER"' 
done
