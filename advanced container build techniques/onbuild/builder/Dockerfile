FROM cpp-builder AS builder

FROM scratch

COPY --from=builder /out/app /bin/app

ENTRYPOINT [ "/bin/app" ]
