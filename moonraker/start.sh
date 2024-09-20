#!/bin/bash

#Link plugins from PLUGIN_ environment variables
for p in $(echo "${!PLUGIN_*}"); do
	pluginFile="${!p}"
	echo "Linking $pluginFile"
	ln -sf "$pluginFile" ./moonraker/moonraker/components/$(basename "$pluginFile");
done

source ./.venv/bin/activate

#install extra dependencies if defined
if [ -n "$EXTRA_DEPS" ]; then
  pip install $EXTRA_DEPS
fi

python moonraker/moonraker/moonraker.py \
	-u ./data/moonraker.sock \
	-d ./data
