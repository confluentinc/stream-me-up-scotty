#!/bin/bash

HEADER="Content-Type: application/json"
DATA=$( cat << EOF
{
    "name": "mysql-cdc-source",
    "config": {
        "connector.class": "io.debezium.connector.mysql.MySqlConnector",
        "tasks.max": "1",
        "database.hostname": "mysql",
        "database.port": "3306",
        "database.user": "debezium",
        "database.password": "debezium",
        "database.server.name": "mysql",
        "database.include.list": "customers",
        "include.schema.changes": false,
        "table.include.list": "customers.customers,customers.demographics",
        "database.history.kafka.topic": "mysql.schemas",
        "database.history.kafka.bootstrap.servers": "${BOOTSTRAP_SERVERS}",
        "database.history.consumer.security.protocol": "SASL_SSL",
        "database.history.consumer.sasl.mechanism": "PLAIN",
        "database.history.consumer.sasl.jaas.config": "${SASL_JAAS_CONFIG}",
        "database.history.producer.security.protocol": "SASL_SSL",
        "database.history.producer.sasl.mechanism": "PLAIN",
        "database.history.producer.sasl.jaas.config": "${SASL_JAAS_CONFIG}"
    }
}
EOF
)

curl -X POST -H "${HEADER}" --data "${DATA}" http://localhost:8083/connectors | jq