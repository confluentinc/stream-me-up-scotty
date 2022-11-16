
source ./utils.sh

# Need to create the TIBCO EMS image using https://github.com/mikeschippers/docker-tibco
DIR=`dirname $0`

if [ ! -f ${DIR}/docker-tibco/TIB_ems-ce_8.6.0_linux_x86_64.zip ]
then
     logerror "ERROR: ${DIR}/docker-tibco/ does not contain TIBCO EMS zip file TIB_ems-ce_8.6.0_linux_x86_64.zip"
     exit 1
fi

if [ ! -f ${DIR}/tibjms.jar ]
then
     log "${DIR}/tibjms.jar missing, will get it from ${DIR}/docker-tibco/TIB_ems-ce_8.6.0_linux_x86_64.zip"
     rm -rf /tmp/TIB_ems-ce_8.6.0
     unzip ${DIR}/docker-tibco/TIB_ems-ce_8.6.0_linux_x86_64.zip -d /tmp/
     tar xvfz /tmp/TIB_ems-ce_8.6.0/tar/TIB_ems-ce_8.6.0_linux_x86_64-java_client.tar.gz opt/tibco/ems/8.6/lib/tibjms.jar
     cp ${DIR}/opt/tibco/ems/8.6/lib/tibjms.jar ${DIR}/
     rm -rf ${DIR}/opt
fi

if test -z "$(docker images -q tibems:latest)"
then
     log "Building TIBCO EMS docker image..it can take a while..."
     OLDDIR=$PWD
     cd ${DIR}/docker-tibco
     docker build -t tibbase:1.0.0 ./tibbase
     docker build -t tibems:latest . -f ./tibems/Dockerfile
     cd ${OLDDIR}
fi
