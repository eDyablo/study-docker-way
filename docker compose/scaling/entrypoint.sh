while true
do
  echo you have reached $(hostname) | nc -l -p 54321
done

