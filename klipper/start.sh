#!/bin/bash

mkdir -p data/logs
mkdir -p data/config
mkdir -p data/gcodes

#Link plugins from PLUGIN_ environment variables
for p in $(echo "${!PLUGIN_*}"); do
	pluginFile="${!p}"
	echo "Linking $pluginFile"
	ln -sf "$pluginFile" ./klipper/klippy/plugins/$(basename "$pluginFile");
done

source ./.venv/bin/activate

python klipper/klippy/klippy.py \
	-a data/klipper.sock \
	-l data/logs/klippy.log \
	--rotate-log-at-restart \
	data/config/klipper.cfg
