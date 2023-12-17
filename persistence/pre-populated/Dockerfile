FROM busybox

RUN mkdir /data

RUN uname -a > /data/name
RUN hostname > /data/hostname

VOLUME [ "/data" ]
