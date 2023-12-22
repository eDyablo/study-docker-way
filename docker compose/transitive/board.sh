echo Started
while true
do
  record=$(nc -l -p 54321)
  [ "$record" ] && echo "$record"
done

