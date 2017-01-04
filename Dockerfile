FROM alpine:edge

MAINTAINER Emrah URHAN <raxetul@gmail.com>

RUN echo "http://nl.alpinelinux.org/alpine/edge/community/" >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache \
      bash \
      s6

RUN mkdir -p /s6/

## Use these 3 lines to add your dummy service in s6 supervision.
## services should have run and finish scripts in their folder and folder should be copied
## into /s6 folder. /s6 folder will be used in ENTRYPOINT.
## You should not change ENTRYPOIN in your docker files
#########################################################################################
# COPY dummy-service /s6/dummy-service
# RUN chmod +x /s6/dummy-service/run /s6/dummy-service/finish \
#  && chown root /s6/dummy-service/run /s6/dummy-service/finish
#########################################################################################

COPY .s6-svscan /s6/.s6-svscan
RUN chmod +x /s6/.s6-svscan/finish && chown root /s6/.s6-svscan/finish

## Use "data" for keeping rw files such as db,
##     "web" for web files such as php's, html's
##     "app" for compiled apps such as nodejs, golang, c++, etc
##      (your application binary may placed in /app or /app/bin, see run level "2" script)
##     "log" for log files
##     "cert" for ssl certificates, public/private keys
#########################################################################################
RUN mkdir /app /conf /data /web /log /cert
VOLUME ["/app","/conf","/data","/web","/log","/cert"]
#########################################################################################

ENTRYPOINT ["/bin/s6-svscan","/s6"]
