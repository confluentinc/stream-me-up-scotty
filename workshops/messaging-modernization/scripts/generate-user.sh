i=$1
FIRSTNAME="FirstName$i"
LASTNAME="LastName$i"
COUNTRY="US"
echo "{ \"user\": \"$i\", \"first\": \"$FIRSTNAME\", \"last\": \"$LASTNAME\", \"country\": \"$COUNTRY\" }"
