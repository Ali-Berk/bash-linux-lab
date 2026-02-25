#!/bin/bash
target="127.0.0.1"
base_value=1
ceiling_value=1024
time_out=1
sleep_time=0

ipv4_regex='^([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$'
ipv6_regex='^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$'
dns_regex='^([a-zA-Z0-9](([a-zA-Z0-9-]*[a-zA-Z0-9])?)\.)+[a-zA-Z]{2,}$'

trap "exit 1" SIGINT SIGTERM

while getopts "t:p:hs" opt; do
    case $opt in
        h)
            echo "Scans TCP ports on the target and determines they are open, closed or filtered."
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo " -t: Target address (IP or Domain.)"
            echo " -p: Port or Port Range (e.g., 80 or 20-100)"
            echo " -s: Safe Mode (Adds 0.1s delay between scans)"
            exit 0
            ;;
        p)
            if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
                if (( OPTARG > 65535 )); then
                    echo "Invalid Port."
                    exit 1
                fi
                base_value="$OPTARG"
                ceiling_value="$OPTARG"
            elif [[ "$OPTARG" =~ ^[0-9]+-[0-9]+$ ]]; then
                IFS='-' read -r base_value ceiling_value <<< "$OPTARG"
                if (( base_value > 65535 || ceiling_value > 65535 || base_value > ceiling_value )); then
                    echo "Invalid Port Range."
                    exit 1
                fi
            else
                echo "Format Incorrect."
                exit 1
            fi
            ;;
        t)
            if [[ "$OPTARG" =~ $ipv4_regex ]] || [[ "$OPTARG" =~ $ipv6_regex ]]; then
                target="$OPTARG"
            elif [[ "$OPTARG" == "localhost" ]]; then
                target="127.0.0.1"
            elif [[ "$OPTARG" =~ $dns_regex ]]; then
                target="$OPTARG"
            else
                echo "Format Incorrect"
                exit 1
            fi
            ;;
        s)
            sleep_time=0.1
            ;;

    esac
done
shift $((OPTIND -1))
for ((i=base_value; i<=ceiling_value; i++)); do
    timeout "$time_out" bash -c "echo > /dev/tcp/$target/$i" 2>/dev/null
    val=$?
    if [[ $val -eq 0 ]]; then
        echo "Port $i: OPEN."
    elif [[ $val -eq 124 ]]; then
        echo "ERROR Code: $val | Port $i: TIMEOUT."
    else
        echo "ERROR Code: $val | Port $i: CLOSED."
    fi
    sleep "$sleep_time"
done
