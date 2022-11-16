require('dotenv').config();
const pg = require('pg');
const express = require('express');
const cors = require('cors');
const { v4: uuidv4 } = require('uuid');

const pool = new pg.Pool();
pool.on('error', (err) => {
    log("error", 'Unexpected error occurred in pg client.', err.stack)
    process.exit(-1);
});

const app = express();
app.use(cors());
app.use(express.json());

app.post('/balance', (req, res) => {
    log('info', 'Received new balance request.', { card: req.body.value.card });
    pool.connect((err, client, done) => {
        log("info", 'Connecting to database connection pool.', null);
        if (err) {
            log('error', 'Error connecting to database connection pool.', err.stack);
            res.status(500).send({ message: "Error connecting to database connection pool." });
            return;
        }
        const abort = (err) => {
            if (err) {
                log('error', 'Encountered error during transaction. Performing rollback.', err.stack);
                res.status(500).send({ message: "Encountered error during transaction. Performing rollback." });
                client.query('ROLLBACK', err => {
                    if (err) {
                        log('error', 'Error rolling back client.', err.stack);
                    }
                    done();
                });
            }
            return !!err;
        };
        client.query('BEGIN', (err) => {
            log('info', 'Beginning new transaction', 'BEGIN');
            if (abort(err)) return;
            const query = `SELECT card_number AS card, SUM(transaction_amount) as balance FROM bank.transactions WHERE card_number='${req.body.value.card}' GROUP BY card_number`;
            client.query(query, (err, result) => {
                log('info', 'Querying database', query);
                if (abort(err)) return;
                client.query('COMMIT', (err) => {
                    log('info', 'Committing transaction', 'COMMIT');
                    if (abort(err)) return;
                    res.status(200).send({
                        message: "Completed transaction successfully.",
                        results: result.rows
                    });
                    done();
                });
            });
        });
    });
});

app.post('/transactions', (req, res) => {
    log('info', 'Received new transaction request.', { card: req.body.value.card, amount: req.body.value.amount });
    pool.connect((err, client, done) => {
        log('info', 'Connecting to database connection pool.', null);
        if (err) {
            log('error', 'Error connecting to database connection pool.', err.stack);
            res.status(500).send({ message: "Error connecting to database connection pool." });
            return;
        }
        const abort = (err) => {
            if (err) {
                log('error', 'Encountered error during transaction. Performing rollback.', err.stack);
                res.status(500).send({ message: "Encountered error during transaction. Performing rollback." });
                client.query('ROLLBACK', err => {
                    if (err) {
                        log('error', 'Error rolling back client.', err.stack);
                    }
                    done();
                });
            }
            return !!err;
        };
        client.query('BEGIN', (err, result) => {
            log('info', 'Beginning new transaction', 'BEGIN');
            if (abort(err)) return;
            const id = uuidv4();
            const query = `INSERT INTO bank.transactions (transaction_id, card_number, transaction_amount) VALUES ('${id}', '${req.body.value.card}', ${req.body.value.amount})`;
            client.query(query, (err, result) => {
                log('info', 'Inserting new transaction.', query);
                if (abort(err)) return;
                client.query('COMMIT;', (err, result) => {
                    log('info', 'Committing transaction', 'COMMIT');
                    if (abort(err)) return;
                    res.status(200).send({
                        message: "Committed new transaction successfully.",
                        values: {
                            id: id,
                            card: req.body.value.card,
                            amount: req.body.value.amount
                        }
                    });
                    done();
                });
            });
        });
    });
});

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

app.listen(8000, (error) => {
    log('info', "Express app started.", null);
    if (error) {
        log('error', 'Error encountered in express API.', error.stack);
    }
});