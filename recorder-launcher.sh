#!/bin/sh
# launcher.sh
# This will be started when the container starts

set -e

echo -- "--- BEGIN OWNTRACKS LAUNCHER ---"
mkdir -p /owntracks/recorder/store
mkdir -p /owntracks/recorder/store/last

echo -- "--- INIT OWNTRACKS RECORDER ---"
/usr/local/sbin/ot-recorder --initialize
# Put ot-recorder defaults in volume if not exist
if [ ! -f /owntracks/ot-recorder ]; then
	mv /etc/default/ot-recorder /owntracks/ot-recorder
fi

echo -- "--- LAUNCH OWNTRACKS RECORDER ---"
exec /usr/local/sbin/ot-recorder --http-host 0.0.0.0 ${OTR_LUA:+"\-\-lua-script $OTR_LUA"}
