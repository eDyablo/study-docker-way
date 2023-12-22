FROM busybox

COPY entrypoint.sh .

HEALTHCHECK --interval=5s CMD [ "nc", "-z", "localhost", "54321" ]

ENTRYPOINT [ "sh", "entrypoint.sh" ]

