#!/bin/bash
# This script needs to be run with bash, not sh. sh doesn't support all the flags used in some of these commands. 

echo "👋" "This script is going to request some inputs to do the basic information gathering and setup necessary to get started."

# Create the directories to store configs and credentials for accessibility
if ! [ -d '.config' ]
then
    mkdir .config
    echo "{}" > .config/confluent-cloud.json
    echo "{}" > .config/confluent-creds.json
fi
if ! [ -d '.secrets' ]
then
    mkdir .secrets
fi

# Check if CCloud exists, if not, download it and add to PATH.
if ! command -v ccloud > /dev/null
then
    echo "🙄" 'CCloud CLI not found, downloading.'
    curl -sL --http1.1 https://cnfl.io/ccloud-cli | sh -s -- latest -b ~/ccloudcli/
    if [ -e ~/ccloudcli/ccloud ]
    then
        echo "🤩" 'Done. Exporting to PATH.'
        export PATH=~/ccloudcli/:$PATH;
        echo "🤩" 'Done.'
    fi
else
    echo "🤩" 'CCloud CLI found.'
fi

# Login to CCloud to create some stuff.
# TODO only ask each time if credentials weren't previously saved
echo "💻" "In order to create some topics, keys, and other fun stuff, please login to CCloud."
read -p "Save username/password for later? (yes/no): " CAN_SAVE_USR_PSWD
if [ $CAN_SAVE_USR_PSWD = "yes" ] || [ $CAN_SAVE_USR_PSWD = "y" ]
then
    ccloud login --save
else if [ $CAN_SAVE_USR_PSWD = "no" ] || [ $CAN_SAVE_USR_PSWD = "n" ]
    then
        ccloud login
    else
        echo "💀" "Needed a 'yes' or 'no' answer."
        exit
    fi
fi

# Check for environments and select one to use.
# TODO add an option to create an environment
ENVIRONMENTS=$(ccloud environment list -o json | jq -c '.')
if ! [ -z $(echo $ENVIRONMENTS | jq -c '.[] | select(.name == "default")') ]
then
    # Default exvironment exists
    echo $ENVIRONMENTS | jq -cC '.[]'
    echo "💻" "Specify an environment by ID to use. Press enter to use the 'default' or copy-paste an ID from above, then press enter to use it."
    read -p "Environment ID (default): " INPUT_ENVIRONMENT_ID
    if [ -z $INPUT_ENVIRONMENT_ID ]
    then
        # Use default
        ENVIRONMENT_ID=$(echo $ENVIRONMENTS | jq -cr '.[] | select(.name == "default").id ')
        ccloud environment use $ENVIRONMENT_ID
        echo "👆" "Using '$ENVIRONMENT_ID' going forward."
        echo $(cat .config/confluent-cloud.json | jq --arg environment_id $ENVIRONMENT_ID '. + {environment_id: $environment_id}') > .config/confluent-cloud.json
    else
        # TODO add check for incorrect values
        # Use specified
        ENVIRONMENT_ID=$INPUT_ENVIRONMENT_ID
        ccloud environment use $ENVIRONMENT_ID
        echo "👆" "Using '$ENVIRONMENT_ID' going forward."
        echo $(cat .config/confluent-cloud.json | jq --arg environment_id $ENVIRONMENT_ID '. + {environment_id: $environment_id}') > .config/confluent-cloud.json
    fi
else
    # Default exvironment doesn't exist
    echo $ENVIRONMENTS | jq -cC '.[]'
    echo "💻" "Specify an environment by ID to use by copy-pasting an ID from above, then pressing enter to use it."
    read -p "Environment ID: " INPUT_ENVIRONMENT_ID
    # TODO add check for incorrect values
    # Use specified
    ENVIRONMENT_ID=$INPUT_ENVIRONMENT_ID
    ccloud environment use $ENVIRONMENT_ID
    echo "👆" "Using '$ENVIRONMENT_ID' going forward."
    echo $(cat .config/confluent-cloud.json | jq --arg environment_id $ENVIRONMENT_ID '. + {environment_id: $environment_id}') > .config/confluent-cloud.json
fi

# Create the cluster
KAFKA_CLUSTERS=$(ccloud kafka cluster list -o json | jq -c '.')
# Check if cluster already exists.
if [ -z $(cat .config/confluent-cloud.json | jq '.cluster.id') ] || [ $(cat .config/confluent-cloud.json | jq '.cluster.id') = "null" ]
then 
    # No config saved, create a cluster.
    echo "💻" "Time to create a cluster that you can use."
    read -p "Cool to create the cluster? (yes/no): " CLUSTER_CAN_CREATE
    if [ $CLUSTER_CAN_CREATE = "yes" ] || [ $CLUSTER_CAN_CREATE = "y" ]
    then
        echo "👍" "Creating a new cluster.  This will default to a 'basic' cluster on GCP."
        KAFKA_CLUSTER=$(ccloud kafka cluster create -o json 'application-modernization' --cloud 'gcp' --region 'us-west4')
        echo $KAFKA_CLUSTER | jq '.'
        echo "👆" "Here's your newly created cluster. Saving the properties."
        KAFKA_CLUSTER_ID=$(echo $KAFKA_CLUSTER | jq -cr '.id')
        BOOTSTRAP_SERVERS=$(echo $KAFKA_CLUSTER | jq -cr '.endpoint' | sed 's/SASL_SSL:\/\///g')
        echo $(cat .config/confluent-cloud.json | jq --arg id $KAFKA_CLUSTER_ID '. * {cluster: { id: $id }}') > .config/confluent-cloud.json
        echo $(cat .config/confluent-cloud.json | jq --arg bootstrap_servers $BOOTSTRAP_SERVERS '. * {cluster: { bootstrap_servers: $bootstrap_servers }}') > .config/confluent-cloud.json
        echo "💻" "Setting your new cluster as the current active cluster."
        ccloud kafka cluster use $KAFKA_CLUSTER_ID
        echo "👆" "Using '$KAFKA_CLUSTER_ID' going forward."
        echo -n $BOOTSTRAP_SERVERS > .secrets/BOOTSTRAP_SERVERS
        echo "🤩" "Done."
    else if [ $CLUSTER_CAN_CREATE = "no" ] || [ $CLUSTER_CAN_CREATE = "n" ]
        then 
            echo "💀" "You need one to proceed. Sorry."
            echo "Bye"
            exit
        else
            echo "💀" "Needed a 'yes' or 'no' answer."
            exit
        fi
    fi
else 
    KAFKA_CLUSTER_ID=$(cat .config/confluent-cloud.json | jq -r '.cluster.id')
    # If a config exists, check if a cluster with the same ID exists in ccloud.
    if ! [ -z $(echo $KAFKA_CLUSTERS | jq -c --arg id $KAFKA_CLUSTER_ID '.[] | select(.id == $id )') ]
    then
        # Cluster with the same ID found in ccloud.
        echo "🤩" "Kafka cluster already created and exists."
    else
        # No cluster with the same ID found in ccloud. Create a new one. 
        echo "💻" "Found a previously created cluster ID, but didn't find it in your environment. Creating a separate one."
        read -p "Cool to create the cluster? (yes/no): " CLUSTER_CAN_CREATE
        if [ $CLUSTER_CAN_CREATE = "yes" ] || [ $CLUSTER_CAN_CREATE = "y" ]
        then
            echo "👍" "Creating a new cluster.  This will default to a 'basic' cluster on GCP."
            KAFKA_CLUSTER=$(ccloud kafka cluster create -o json 'application-modernization' --cloud 'gcp' --region 'us-west4')
            echo $KAFKA_CLUSTER | jq '.'
            echo "👆" "Here's your newly created cluster. Saving the properties."
            KAFKA_CLUSTER_ID=$(echo $KAFKA_CLUSTER | jq -cr '.id')
            BOOTSTRAP_SERVERS=$(echo $KAFKA_CLUSTER | jq -cr '.endpoint' | sed 's/SASL_SSL:\/\///g')
            echo $(cat .config/confluent-cloud.json | jq --arg id $KAFKA_CLUSTER_ID '. * {cluster: { id: $id }}') > .config/confluent-cloud.json
            echo $(cat .config/confluent-cloud.json | jq --arg bootstrap_servers $BOOTSTRAP_SERVERS '. * {cluster: { bootstrap_servers: $bootstrap_servers }}') > .config/confluent-cloud.json
            echo "💻" "Setting your new cluster as the current active cluster."
            ccloud kafka cluster use $KAFKA_CLUSTER_ID
            echo "👆" "Using '$KAFKA_CLUSTER_ID' going forward."
            echo -n $BOOTSTRAP_SERVERS > .secrets/BOOTSTRAP_SERVERS
            echo "🤩" "Done."
        else if [ $CLUSTER_CAN_CREATE = "no" ] || [ $CLUSTER_CAN_CREATE = "n" ]
            then 
                echo "💀" "You need one to proceed. Sorry."
                echo "Bye"
                exit
            else
                echo "💀" "Needed a 'yes' or 'no' answer."
                exit
            fi
        fi
    fi
fi

# Enable Schema Registry in the environment if it isn't already.
echo "💻" "Checking to see if Schema Registry is already enabled for this environment."
ccloud schema-registry cluster describe &> /dev/null
if [ $? -eq 0 ]
then
    echo "💻" "Schema Registry already enabled for this environment."
    SCHEMA_REGISTRY=$(ccloud schema-registry cluster describe -o json | jq -c '.')
    echo $SCHEMA_REGISTRY | jq '.'
    echo "👆" "This is the Schema Registry cluster already enabled. Saving its properties."
    SCHEMA_REGISTRY_CLUSTER_ID=$(echo $SCHEMA_REGISTRY | jq -cr '.cluster_id')
    SCHEMA_REGISTRY_URL=$(echo $SCHEMA_REGISTRY | jq -cr '.endpoint_url')
    echo $(cat .config/confluent-cloud.json | jq --arg cluster_id $SCHEMA_REGISTRY_CLUSTER_ID '. * {schema_reigstry: { cluster_id: $cluster_id }}') > .config/confluent-cloud.json
    echo $(cat .config/confluent-cloud.json | jq --arg endpoint_url $SCHEMA_REGISTRY_URL '. * {schema_reigstry: { endpoint_url: $endpoint_url }}') > .config/confluent-cloud.json
    echo -n $SCHEMA_REGISTRY_URL > .secrets/SCHEMA_REGISTRY_URL
    echo "🤩" "Schema Registry done."
else
    echo "💻" "Schema Registry not yet enabled. Enabling it in the US on GCP."
    SCHEMA_REGISTRY=$(ccloud schema-registry cluster enable -o json --cloud 'gcp' --geo 'us' | jq -c '.')
    echo $SCHEMA_REGISTRY | jq '.'
    echo "👆" "This will be the Schema Registry you'll use going forward. Saving its properties."
    SCHEMA_REGISTRY_CLUSTER_ID=$(echo $SCHEMA_REGISTRY | jq -cr '.cluster_id')
    SCHEMA_REGISTRY_URL=$(echo $SCHEMA_REGISTRY | jq -cr '.endpoint_url')
    echo $(cat .config/confluent-cloud.json | jq --arg cluster_id $SCHEMA_REGISTRY_CLUSTER_ID '. * {schema_reigstry: { cluster_id: $cluster_id }}') > .config/confluent-cloud.json
    echo $(cat .config/confluent-cloud.json | jq --arg endpoint_url $SCHEMA_REGISTRY_URL '. * {schema_reigstry: { endpoint_url: $endpoint_url }}') > .config/confluent-cloud.json
    echo -n $SCHEMA_REGISTRY_URL > .secrets/SCHEMA_REGISTRY_URL
    echo "🤩" "Done enabling Schema Registry."
fi


# Check for credentials and skip or move on.
KEYS=$(ccloud api-key list -o json | jq -c '.')
echo "💻" "Checking for existing credentials for previously created clusters."
# Check for client credentials.
if [ -z $(cat .config/confluent-creds.json | jq '.client.key') ] || [ $(cat .config/confluent-creds.json | jq '.client.key') = "null" ]
then
    # No existing client credentials found. Create credentials clients. 
    # Credentials for clients to auth with the cluster.
    echo "💻" "No credentials found for Kafka Clients. Creating them."
    CLIENT_CREDS=$(ccloud api-key create -o json --resource $KAFKA_CLUSTER_ID --description "API Keys for AppMods Kafka Clients" | jq -c '.')
    CLIENT_KEY=$(echo $CLIENT_CREDS | jq -r '.key')
    CLIENT_SECRET=$(echo $CLIENT_CREDS | jq -r '.secret')
    echo "API Key: " $CLIENT_KEY
    echo "API Secret: " $CLIENT_SECRET
    echo "👆" "Saving these for use later."
    echo $(cat .config/confluent-creds.json | jq --arg key $CLIENT_KEY '. * {client: { key: $key }}') > .config/confluent-creds.json
    echo $(cat .config/confluent-creds.json | jq --arg secret $CLIENT_SECRET '. * {client: { secret: $secret }}') > .config/confluent-creds.json
    echo -n $CLIENT_KEY > .secrets/CLIENT_KEY
    echo -n $CLIENT_SECRET > .secrets/CLIENT_SECRET
    echo -n "org.apache.kafka.common.security.plain.PlainLoginModule required username='$CLIENT_KEY' password='$CLIENT_SECRET';" > .secrets/SASL_JAAS_CONFIG
else
    # Previously created keys saved, check if they still exist.
    CLIENT_KEY=$(cat .config/confluent-creds.json | jq -r '.client.key')
    if ! [ -z $(echo $KEYS | jq -c --arg key $CLIENT_KEY '.[] | select(.key == $key).key') ]
    then
        echo "🤩" "Kafka client credentials already created and exist."
        CLIENT_KEY=$(cat .config/confluent-creds.json | jq -r '.client.key')
        CLIENT_SECRET=$(cat .config/confluent-creds.json | jq -r '.client.secret')
    else
        echo "💻" "Found a previously created client credentials, but didn't find them in your environment. Creating new ones."
        CLIENT_CREDS=$(ccloud api-key create -o json --resource $KAFKA_CLUSTER_ID --description "API Keys for AppMods Kafka Clients" | jq -c '.')
        CLIENT_KEY=$(echo $CLIENT_CREDS | jq -r '.key')
        CLIENT_SECRET=$(echo $CLIENT_CREDS | jq -r '.secret')
        echo "API Key: " $CLIENT_KEY
        echo "API Secret: " $CLIENT_SECRET
        echo "👆" "Saving these for use later."
        echo $(cat .config/confluent-creds.json | jq --arg key $CLIENT_KEY '. * {client: { key: $key }}') > .config/confluent-creds.json
        echo $(cat .config/confluent-creds.json | jq --arg secret $CLIENT_SECRET '. * {client: { secret: $secret }}') > .config/confluent-creds.json
        echo -n $CLIENT_KEY > .secrets/CLIENT_KEY
        echo -n $CLIENT_SECRET > .secrets/CLIENT_SECRET
        echo -n "org.apache.kafka.common.security.plain.PlainLoginModule required username='$CLIENT_KEY' password='$CLIENT_SECRET';" > .secrets/SASL_JAAS_CONFIG
    fi
fi

# Check for ksqldb credentials.
if [ -z $(cat .config/confluent-creds.json | jq '.ksqldb.kafka.key') ] || [ $(cat .config/confluent-creds.json | jq '.ksqldb.kafka.key') = "null" ]
then
    # No existing ksqldb credentials found. Create credentials clients. 
    # Credentials for ksqldb to auth with the cluster.
    echo "💻" "No credentials found for ksqlDB. Creating them."
    KSQLDB_CREDS=$(ccloud api-key create -o json --resource $KAFKA_CLUSTER_ID --description "API Keys for AppMods ksqlDB App" | jq -c '.')
    KSQLDB_KEY=$(echo $KSQLDB_CREDS | jq -r '.key')
    KSQLDB_SECRET=$(echo $KSQLDB_CREDS | jq -r '.secret')
    echo "API Key: " $KSQLDB_KEY
    echo "API Secret: " $KSQLDB_SECRET
    echo "👆" "Saving these for use later."
    echo $(cat .config/confluent-creds.json | jq --arg key $KSQLDB_KEY '. * {ksqldb: { kafka: { key: $key }}}') > .config/confluent-creds.json
    echo $(cat .config/confluent-creds.json | jq --arg secret $KSQLDB_SECRET '. * {ksqldb: { kafka: { secret: $secret }}}') > .config/confluent-creds.json
    echo -n $KSQLDB_KEY > .secrets/KSQLDB_KEY
    echo -n $KSQLDB_SECRET > .secrets/KSQLDB_SECRET
else
    # Previously created keys saved, check if they still exist.
    KSQLDB_KEY=$(cat .config/confluent-creds.json | jq -r '.ksqldb.kafka.key')
    if ! [ -z $(echo $KEYS | jq -c --arg key $KSQLDB_KEY '.[] | select(.key == $key).key') ]
    then
        echo "🤩" "ksqlDB credentials already created and exist."
        KSQLDB_KEY=$(cat .config/confluent-creds.json | jq -r '.ksqldb.kafka.key')
        KSQLDB_SECRET=$(cat .config/confluent-creds.json | jq -r '.ksqldb.kafka.secret')
    else
        echo "💻" "Found a previously created ksqlDB credentials, but didn't find them in your environment. Creating new ones."
        KSQLDB_CREDS=$(ccloud api-key create -o json --resource $KAFKA_CLUSTER_ID --description "API Keys for AppMods Kafka Clients" | jq -c '.')
        KSQLDB_KEY=$(echo $KSQLDB_CREDS | jq -r '.key')
        KSQLDB_SECRET=$(echo $KSQLDB_CREDS | jq -r '.secret')
        echo "API Key: " $KSQLDB_KEY
        echo "API Secret: " $KSQLDB_SECRET
        echo "👆" "Saving these for use later."
        echo $(cat .config/confluent-creds.json | jq --arg key $KSQLDB_KEY '. * { ksqldb: { kafka: { key: $key }}}') > .config/confluent-creds.json
        echo $(cat .config/confluent-creds.json | jq --arg secret $KSQLDB_SECRET '. * { ksqldb: { kafka: { secret: $secret }}}') > .config/confluent-creds.json
        echo -n $KSQLDB_KEY > .secrets/KSQLDB_KEY
        echo -n $KSQLDB_SECRET > .secrets/KSQLDB_SECRET
    fi
fi

# Create the ksqldb app.
KSQLDB_APPS=$(ccloud ksql app list -o json | jq -c '.')
# Check if ksqldb app already exists.
if [ -z $(cat .config/confluent-cloud.json | jq '.ksqldb.id') ] || [ $(cat .config/confluent-cloud.json | jq '.ksqldb.id') = "null" ]
then 
    # No config saved, create a ksqldb app.
    echo "💻" "Time to create a ksqlDB app that you can use."
    read -p "Cool to create the ksqlDB app? (yes/no): " KSQLDB_CAN_CREATE
    if [ $KSQLDB_CAN_CREATE = "yes" ] || [ $KSQLDB_CAN_CREATE = "y" ]
    then
        echo "👍" "Creating a new ksqlDB app.  This will default to the minimum size of 4 CSUs."
        KSQLDB_APP=$(ccloud ksql app create -o json ksqldb-appmod --csu 4 --api-key $KSQLDB_KEY --api-secret $KSQLDB_SECRET)
        echo $KSQLDB_APP | jq '.'
        echo "👆" "Here's your newly created ksqlDB app. Saving the properties."
        KSQLDB_APP_ID=$(echo $KSQLDB_APP | jq -cr '.id')
        KSQLDB_APP_ENDPOINT=$(echo $KSQLDB_APP | jq -cr '.endpoint')
        echo $(cat .config/confluent-cloud.json | jq --arg id $KSQLDB_APP_ID '. * {ksqldb: { id: $id }}') > .config/confluent-cloud.json
        echo $(cat .config/confluent-cloud.json | jq --arg endpoint $KSQLDB_APP_ENDPOINT '. * { ksqldb: { endpoint: $endpoint }}') > .config/confluent-cloud.json
        echo -n $KSQLDB_APP_ENDPOINT > .secrets/KSQLDB_APP_ENDPOINT
        echo "🤩" "Done creating ksqlDB app."
    else if [ $KSQLDB_CAN_CREATE = "no" ] || [ $KSQLDB_CAN_CREATE = "n" ]
        then 
            echo "💀" "You need one to proceed. Sorry."
            echo "Bye"
            exit
        else
            echo "💀" "Needed a 'yes' or 'no' answer."
            exit
        fi
    fi
else 
    KSQLDB_APP_ID=$(cat .config/confluent-cloud.json | jq -r '.ksqldb.id')
    # If a config exists, check if a ksqldb app with the same ID exists in ccloud.
    if ! [ -z $(echo $KSQLDB_APPS | jq -c --arg id $KSQLDB_APP_ID '.[] | select(.id == $id )') ]
    then
        # Cluster with the same ID found in ccloud.
        echo "🤩" "ksqlDB app already created and exists."
    else
        # No ksqldb app with the same ID found in ccloud. Create a new one. 
        echo "💻" "Found a previously created ksqldb app ID, but didn't find it in your environment. Creating a separate one."
        read -p "Cool to create the ksqlDB app? (yes/no): " KSQLDB_CAN_CREATE
        if [ $KSQLDB_CAN_CREATE = "yes" ] || [ $KSQLDB_CAN_CREATE = "y" ]
        then
            echo "👍" "Creating a new ksqlDB app.  This will default to the minimum size of 4 CSUs."
            KSQLDB_APP=$(ccloud ksql app create -o json ksqldb-appmod --csu 4 --api-key $KSQLDB_KEY --api-secret $KSQLDB_SECRET)
            echo $KSQLDB_APP | jq '.'
            echo "👆" "Here's your newly created ksqlDB app. Saving the properties."
            KSQLDB_APP_ID=$(echo $KSQLDB_APP | jq -cr '.id')
            KSQLDB_APP_ENDPOINT=$(echo $KSQLDB_APP | jq -cr '.endpoint')
            echo $(cat .config/confluent-cloud.json | jq --arg id $KSQLDB_APP_ID '. * {ksqldb: { id: $id }}') > .config/confluent-cloud.json
            echo $(cat .config/confluent-cloud.json | jq --arg endpoint $KSQLDB_APP_ENDPOINT '. * { ksqldb: { endpoint: $endpoint }}') > .config/confluent-cloud.json
            echo -n $KSQLDB_APP_ENDPOINT > .secrets/KSQLDB_APP_ENDPOINT
            echo "🤩" "Done creating ksqlDB app."
        else if [ $KSQLDB_CAN_CREATE = "no" ] || [ $KSQLDB_CAN_CREATE = "n" ]
            then 
                echo "💀" "You need one to proceed. Sorry."
                echo "Bye"
                exit
            else
                echo "💀" "Needed a 'yes' or 'no' answer."
                exit
            fi
        fi
    fi
fi

# Create necessary Kafka topics.
if [ "$(cat .config/confluent-cloud.json | jq '.cluster.topics')" = "null" ] || [ $(cat .config/confluent-cloud.json | jq '.cluster.topics | length') -lt 4 ]
then    
    # No topics in the config, creating them
    echo "💻" "Creating a few topics needed for the connectors and apps."
    # Check cluster availability / wait for the cluster to be available.
    echo "💻" "Checking the status of the cluster first."
    CLUSTER_STATUS=$(ccloud kafka cluster describe -o json $KAFKA_CLUSTER_ID | jq -r '.status')
    while [ "$CLUSTER_STATUS" != "UP" ]
    do
        echo "😴" "Cluster not yet 'UP'. Waiting..."
        CLUSTER_STATUS=$(ccloud kafka cluster describe -o json $KAFKA_CLUSTER_ID | jq -r '.status')
        sleep 2
    done
    if [ "$CLUSTER_STATUS" = "UP" ]
    then
        echo "🤩" "Cluster is 'UP'."
        echo $(cat .config/confluent-cloud.json | jq '. * { cluster: { topics: []}}') > .config/confluent-cloud.json
        CREATE_TOPICS=( "postgres.bank.customers" "postgres.bank.accounts" "postgres.bank.transactions" "express.bank.transactions" )
        for TOPIC in ${CREATE_TOPICS[@]}; 
        do
            ccloud kafka topic create $TOPIC
            echo $(cat .config/confluent-cloud.json | jq --arg topic $TOPIC '.cluster.topics += [{ topic: $topic }]') > .config/confluent-cloud.json
        done
        echo "🤩" "Created the necessary topics."
    # else # TODO some other condition if possible
    fi
else
    # Topic configs found, checking ccloud for them
    echo "💻" "Found existing topic config. Checking ccloud for it."
    echo "💻" "Checking the status of the cluster first."
    CLUSTER_STATUS=$(ccloud kafka cluster describe -o json $KAFKA_CLUSTER_ID | jq -r '.status')
    while [ "$CLUSTER_STATUS" != "UP" ]
    do
        echo "😴" "Cluster not yet 'UP'. Waiting..."
        CLUSTER_STATUS=$(ccloud kafka cluster describe -o json $KAFKA_CLUSTER_ID | jq -r '.status')
        sleep 2
    done
    if [ "$CLUSTER_STATUS" = "UP" ]
    then
        echo "🤩" "Cluster is 'UP'."
        CREATE_TOPICS=( "postgres.bank.customers" "postgres.bank.accounts" "postgres.bank.transactions" "express.bank.transactions" )
        TOPICS=$(ccloud kafka topic list -o json | jq -c '.')
        for DESIRED_TOPIC in ${CREATE_TOPICS[@]};
        do
            # Check if a given desired topic exists
            if [ -z $(echo $TOPICS | jq -c --arg topic $DESIRED_TOPIC '.[] | select(.name == $topic)') ]
            then
                # Topic doesn't exist, create it
                echo "💻" "Found previously configured topic in the config, but not in ccloud. Creating it."
                ccloud kafka topic create $DESIRED_TOPIC
            else 
                # Topic does exist
                echo "🤩" "$TOPIC already exists."
            fi
        done
        echo "🤩" "Topics checked."
    # else # TODO some other condition if possible
    fi
fi


# Check for ksqldb api keys.
if [ -z $(cat .config/confluent-creds.json | jq '.ksqldb.api.key') ] || [ $(cat .config/confluent-creds.json | jq '.ksqldb.api.key') = "null" ]
then
    # No existing ksqldb api keys found. Create them. 
    # Api keys for clients to auth with the ksqldb api.
    echo "💻" "No API Keys found for ksqlDB. Creating them."
    KSQLDB_API_KEYS=$(ccloud api-key create -o json --resource $KSQLDB_APP_ID --description "API Keys for AppMods ksqlDB clients" | jq -c '.')
    KSQLDB_API_KEY=$(echo $KSQLDB_API_KEYS | jq -r '.key')
    KSQLDB_API_SECRET=$(echo $KSQLDB_API_KEYS | jq -r '.secret')
    echo "API Key: " $KSQLDB_API_KEY
    echo "API Secret: " $KSQLDB_API_SECRET
    echo "👆" "Saving these for use later."
    echo $(cat .config/confluent-creds.json | jq --arg key $KSQLDB_API_KEY '. * {ksqldb: { api: { key: $key }}}') > .config/confluent-creds.json
    echo $(cat .config/confluent-creds.json | jq --arg secret $KSQLDB_API_SECRET '. * {ksqldb: { api: { secret: $secret }}}') > .config/confluent-creds.json
    echo -n $KSQLDB_API_KEY > .secrets/KSQLDB_API_KEY
    echo -n $KSQLDB_API_SECRET > .secrets/KSQLDB_API_SECRET
else
    # Previously created keys saved, check if they still exist.
    KSQLDB_API_KEY=$(cat .config/confluent-creds.json | jq -r '.ksqldb.api.key')
    if ! [ -z $(echo $KEYS | jq -c --arg key $KSQLDB_API_KEY '.[] | select(.key == $key).key') ]
    then
        echo "🤩" "ksqlDB API Keys already created and exist."
        KSQLDB_KEY=$(cat .config/confluent-creds.json | jq -r '.ksqldb.api.key')
        KSQLDB_SECRET=$(cat .config/confluent-creds.json | jq -r '.ksqldb.api.secret')
    else
        echo "💻" "Found a previously created ksqlDB API Keys, but didn't find them in your environment. Creating new ones."
        KSQLDB_API_KEYS=$(ccloud api-key create -o json --resource $KSQLDB_APP_ID --description "API Keys for AppMods ksqlDB clients" | jq -c '.')
        KSQLDB_API_KEY=$(echo $KSQLDB_API_KEYS | jq -r '.key')
        KSQLDB_API_SECRET=$(echo $KSQLDB_API_KEYS | jq -r '.secret')
        echo "API Key: " $KSQLDB_API_KEY
        echo "API Secret: " $KSQLDB_API_SECRET
        echo "👆" "Saving these for use later."
        echo $(cat .config/confluent-creds.json | jq --arg key $KSQLDB_API_KEY '. * { ksqldb: { api: { key: $key }}}') > .config/confluent-creds.json
        echo $(cat .config/confluent-creds.json | jq --arg secret $KSQLDB_API_SECRET '. * { ksqldb: { api: { secret: $secret }}}') > .config/confluent-creds.json
        echo -n $KSQLDB_API_KEY > .secrets/KSQLDB_API_KEY
        echo -n $KSQLDB_API_SECRET > .secrets/KSQLDB_API_SECRET
    fi
fi

# Check for Schema Registry api keys.
if [ -z $(cat .config/confluent-creds.json | jq '.schema_registry.api.key') ] || [ $(cat .config/confluent-creds.json | jq '.schema_registry.api.key') = "null" ]
then
    # No existing Schema Registry api keys found. Create them. 
    # Api keys for clients to auth with the Schema Registry api.
    echo "💻" "No API Keys found for Schema Registry. Creating them."
    SCHEMA_REGISTRY_API_KEYS=$(ccloud api-key create -o json --resource $SCHEMA_REGISTRY_CLUSTER_ID --description "API Keys for AppMods Schema Registry" | jq -c '.')
    SCHEMA_REGISTRY_API_KEY=$(echo $SCHEMA_REGISTRY_API_KEYS | jq -r '.key')
    SCHEMA_REGISTRY_API_SECRET=$(echo $SCHEMA_REGISTRY_API_KEYS | jq -r '.secret')
    echo "API Key: " $SCHEMA_REGISTRY_API_KEY
    echo "API Secret: " $SCHEMA_REGISTRY_API_SECRET
    echo "👆" "Saving these for use later."
    echo $(cat .config/confluent-creds.json | jq --arg key $SCHEMA_REGISTRY_API_KEY '. * {schema_registry: { api: { key: $key }}}') > .config/confluent-creds.json
    echo $(cat .config/confluent-creds.json | jq --arg secret $SCHEMA_REGISTRY_API_SECRET '. * {schema_registry: { api: { secret: $secret }}}') > .config/confluent-creds.json
    echo -n $SCHEMA_REGISTRY_API_KEY > .secrets/SCHEMA_REGISTRY_API_KEY
    echo -n $SCHEMA_REGISTRY_API_SECRET > .secrets/SCHEMA_REGISTRY_API_SECRET
    echo -n "$SCHEMA_REGISTRY_API_KEY:$SCHEMA_REGISTRY_API_SECRET" > .secrets/SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO
else
    # Previously created keys saved, check if they still exist.
    SCHEMA_REGISTRY_API_KEY=$(cat .config/confluent-creds.json | jq -r '.schema_registry.api.key')
    if ! [ -z $(echo $KEYS | jq -c --arg key $SCHEMA_REGISTRY_API_KEY '.[] | select(.key == $key).key') ]
    then
        echo "🤩" "Schema Registry API Keys already created and exist."
        KSQLDB_KEY=$(cat .config/confluent-creds.json | jq -r '.schema_registry.api.key')
        KSQLDB_SECRET=$(cat .config/confluent-creds.json | jq -r '.schema_registry.api.secret')
    else
        echo "💻" "Found a previously created Schema Registry API Keys, but didn't find them in your environment. Creating new ones."
        SCHEMA_REGISTRY_API_KEYS=$(ccloud api-key create -o json --resource $KSQLDB_APP_ID --description "API Keys for AppMods Schema Registry" | jq -c '.')
        SCHEMA_REGISTRY_API_KEY=$(echo $SCHEMA_REGISTRY_API_KEYS | jq -r '.key')
        SCHEMA_REGISTRY_API_SECRET=$(echo $SCHEMA_REGISTRY_API_KEYS | jq -r '.secret')
        echo "API Key: " $SCHEMA_REGISTRY_API_KEY
        echo "API Secret: " $SCHEMA_REGISTRY_API_SECRET
        echo "👆" "Saving these for use later."
        echo $(cat .config/confluent-creds.json | jq --arg key $SCHEMA_REGISTRY_API_KEY '. * { schema_registry: { api: { key: $key }}}') > .config/confluent-creds.json
        echo $(cat .config/confluent-creds.json | jq --arg secret $SCHEMA_REGISTRY_API_SECRET '. * { schema_registry: { api: { secret: $secret }}}') > .config/confluent-creds.json
        echo -n $SCHEMA_REGISTRY_API_KEY > .secrets/SCHEMA_REGISTRY_API_KEY
        echo -n $SCHEMA_REGISTRY_API_SECRET > .secrets/SCHEMA_REGISTRY_API_SECRET
        echo -n "$SCHEMA_REGISTRY_API_KEY:$SCHEMA_REGISTRY_API_SECRET" > .secrets/SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO
    fi
fi