FROM alpine:3.24.2

LABEL maintainer="Emrah URHAN <raxetul@gmail.com>"

## s6-overlay is the init / process supervisor (PID 1). It replaces the bare
## s6-svscan setup used previously and gives us proper signal handling, so
## `docker stop` shuts services down gracefully instead of timing out.
ARG S6_OVERLAY_VERSION=3.2.3.2
## TARGETARCH / TARGETVARIANT are provided automatically by Docker Buildx,
## one value per target platform. We map them to s6-overlay's asset names.
ARG TARGETARCH
ARG TARGETVARIANT

RUN apk add --no-cache \
      bash \
      ca-certificates \
      tzdata \
  && apk add --no-cache --virtual .s6-build xz \
  && case "${TARGETARCH}/${TARGETVARIANT}" in \
       amd64/*)   S6_ARCH=x86_64 ;; \
       arm64/*)   S6_ARCH=aarch64 ;; \
       arm/v7)    S6_ARCH=arm ;; \
       arm/v6)    S6_ARCH=armhf ;; \
       ppc64le/*) S6_ARCH=powerpc64le ;; \
       s390x/*)   S6_ARCH=s390x ;; \
       *) echo "Unsupported architecture: ${TARGETARCH}/${TARGETVARIANT}" >&2; exit 1 ;; \
     esac \
  && echo "Installing s6-overlay ${S6_OVERLAY_VERSION} for ${S6_ARCH}" \
  && wget -qO /tmp/s6-overlay-noarch.tar.xz \
       "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" \
  && wget -qO /tmp/s6-overlay-arch.tar.xz \
       "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.xz" \
  && tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz \
  && tar -C / -Jxpf /tmp/s6-overlay-arch.tar.xz \
  && rm -f /tmp/s6-overlay-noarch.tar.xz /tmp/s6-overlay-arch.tar.xz \
  && apk del .s6-build

## Adding your own service (s6-rc / s6-overlay v3 style):
##   A long-running service lives in /etc/s6-overlay/s6-rc.d/<name>/ and needs:
##     - a "type" file containing the word "longrun"
##     - an executable "run" script (see dummy-service/ for a template)
##     - an optional "finish" script for cleanup
##   Enable it at boot by creating an empty flag file:
##     /etc/s6-overlay/s6-rc.d/user/contents.d/<name>
##   Then COPY the whole tree into the image. See the alpine-s6-nginx image
##   for a real, working example.
#########################################################################################
# COPY s6-rc.d /etc/s6-overlay/s6-rc.d
#########################################################################################

## Standard mount points:
##   "data" rw files such as db,   "web"  web files (php/html),
##   "app"  compiled app binaries, "log"  log files,
##   "conf" configuration files,   "cert" ssl certificates / public/private keys
#########################################################################################
RUN mkdir -p /app /conf /data /web /log /cert
VOLUME ["/app","/conf","/data","/web","/log","/cert"]
#########################################################################################

## /init comes from s6-overlay. Child images MUST NOT override this ENTRYPOINT.
ENTRYPOINT ["/init"]
