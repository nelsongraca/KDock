#!/bin/bash

stack_location="$1"
socket="$2/supervisord_escaper.sock"
pidfile="$stack_location/$(basename $0).pid"

function main () {
    if [ -f $pidfile ]; then
        pid=$(cat $pidfile)
        if ps -p $pid > /dev/null; then
            echo Already running as $pid
            exit 0
        fi
    fi

    if [ -f $socket ]; then
        rm $socket
    fi

    trap "clean_exit" EXIT

    echo $$ > "$pidfile"

    socat UNIX-LISTEN:$socket,mode=660,user=1000,group=1000,fork system:'bash -c "handle_cmd"',pipes &

    scpid=$!
    wait $scpid
}

function handle_cmd () {
    declare -A service_map=( 
      ["klipper"]="klipper"
      ["moonraker"]="moonraker"
      ["uStreamer"]="uStreamer"
      ["klipper-screen"]="klipper-screen"
    )
    printf -v services_str "%s|" "${!service_map[@]}"
    services_str=${services_str%?} 
    
    read cmd
    args=()
    for i in $cmd; do args+=($i) ; done

    if [[ ! "${args[0]}" =~ ^(start|stop|restart|status)$ ]]; then
        echo "Invalid command"
	return 0
    fi

    translated_services=""

    for svc in ${args[@]:1}; do
	if [[ ! "${svc}" =~ ^(${services_str})$ ]]; then	
	    echo "Invalid service"
	    return 0
	fi
	translated_services="$translated_services ${service_map[${svc}]}"
    done

    if [[ "${args[0]}" == "status" ]]; then
        args[0]="ps"
	extra_args=('-a' '--format' '{{.Service}} {{lower .State}}')
    fi

    result=$(docker compose --ansi never --progress none --project-directory $stack_location --parallel 1 ${args[0]} "${extra_args[@]}" $translated_services)
    while IFS= read -r line; do
        for i in "${!service_map[@]}"; do
	    split=($line)
	    if [[ ${split[0]} == ${service_map[$i]} ]]; then
		echo $line | sed "s/${service_map[$i]}/$i/"
	    fi
        done
    done <<< "$result"
}


export -f handle_cmd
export stack_location

function clean_exit () {
    rm -f -- "$pidfile"
    kill $scpid
}

main
