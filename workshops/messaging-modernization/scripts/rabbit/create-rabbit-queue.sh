curl --user guest:guest \
      -X PUT -H 'content-type: application/json' \
      --data-binary '{"vhost":"/","name":"test-queue-01","durable":"true","auto_delete":"false","arguments":{"x-queue-type":"classic"}}' \
      'http://localhost:15672/api/queues/%2F/test-queue-01'
