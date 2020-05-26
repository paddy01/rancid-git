FROM alpine:latest

ARG UID=1000
ARG GID=1000
ARG TIMEZONE="UTC"

RUN apk update
RUN apk add --no-cache bash expect git openssh-client perl-socket6 busybox-extras

# Set timezone in the image
RUN apk add --no-cache tzdata
RUN cp /usr/share/zoneinfo/$TIMEZONE /etc/localtime
RUN echo "$TIMEZONE" > /etc/timezone
RUN apk del tzdata

RUN addgroup --gid $GID rancid
RUN adduser -D -u $UID -G rancid -s /bin/sh rancid

RUN apk add --no-cache --virtual .builddeps build-base alpine-sdk autoconf automake gcc make
RUN  cd /usr/bin && \
     ln -s aclocal aclocal-1.14 && \
     ln -s automake automake-1.14 && \
     cd /root && \
     git clone https://github.com/haussli/rancid.git rancid-git && \
     cd /root/rancid-git && \
     ./configure --prefix=/home/rancid --mandir=/usr/share/man --bindir=/usr/bin --sbindir=/usr/sbin --sysconfdir=/etc/rancid --with-git --datarootdir=/usr/share && \
     make install && \
     chown -R rancid /home/rancid

RUN cp -rp /etc/rancid /root/rancid-etc
RUN cp -rp /home/rancid/lib /root/rancid-lib

ADD https://github.com/just-containers/s6-overlay/releases/download/v1.18.1.5/s6-overlay-amd64.tar.gz /

# Newer Docker now auto-unpacking remote URLS, if older docker, add will have
# downloaded the file, if newer, it will already have unpacked it
RUN test -f /s6-overlay-amd64.tar.gz && tar xzf /s6-overlay-amd64.tar.gz -C / && rm /s6-overlay-amd64.tar.gz || true

# setup sample config, default cron, 20 minute polling
RUN cp /usr/share/rancid/rancid.conf.sample /root/rancid-etc && \
    echo '*/20 * * * * /usr/bin/rancid-run >/home/rancid/var/logs/cron.log 2>/home/rancid/var/logs/cron.err' > /root/rancid-etc/rancid.cron

# Copy basic files into root for safekeeping
ADD /root /

#
VOLUME ["/home/rancid"]
VOLUME ["/etc/rancid"]

# write README file
# advise on git config/read from ENV and adjust accordingly
# advise to add entry to GROUPS list in rancid.conf, run rancid-cvs as 'rancid' user to pre-create folders
ENTRYPOINT ["/init"]
