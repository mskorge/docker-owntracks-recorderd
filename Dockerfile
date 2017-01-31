FROM debian:jessie
LABEL version="0.4" description="OwnTracks Recorder"
LABEL authors="Jan-Piet Mens <jpmens@gmail.com>, Giovanni Angoli <juzam76@gmail.com>, Francesco Vezzoli <fvezzoli@iz2vtw.net>"

ADD http://repo.owntracks.org/repo.owntracks.org.gpg.key /tmp/owntracks.gpg.key

RUN	apt-key add /tmp/owntracks.gpg.key && \
	apt-get update && \
	apt-get install -y software-properties-common net-tools && \
	apt-add-repository 'deb http://repo.owntracks.org/debian jessie main' && \
	apt-get update && \
	apt-get install -y \
		libmosquitto1 \
		libsodium13 \
		libcurl3 \
		liblua5.2-0 \
		ot-recorder \
		curl \
		&& \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

# data volume
VOLUME /owntracks

COPY ot-recorder.default /etc/default/ot-recorder

COPY launcher.sh /usr/local/sbin/launcher.sh

COPY recorder-health.sh /usr/local/sbin/recorder-health.sh
HEALTHCHECK --interval=5m --timeout=30s CMD /usr/local/sbin/recorder-health.sh

RUN	mkdir -p -m 775 /owntracks/recorder/store && \
	chown -R owntracks:owntracks /owntracks && \
	chmod 755 /usr/local/sbin/launcher.sh /usr/local/sbin/recorder-health.sh

EXPOSE 8083
CMD ["/usr/local/sbin/launcher.sh"]
