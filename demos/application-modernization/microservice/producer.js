require('dotenv').config();
const Kafka = require("node-rdkafka");

const ERR_TOPIC_ALREADY_EXISTS = 36;

function createTopic(options) {
    const adminClient = Kafka.AdminClient.create(options.clients);
    return new Promise((resolve, reject) => {
        adminClient.createTopic({
            topic: options.topic,
            num_partitions: 6,
            replication_factor: 3
        }, (error) => {
            if (!error) {
                log('info', 'Created topic.', { topic: options.topic });
                return resolve();
            }
            if (error.code === ERR_TOPIC_ALREADY_EXISTS) {
                return resolve();
            }
            return reject(error);
        });
    });
}

function createProducer(options, onDeliveryReport) {
    const producer = new Kafka.Producer(options.clients);
    return new Promise((resolve, reject) => {
        producer
            .on('ready', () => resolve(producer))
            .on('delivery-report', onDeliveryReport)
            .on('event.error', (error) => {
                log('error', 'An error occurred in the producer.', error.stack);
                reject(error);
            });
        producer.connect();
    })
}

exports.kafka_producer = (options) => {
    return new Promise((resolve, reject) => {
        createTopic(options)
            .then(() => {
                createProducer(options, (error, report) => {
                    if (error) {
                        log('error', 'Error producing message.', error.stack);
                    } else {
                        const { topic, partition, value } = report;
                        log('info', 'Successfully produced record', { topic: topic, partition: partition, value: value });
                    }
                })
                    .then((producer) => {
                        resolve(producer);
                    })
                    .catch((error) => {
                        log('error', 'Error creating producer.', error.stack);
                        reject(error);
                    });
            })
            .catch((error) => {
                log('error', 'Error creating producer.', error.stack);
                reject(error);
            });
    })
};

const log = (level, message, event) => {
    switch (level) {
        case "info":
            console.info(new Date(Date.now()).toISOString(), "INFO", { message: message, event, event });
            break;
        case "warn":
            console.warn(new Date(Date.now()).toISOString(), "WARN", { message: message, event, event });
            break;
        case "error":
            console.error(new Date(Date.now()).toISOString(), "ERROR", { message: message, event, event });
            break;
        default:
            console.log(new Date(Date.now()).toISOString(), "INFO", { message: message, event, event });
            break;
    }
}