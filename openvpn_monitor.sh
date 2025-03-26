#!/bin/sh
STATUS_FILE="PATH_STATUS_FILE"
get_discovery() {
    CLIENT_LIST=$(sed -n '/CLIENT LIST/,/ROUTING TABLE/p' "$STATUS_FILE" | tail -n +4 | head -n -1 | cut -d, -f1 | sort | uniq)
    JSON="["
    FIRST=true
    for CN in $CLIENT_LIST; do
        if [ "$FIRST" = true ]; then
            FIRST=false
        else
            JSON="$JSON,"
        fi
        JSON="$JSON{\"CN\":\"$CN\"}"
    done
    JSON="$JSON]"
    echo "$JSON"
}

get_users_count() {
    sed -n '/CLIENT LIST/,/ROUTING TABLE/p' "$STATUS_FILE" | tail -n +4 | head -n -1 | wc -l
}

get_user_data() {
    CN="$1"
    PARAM="$2"
    CLIENT_LIST=$(sed -n '/CLIENT LIST/,/ROUTING TABLE/p' "$STATUS_FILE" | tail -n +4 | head -n -1)
    USER_DATA=$(echo "$CLIENT_LIST" | grep "^$CN,")
    if [ -z "$USER_DATA" ]; then
        echo "User $CN not found"
        exit 1
    fi
    case "$PARAM" in
        real_ip)
            echo "$USER_DATA" | cut -d, -f2 | cut -d: -f1
            ;;
        virtual_ip)
            VIRTUAL_IP=$(sed -n '/ROUTING TABLE/,/GLOBAL STATS/p' "$STATUS_FILE" | grep "$CN," | grep "^[0-9]" | cut -d, -f1 | head -n1)
            echo "$VIRTUAL_IP"
            ;;
        bytes_received)
            echo "$USER_DATA" | cut -d, -f3
            ;;
        bytes_sent)
            echo "$USER_DATA" | cut -d, -f4
            ;;
        connected_since)
            echo "$USER_DATA" | cut -d, -f5
            ;;
        duration)
            CONNECTED_SINCE=$(echo "$USER_DATA" | cut -d, -f5)
            CONNECTED_TIME=$(date -d "$CONNECTED_SINCE" +%s)
            CURRENT_TIME=$(date +%s)
            DURATION=$((CURRENT_TIME - CONNECTED_TIME))
            echo "$DURATION"
            ;;
        *)
            echo "Unknown parameter: $PARAM"
            exit 1
            ;;
    esac
}

if [ "$1" = "discovery" ]; then
    get_discovery
elif [ "$1" = "users.count" ]; then
    get_users_count
elif [ "$1" = "user" ]; then
    CN="$2"
    PARAM="$3"
    get_user_data "$CN" "$PARAM"
else
    echo "Usage: $0 {discovery|users.count|user <CN> <param>}"
    exit 1
fi
