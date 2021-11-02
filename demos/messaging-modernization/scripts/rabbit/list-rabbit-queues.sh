curl -s --user guest:guest \
        -X GET -H 'content-type: application/json' \
        'http://localhost:15672/api/queues/%2F/' | jq '.[].name'
