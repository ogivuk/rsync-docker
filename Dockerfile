FROM alpine

RUN apk add --update-cache \
    rsync \
    tzdata \
 && rm -rf /var/cache/apk/*

COPY rsync.sh .

ENTRYPOINT [ "./rsync.sh" ]
