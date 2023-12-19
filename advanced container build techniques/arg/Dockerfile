FROM alpine

RUN apk add --update --no-cache figlet

ENV FONT=big

ENTRYPOINT [ "sh", "-c", "echo $0 $@ | figlet -f$FONT" ]

