FROM alpine:3.5
LABEL version="edge" description="OwnTracks Recorder"
LABEL authors="Francesco Vezzoli <fvezzoli@iz2vtw.net>"

COPY config.mk /recorder-master/config.mk

RUN	apk update && \
	apk add build-base mosquitto-dev lua-dev libsodium-dev curl-dev libconfig-dev && \
	apk add ca-certificates && update-ca-certificates && apk add openssl && \
	wget https://codeload.github.com/owntracks/recorder/tar.gz/master && \
	tar xzf master && rm master && \
	cd recorder-master && \
	make && make install && \
	cd .. && rm -r recorder-master

# data volume
VOLUME /owntracks

COPY ot-recorder.default /etc/default/ot-recorder

COPY recorder-launcher.sh /usr/local/bin/recorder-launcher.sh

COPY recorder-health.sh /usr/local/bin/recorder-health.sh
HEALTHCHECK --interval=5m --timeout=30s CMD /usr/local/sbin/recorder-health.sh

RUN	mkdir -p -m 775 /owntracks/recorder/store && \
	chmod 755 /usr/local/bin/recorder-launcher.sh /usr/local/bin/recorder-health.sh

EXPOSE 8083
CMD ["/usr/local/bin/recorder-launcher.sh"]
