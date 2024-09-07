#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "$SCRIPT_DIR" || exit

nohup moonraker/supervisor/supervisord_escaper.sh ${SCRIPT_DIR} ${SCRIPT_DIR}/data &
