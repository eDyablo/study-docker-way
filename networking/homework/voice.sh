lullaby="$(find / -type f -name lullaby.txt)"
echo found "$lullaby"
cat "$lullaby" | nc -v -l -p $PORT
