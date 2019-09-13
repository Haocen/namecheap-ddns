FROM alpine:latest

LABEL maintainer Haocen.xu@gmail.com

RUN apk add --no-cache curl
RUN apk add --no-cache bash

WORKDIR /usr/scripts

COPY update_ddns.sh ./

ENV DOMAIN example.com
ENV HOST www
ENV PASSWORD abcdef
ENV IP_DETECTOR_ENDPOINT https://check.torproject.org/
ENV DEBUG false

RUN chmod 555 update_ddns.sh

CMD while /bin/true; do ./update_ddns.sh; /bin/sleep 60; done
