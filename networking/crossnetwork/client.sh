PORT=54321

while ! (nc -z $HOST $PORT); do
  sleep 1
done

echo Connection established.

echo hello | nc $HOST $PORT
echo bye | nc $HOST $PORT
