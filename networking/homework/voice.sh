lullaby="$(find / -type f -name lullaby.txt)"
cat "$lullaby" | nc -l -p $PORT
