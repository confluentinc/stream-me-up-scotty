#!/bin/sh

echo "Starting..." >> startup.log
echo "Updating yum..." >> startup.log
sudo yum update -y
echo "Updated yum." >> startup.log
echo "Installing docker..." >> startup.log
sudo yum install docker -y
echo "Docker installed." >> startup.log
echo "Starting docker service..." >> startup.log
sudo service docker start
echo "Docker service started." >> startup.log
echo "Starting postgres container..." >> startup.log
sudo docker run -p 5432:5432 --name postgres -d zachhamilton/rt-dwh-postgres-customers
echo "Started postgres container in the background." >> startup.log
echo "Starting postgres readiness checks..." >> startup.log
PG_READY=1
while [ $PG_READY -ne 0 ]; do
    sudo docker exec postgres pg_isready
    PG_READY=$?
    sleep 1
done
echo "Completed postgres readniness checks." >> startup.log
echo "Starting postgres procedures..." >> startup.log
echo "Starting shuffle_customers()..." >> startup.log
sudo docker exec -d postgres psql -U postgres -c 'CALL customers.shuffle_customers();'
echo "Starting shuffle_demographics()..." >> startup.log 
sudo docker exec -d postgres psql -U postgres -c 'CALL customers.shuffle_demographics();'
echo "Started postgres procedures in the background." >> startup.log
echo "Done..." >> startup.log