FROM nimmis/alpine-glibc

MAINTAINER nimmis <kjell.havneskold@gmail.com>

ENV RSLSYNC_SIZE=1000 \
    RSLSYNC_TRASH_TIME=30 \
    RSLSYNC_TRASH=true
COPY root/. /

RUN apk update && apk upgrade && \
    apk add zip curl && \
    cd /root && \
    curl https://download-cdn.resilio.com/stable/linux-x64/resilio-sync_x64.tar.gz | tar xfz - && \
    mv rslsync /usr/local/bin && \
    rm -rf /var/cache/apk/*

VOLUME /data

EXPOSE 33333
EXPOSE 8888

