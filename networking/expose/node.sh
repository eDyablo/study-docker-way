first=1; second=2
while [ "$first" -a "$second" ]; do sleep 1; done \
& first=$(echo You have connected to port 50001 | nc -l -p 50001) \
& second=$(echo You have connected to port 50002 | nc -l -p 50002)
