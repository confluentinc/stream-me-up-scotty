#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

if [ ! -f ${DIR}/com.ibm.mq.allclient.jar ]
then
     # install deps
     echo "Getting com.ibm.mq.allclient.jar and jms.jar from 9.0.0.10-IBM-MQ-Install-Java-All.jar"
     docker run --rm -v ${DIR}/9.0.0.10-IBM-MQ-Install-Java-All.jar:/tmp/9.0.0.10-IBM-MQ-Install-Java-All.jar -v ${DIR}/install:/tmp/install openjdk:8 java -jar /tmp/9.0.0.10-IBM-MQ-Install-Java-All.jar --acceptLicense /tmp/install
     cp ${DIR}/install/wmq/JavaSE/jms.jar ${DIR}/jars
     cp ${DIR}/install/wmq/JavaSE/com.ibm.mq.allclient.jar ${DIR}/jars
     rm -rf ${DIR}/install
fi

