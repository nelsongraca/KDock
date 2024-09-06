
#!/bin/bash

#Link plugins from PLUGIN_ environment variables
for p in $(echo "${!PLUGIN_*}"); do
	pluginFile="${!p}"
	echo "Linking $pluginFile"
	ln -sf "$pluginFile" ./moonraker/moonraker/components/$(basename "$pluginFile");
done



source ./.venv/bin/activate

python moonraker/moonraker/moonraker.py \
	-u ./data/moonraker.sock \
	-d ./data
