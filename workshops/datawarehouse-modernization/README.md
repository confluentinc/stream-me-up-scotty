<div align="center" padding=25px>
    <img src="images/confluent.png" width=50% height=50%>
</div>

# <div align="center">Real-time Data Warehouse Ingestion with Confluent Cloud</div>
## <div align="center">Workshop & Lab Guide</div>

## Background

The idea behind this workshop/lab guide is to provide a complete walk through of an example application that connects multiple external data sources to Confluent, joins their datasets together into one, and writes the new events to a data warehouse in real-time.

The core Confluent Cloud components that will be used to accomplish this will be:
- Kafka Connect
- Kafka
- KsqlDB
- Schema Registry

This repository is meant to either be presented as a walk through by a member of the Confluent team, used as a demonstration without guided hands-on, or as a collection of artifacts that you can build on your own. All of the code used is available within the repository. 

***

## Prerequisites

First thing you'll need is a Confluent Cloud account. If you already have one, you can skip this, otherwise, you can try this completely free of charge and without adding payment details. The following link will bring you to a sign up page to get started. 
- [Get Started with Confluent Cloud for Free](https://www.confluent.io/confluent-cloud/tryfree/).

As you can expect, there are some tools that will be required to be successful with this lab. Please have the following in order to take full advantage of this workshop/lab guide.
- Docker
- Terraform

In addition to the necessary tools, this lab will use those tools to create resources in the cloud provider of your choice (what will be created will be explicitly stated in steps where you create it). These resources are used to create the end-to-end flow of data. The following states necessary credentials for each respective cloud provider.
- AWS
    - A user account with an API Key and Secret Key.
    - Appropriate permissions in a non-prod environment to create resources.
- GCP 
    - A non-prod project within which resources can be created.
    - A user account with a JSON Key file.
    - Appropriate permissions within the non-prod project to create resources.
- Azure
    - TBD.

Finally, in order to sink data to a data warehouse in real-time, you'll need one of the following data warehousing technologies and the stated permissions. It is expected that you'll either have one of these two solutions already to use, or to follow the included documentation to have it provisioned to work with Confluent Cloud.
- Snowflake
    - [Current Limitations](https://docs.confluent.io/cloud/current/connectors/limits.html#snowflake-sink-connector).
- Databricks *(AWS only)*
    - Databricks running **within the same region that you will deploy your Kafka Cluster**.
    - An S3 bucket in which the Delta Lake Sink Connector can stage data (this is explained in the link below).
    - Please review and walk through the following documentation to verify the appropriate setup within AWS and Databricks.
        - [Set Up Databricks Delta Lake](https://docs.confluent.io/cloud/current/connectors/cc-databricks-delta-lake-sink/databricks-aws-setup.html).

***

## Step-by-Step

### Confluent Cloud Components

1. Clone and enter this repo.
    ```bash
    git clone https://github.com/zacharydhamilton/realtime-datawarehousing
    ```
    ```bash
    cd realtime-datawarehousing
    ```
1. Create a new "clipboard" file in the directory. Since a variety of credentials will be required, a place to keep track of them will be necessary. The following is the recommended approach. 
    ```bash 
    touch env.sh
    ```
    ```bash
    # Contents to create in env.sh ...

    # Confluent Creds
    export BOOTSTRAP_SERVERS="<replace>"
    export KAFKA_KEY="<replace>"
    export KAFKA_SECRET="<replace>"
    export SASL_JAAS_CONFIG="org.apache.kafka.common.security.plain.PlainLoginModule required username='$KAFKA_KEY' password='$KAFKA_SECRET';"
    export SCHEMA_REGISTRY_URL="<replace>"
    export SCHEMA_REGISTRY_KEY="<replace>"
    export SCHEMA_REGISTRY_SECRET="<replace>"
    export SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO="$SCHEMA_REGISTRY_KEY:$SCHEMA_REGISTRY_SECRET"
    export BASIC_AUTH_CREDENTIALS_SOURCE="USER_INFO"
    # AWS Creds for TF
    export AWS_ACCESS_KEY_ID="<replace>"
    export AWS_SECRET_ACCESS_KEY="<replace>"
    export AWS_DEFAULT_REGION="us-east-2" # You can change this, but make sure it's consistent
    # GCP Creds for TF
    export TF_VAR_GCP_PROJECT=""
    export TF_VAR_GCP_CREDENTIALS=""
    # Databricks
    export DATABRICKS_SERVER_HOSTNAME="<replace>"
    export DATABRICKS_HTTP_PATH="<replace>"
    export DATABRICKS_ACCESS_TOKEN="<replace>"
    export DELTA_LAKE_STAGING_BUCKET_NAME="<replace>"
    ```
    > **Note:** *The impetus behind the above is so that you can easily `sh env.sh` to have all the values available in the terminal.*

1. Create a cluster in Confluent Cloud. The recommended cluster type for this workshop/lab is either Basic/Standard.
    - [Create a Cluster in Confluent Cloud](https://docs.confluent.io/cloud/current/clusters/create-cluster.html).
    - Once the cluster is created, select its tile if you haven't, then select **Cluster overview > Cluster settings**. On the corresponding page, copy the value for **Bootstrap server** and paste it into your clipboard file under `BOOTSTRAP_SERVERS`. 

1. Create an API Key pair for for authentication to the cluster.
    - [Create API Keys](https://docs.confluent.io/cloud/current/access-management/authenticate/api-keys/api-keys.html#ccloud-api-keys).
    - Once the keys have been generated, copy the values of the key and secret into the values of `KAFKA_KEY` and `KAFKA_SECRET` in your clipboard file respectively. 

1. Enable a Schema Registry. If you already have Schema Registry enabled for your environment, you can skip this step.
    - [Enable Schema Registry](https://docs.confluent.io/cloud/current/get-started/schema-registry.html#enable-sr-for-ccloud).
    - Once Schema Registry is enabled for the environment, select the **Schema Registry** tab for the environment to find the **API endpoint**. Copy the API endpoint into your clipboard file under `SCHEMA_REGISTRY_URL`.

1. Create an API Key for authentication to Schema Registry. 
    - [Create Schema Registry API Keys](https://docs.confluent.io/cloud/current/get-started/schema-registry.html#create-an-api-key-for-ccloud-sr).
    - Once the Schema Registry keys have been generated, copy the values of the key and secret into the values of `SCHEMA_REGISTRY_KEY` and `SCHEMA_REGISTRY_SECRET` in your clipboard file respectively. 

1. Create a ksqlDB cluster in Confluent Cloud. 
    - [Create a ksqlDB Cluster](https://docs.confluent.io/cloud/current/get-started/ksql.html#create-a-ksql-cloud-cluster-in-ccloud).

***

### Build some cloud infrastructure

The next steps will vary between the various cloud providers. Use the following expandable sections to follow the relevant directions for the cloud provider of your choice. 
> **Note:** *While it might be obvious, it's worth mentioning that whatever cloud provider you created you Kafka cluster on should be the same cloud provider you use in the following steps.*

<details>
    <summary><b>AWS</b></summary>

1. Navigate to the AWS directory for Terraform.
    ```bash
    cd terraform/aws
    ```
1. Initialize Terraform within the directory.
    ```bash
    terraform init
    ```
1. Create the Terraform plan.
    ```bash
    terraform plan
    ```
1. Apply the plan and create the infrastructure.
    ```bash
    terraform apply
    ```
    > **Note:** *To see the inventory of what is created by this command, check out the configuration file [here](https://github.com/zacharydhamilton/realtime-datawarehousing/tree/main/terraform/aws).*

The Terraform configuration will create two outputs. These outputs are the public endpoints of the Postgres (Customers DB) and Postgres (Products DB) instances that were created. Keep these handy as you will need them in the connector configuration steps. 

</details>

<br>

<details>
    <summary><b>GCP</b></summary>

1. Navigate to the GCP directory for Terraform.
    ```bash
    cd terraform/gcp
    ```
1. Initialize Terraform within the directory.
    ```bash
    terraform init
    ```
1. Create the Terraform plan.
    ```bash
    terraform plan
    ```
1. Apply the plan and create the infrastructure.
    ```bash
    terraform apply
    ```
    > **Note:** *To see the inventory of what is created by this command, check out the configuration file [here](https://github.com/zacharydhamilton/realtime-datawarehousing/tree/main/terraform/gcp).*

The Terraform configuration will create two outputs. These outputs are the public endpoints of the Postgres (Customers DB) and Postgres (Products DB) instances that were created. Keep these handy as you will need them in the connector configuration steps. 


</details>

<br>

<details>
    <summary><b>Azure</b></summary>

Coming Soon!

</details>

<br>

***

### Kafka Connectors

1. Before creating the connectors, you'll need to create the topics they'll write data to. The following list of topics should each be created with **1 partition each** for simplicity in the **Topics** menu.
    - `postgres.customers.customers`
    - `postgres.customers.demographics`
    - `postgres.products.products`
    - `postgres.products.orders`
    
1. Once the topics have been created, start by creating the Debezium Postgres CDC Source Connector (for the customers DB). Select **Data integration > Connectors** from the left-hand menu, then search for the connector. When you find its tile, select it and configure it with the following settings, then launch it. 

    | **Property**                      | **Value**                                   |
    |-----------------------------------|---------------------------------------------|
    | Kafka Cluster Authentication mode | "Use an existing API key"                   |
    | Kafka API Key                     | *copy from clipboard file*                  |
    | Kafka API Secret                  | *copy from clipboard file*                  |
    | Database name                     | postgres                                    | 
    | Database server name              | postgres                                    |
    | SSL mode                          | disabled                                    |
    | Database hostname                 | *derived from Terraform output or provided* |
    | Database port                     | 5432                                        |
    | Database username                 | postgres                                    |
    | Database password                 | rt-dwh-c0nflu3nt!                           |
    | Output Kafka record value format  | JSON_SR                                     |
    | Output Kafka record key format    | JSON_SR                                     |
    | Slot name                         | *something creative, like **camel**, it can be anything unique* |
    | Tables included                   | customers.customers, customers.demographics |
    | After-state only                  | false                                       |
    | Tasks                             | 1                                           |

    The connector can take a minute or two to provision. While it is, you can create the next connector. 

1. Create the Debezium Postgres CDC Source Connector (for the products DB) by searching for it as you did above. When you find it, configure it with the following settings, then launch it. 

    | **Property**                      | **Value**                                   |
    |-----------------------------------|---------------------------------------------|
    | Kafka Cluster Authentication mode | "Use an existing API key"                   |
    | Kafka API Key                     | *copy from clipboard file*                  |
    | Kafka API Secret                  | *copy from clipboard file*                  |
    | Database name                     | postgres                                    | 
    | Database server name              | postgres                                    |
    | SSL mode                          | disabled                                    |
    | Database hostname                 | *derived from Terraform output or provided* |
    | Database port                     | 5432                                        |
    | Database username                 | postgres                                    |
    | Database password                 | rt-dwh-c0nflu3nt!                           |
    | Output Kafka record value format  | JSON_SR                                     |
    | Slot name                         | *something creative, like **turtle**, it can be anything unique* |
    | Tables included                   | products.products, products.orders          |
    | Tasks                             | 1                                           |

Give the connectors a chance to provision, and troubleshoot any failures that occur. Once provisioned, the connector should begin capturing a stream of change data from a few tables in each database. 

<br>

***

### Ksql 

With the connectors provisioned, it's time to transform and join our streams of data in-flight with Ksql. If your cluster is still provisioning, give it more time before continuing. 

1. Use the following statements to consume the `customers` data and flatten it for ease of use. 
    ```sql
        CREATE STREAM customers_structured (
            struct_key STRUCT<id VARCHAR> KEY,
            before STRUCT<id VARCHAR, first_name VARCHAR, last_name VARCHAR, email VARCHAR, phone VARCHAR>,
            after STRUCT<id VARCHAR, first_name VARCHAR, last_name VARCHAR, email VARCHAR, phone VARCHAR>,
            op VARCHAR
        ) WITH (
            KAFKA_TOPIC='postgres.customers.customers',
            KEY_FORMAT='JSON_SR',
            VALUE_FORMAT='JSON_SR'
        );
    ```
    ```sql
        CREATE STREAM customers_flattened WITH (
                KAFKA_TOPIC='customers_flattened',
                KEY_FORMAT='JSON_SR',
                VALUE_FORMAT='JSON_SR'
            ) AS SELECT
                after->id,
                after->first_name first_name, 
                after->last_name last_name,
                after->email email,
                after->phone phone
            FROM customers_structured
            PARTITION BY after->id
        EMIT CHANGES;
    ```

1. With the `customers` data flattened, it can be easily aggregated into a Ksql table to retain the most up-to-date values by customer.
    ```sql
        CREATE TABLE customers WITH (
                KAFKA_TOPIC='customers',
                KEY_FORMAT='JSON_SR',
                VALUE_FORMAT='JSON_SR'
            ) AS SELECT
                id,
                LATEST_BY_OFFSET(first_name) first_name, 
                LATEST_BY_OFFSET(last_name) last_name,
                LATEST_BY_OFFSET(email) email,
                LATEST_BY_OFFSET(phone) phone
            FROM customers_flattened
            GROUP BY id
        EMIT CHANGES;
    ```

1. Next, do what is effectively the same thing, this time for the `demographics` data. 
    ```sql
        CREATE STREAM demographics_structured (
            struct_key STRUCT<id VARCHAR> KEY,
            before STRUCT<id VARCHAR, street_address VARCHAR, state VARCHAR, zip_code VARCHAR, country VARCHAR, country_code VARCHAR>,
            after STRUCT<id VARCHAR, street_address VARCHAR, state VARCHAR, zip_code VARCHAR, country VARCHAR, country_code VARCHAR>,
            op VARCHAR
        ) WITH (
            KAFKA_TOPIC='postgres.customers.demographics',
            KEY_FORMAT='JSON_SR',
            VALUE_FORMAT='JSON_SR'
        );
    ```
    ```sql
        CREATE STREAM demographics_flattened WITH (
                KAFKA_TOPIC='demographics_flattened',
                KEY_FORMAT='JSON_SR',
                VALUE_FORMAT='JSON_SR'
            ) AS SELECT
                after->id,
                after->street_address,
                after->state,
                after->zip_code,
                after->country,
                after->country_code
            FROM demographics_structured
            PARTITION BY after->id
        EMIT CHANGES;
    ```

1. And now create a Ksql table to retain the most up-to-date values by demographics. 
    ```sql
        CREATE TABLE demographics WITH (
                KAFKA_TOPIC='demographics',
                KEY_FORMAT='JSON_SR',
                VALUE_FORMAT='JSON_SR'
            ) AS SELECT
                id, 
                LATEST_BY_OFFSET(street_address) street_address,
                LATEST_BY_OFFSET(state) state,
                LATEST_BY_OFFSET(zip_code) zip_code,
                LATEST_BY_OFFSET(country) country,
                LATEST_BY_OFFSET(country_code) country_code
            FROM demographics_flattened
            GROUP BY id
        EMIT CHANGES;
    ```

1. With the two tables `customers` and `demographics` created, they can be joined together to create what will effectively be an always up-to-date view of the customer and demographic data combined together by the customer ID. 
    ```sql
        CREATE TABLE customers_enriched WITH (
                KAFKA_TOPIC='customers_enriched',
                KEY_FORMAT='JSON_SR',
                VALUE_FORMAT='JSON_SR'
            ) AS SELECT 
                c.id id, c.first_name first_name, c.last_name last_name, c.email email, c.phone phone,
                d.street_address street_address, d.state state, d.zip_code zip_code, d.country country, d.country_code country_code
            FROM customers c
                JOIN demographics d ON d.id = c.id
        EMIT CHANGES;
    ```

1. Next, use the following statements to capture the `products` data and re-key it.
    ```sql
        CREATE STREAM products_composite (
            struct_key STRUCT<product_id VARCHAR> KEY,
            product_id VARCHAR,
            `size` VARCHAR,
            product VARCHAR,
            department VARCHAR,
            price VARCHAR,
            __deleted VARCHAR
        ) WITH (
            KAFKA_TOPIC='postgres.products.products',
            KEY_FORMAT='JSON',
            VALUE_FORMAT='JSON_SR'
        );
    ```
    ```sql
        CREATE STREAM products_rekeyed WITH (
                KAFKA_TOPIC='products_rekeyed',
                KEY_FORMAT='KAFKA',
                VALUE_FORMAT='JSON_SR'
            ) AS SELECT 
                product_id,
                `size`,
                product,
                department,
                price,
                __deleted deleted
            FROM products_composite
            PARTITION BY product_id
        EMIT CHANGES;
    ```

1. Just like you did with the customer data, create a Ksql table to retain the most up-to-date values for the `products` data. 
    ```sql 
        CREATE TABLE products WITH (
                KAFKA_TOPIC='products',
                KEY_FORMAT='JSON_SR',
                VALUE_FORMAT='JSON_SR'
            ) AS SELECT 
                product_id,
                LATEST_BY_OFFSET(`size`) `size`,
                LATEST_BY_OFFSET(product) product,
                LATEST_BY_OFFSET(department) department,
                LATEST_BY_OFFSET(price) price,
                LATEST_BY_OFFSET(deleted) deleted
            FROM products_rekeyed
            GROUP BY product_id
        EMIT CHANGES;
    ```

1. Next, replicate what you did above with the `orders` data. 
    ```sql
        CREATE STREAM orders_composite (
            order_key STRUCT<`order_id` VARCHAR> KEY,
            order_id VARCHAR,
            product_id VARCHAR,
            customer_id VARCHAR,
            __deleted VARCHAR
        ) WITH (
            KAFKA_TOPIC='postgres.products.orders',
            KEY_FORMAT='JSON',
            VALUE_FORMAT='JSON_SR'
        );
    ```
    ```sql
        CREATE STREAM orders_rekeyed WITH (
                KAFKA_TOPIC='orders_rekeyed',
                KEY_FORMAT='KAFKA',
                VALUE_FORMAT='JSON_SR'
            ) AS SELECT
                order_id,
                product_id,
                customer_id,
                __deleted deleted
            FROM orders_composite
            PARTITION BY order_id
        EMIT CHANGES;
    ```

1. Finally, create a Ksql stream to join **all** the tables together to enrich the order data in real time. 
    ```sql
        CREATE STREAM orders_enriched WITH (
                KAFKA_TOPIC='orders_enriched',
                KEY_FORMAT='JSON',
                VALUE_FORMAT='JSON_SR'
            ) AS SELECT 
                o.order_id `order_id`,
                p.product_id `product_id`, p.`size` `size`, p.product `product`, p.department `department`, p.price `price`,
                c.id `id`, c.first_name `first_name`, c.last_name `last_name`, c.email `email`, c.phone `phone`,
                c.street_address `street_address`, c.state `state`, c.zip_code `zip_code`, c.country `country`, c.country_code `country_code`
            FROM orders_rekeyed o
                JOIN products p ON o.product_id = p.product_id
                JOIN customers_enriched c ON o.customer_id = c.id
            PARTITION BY o.order_id  
        EMIT CHANGES;  
    ```
    > **Note:** *You used a stream rather than a table above since you'll use this new stream of enriched data to hydrate your data warehouse in a future step.* 

At this point, you should have a functioning Ksql topology. To see the flow laid out graphically, select **Flow** from the tabs in the Ksql cluster or click [here](https://github.com/zacharydhamilton/realtime-datawarehousing/blob/mysql/images/stream-lineage.png) for a screenshot.

***

### Data Warehouse Connectors

With the data now being captured from the two source databases and transformed in real-time, you're ready to sink the data to your data warehouse with another connector. Expand the section below corresponding to the data warehousing technology of your choice, and follow the directions to set it up. 

> **Note:** *If you skipped over the prerequisites, you'll need to address those to be able to do this part of the lab.* 

<details>
    <summary><b>Databricks</b></summary>

1. Start by locating the Databricks cluster's JDBC/ODBC connection details. After selecting your cluster, expand the section titled **Advanced**, and then select the **JDBC/ODBC** tab. On the following page, select and copy the values for **Server Hostname** and **HTTP Path** to your clipboard file. 
    > **Note:** *If you don't have an S3 bucket, an AWS Key/secret, or the Databricks Access token described from doing the prerequisites, create or gather these values. 

1. Start by creating the Databricks Delta Lake Sink Connector. Select **Data integration > Connectors** from the left-hand menu, then search for the connector. When you find its tile, select it and configure it with the following settings, then launch it.
    | **Property**                      | **Value**                  |
    |-----------------------------------|----------------------------|
    | Topics                            | `orders_enriched`          |
    | Kafka Cluster Authentication mode | KAFKA_API_KEY              |
    | Kafka API Key                     | *copy from clipboard file* |
    | Kafka API Secret                  | *copy from clipboard file* |
    | Delta Lake Host Name              | *copy from clipboard file* |
    | Delta Lake HTTP Path              | *copy from clipboard file* |
    | Delta Lake Token                  | *from the prerequisites*   |
    | Staging S3 Access Key ID          | *from the prerequisites*   |
    | Staging S3 Secret Access Key      | *from the prerequisites*   |
    | S3 Staging Bucket Name            | *from the prerequisites*   |
    | Tasks                             | 1                          |

1. With the connector provisioned, data should be being sent to a Delta Lake Table in real time. Create the following table so you can query the datasets. 
    ```sql
        CREATE TABLE orders_enriched (order_id STRING, 
                                    product_id STRING, size STRING, product STRING, department STRING, price STRING,
                                    id STRING, first_name STRING, last_name STRING, email STRING, phone STRING,
                                    street_address STRING, state STRING, zip_code STRING, country STRING, country_code STRING,
                                    partition INT) USING DELTA;
    ```

1. And finally, query the records!
    ```sql 
     SELECT * FROM default.orders_enriched;
    ```

At this point, you can play around to your hearts desire with the dataset in Databricks. To emphasize was you accomplished, try constructing some queries that combine the data from two tables originating in the different source databases to do something cool. *Hint, total revenue by state, or something.*

</details>

<br>

<details>
    <summary><b>Snowflake</b></summary>

The most detailed description of setting up the **Fully-Managed Snowflake Sink Connector** can be found [here](https://docs.confluent.io/cloud/current/connectors/cc-snowflake-sink.html). 
> **Note:** *The screenshots (at the time this was written) are of the classic view in Snowflake. If things don't align, try switching to the classic view.*

</details>

<br>

***

## Cleanup

When you're done with all of the resources created in this lab, **be sure to delete everything you provisioned** in an effort to mitigate the chances of being changed for anything. 

### Confluent Cloud
During this lab you created the following resources, be sure to remove them when you're done with them.
- Ksql Cluster
- Delta Lake Sink Connector
- Postgres CDC Source Connector (Customers)
- Postgres CDC Source Connector (Products)
- Kafka Cluster

### Terraform
To remove everything provisioned by Terraform in either AWS, GCP, or Azure, use the following command.
    ```bash
    terraform destroy
    ```

### Databricks and Snowflake
If you created instances of either Databricks and Snowflake solely for the purpose of this lab, remove them!

***

## Useful Links

Databricks
- [Confluent Cloud Databricks Delta Lake Sink](https://docs.confluent.io/cloud/current/connectors/cc-databricks-delta-lake-sink/cc-databricks-delta-lake-sink.html)
- [Databricks Setup on AWS](https://docs.confluent.io/cloud/current/connectors/cc-databricks-delta-lake-sink/databricks-aws-setup.html)
