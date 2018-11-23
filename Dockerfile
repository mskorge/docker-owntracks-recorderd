FROM alpine:3.8
LABEL version="0.7.9" description="OwnTracks Recorder"
LABEL authors="Francesco Vezzoli <fvezzoli@iz2vtw.net>"

ENV VERSION=0.7.9

COPY ot-recorder.default /etc/default/ot-recorder
COPY recorder-launcher.sh /app/recorder-launcher.sh
COPY recorder-health.sh /app/recorder-health.sh

RUN	set -ex \
    # Add build dependencies, remove after build
    && apk --no-cache add --virtual .build-deps \
            build-base \
            mosquitto-dev \
            lua-dev \
            libsodium-dev \
            curl-dev \
            libconfig-dev \
            #   ca-certificates curl python openssl \
    # Add run dependencies, keep after build
    && apk --no-cache add --virtual .run-deps \
            mosquitto-libs \
            lua-libs \
            libsodium \
            libcurl \
            libconfig \
    # Add run dependencies, keep after build
    && apk --no-cache add --virtual .health-deps \
            curl \
            jq \
    && cd /tmp \
	&& wget -O recorder.tar.gz https://github.com/owntracks/recorder/archive/$VERSION.tar.gz \
	&& tar xzf recorder.tar.gz \
	&& cd recorder-$VERSION \
	&& sed -e 's/WITH_LUA ?= no/WITH_LUA ?= yes/' \
           -e 's/WITH_ENCRYPT ?= no/WITH_ENCRYPT ?= yes/' \
           -e 's/STORAGEDEFAULT = .*/STORAGEDEFAULT = \/owntracks\/recorder\/store/' \
           -e 's/CONFIGFILE = .*/CONFIGFILE = \/owntracks\/ot-recorder/' \
           config.mk.in > config.mk \
	&& make \
    && make install \
    && apk --purge del .build-deps \
	&& cd / && rm -r /tmp/* \
    && mkdir -p -m 775 /owntracks/recorder/store \
    && chmod 755 /app/recorder-launcher.sh /app/recorder-health.sh

# data volume
VOLUME /owntracks

HEALTHCHECK --interval=5m --timeout=30s CMD /app/recorder-health.sh

EXPOSE 8083
CMD ["/usr/local/bin/recorder-launcher.sh"]
