FROM busybox AS base

FROM base AS service

COPY service.sh .

ENTRYPOINT [ "sh", "service.sh" ]

FROM base AS client

COPY client.sh .

ENTRYPOINT [ "sh", "client.sh" ]
