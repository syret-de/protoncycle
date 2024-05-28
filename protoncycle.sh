#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <sleep_time_in_seconds>"
    exit 1
fi

function ctrl_c() {
    echo "Stopping script, shutting down Docker Compose..."
    docker compose down
    exit
}

trap ctrl_c INT

sleep_time=$1
filename="proxy.txt"

echo "http://vpn1:8080" > "$filename"
echo "http://vpn2:8080" >> "$filename"

docker compose up -d

# I have added the echo outside of the docker exec, cause sometimes mubeng dies and then proxy.txt gets empty

while true; do
    sleep "$sleep_time"
    echo "Restarting VPN 1"
    docker exec -t mubeng sh -c "echo http://vpn2:8080 > proxy.txt"
    echo http://vpn2:8080 > ./proxy.txt 
    docker exec -t vpn1 protonvpn c -f &>/dev/null &
    sleep 20
    docker exec -t mubeng sh -c "echo http://vpn1:8080 >> proxy.txt"
    echo http://vpn1:8080 >> ./proxy.txt

    sleep "$sleep_time"
    echo "Restarting VPN 2"
    docker exec -t mubeng sh -c "echo http://vpn1:8080 > proxy.txt"
    echo http://vpn1:8080 > ./proxy.txt
    docker exec -t vpn2 protonvpn c -f &>/dev/null &
    sleep 20
    docker exec -t mubeng sh -c "echo http://vpn2:8080 >> proxy.txt"
    echo http://vpn2:8080 >> ./proxy.txt
done
