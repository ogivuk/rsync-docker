FROM alpine

RUN apk add --update-cache \
    rsync \
    openssh-client \
    tzdata \
 && rm -rf /var/cache/apk/*

COPY rsync.sh .

ENTRYPOINT [ "./rsync.sh" ]
