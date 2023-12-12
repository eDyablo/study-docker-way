response='Thank you for choosing us!'
request=$(echo $response | nc -v -l -p 54321)

while [ "$request" != "bye" ]; do
  response='Thank you for your request, we have already started working on it.'
  request=$(echo $response | nc -v -l -p 54321)
done
