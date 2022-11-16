CURRENCY="$"
VALUE=$(jot -r -p 1 1 20 200)
DATE=$(date)
AMT="$CURRENCY$VALUE"
let USERID=$RANDOM%100
echo "{ \"transaction\": \"PAYMENT\", \"amount\": \"$AMT\", \"timestamp\": \"$DATE\", \"user\": \"$USERID\" }"
