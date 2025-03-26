#!/bin/sh
STATUS_FILE="PATH_STATUS_FILE"
get_auth_user(){
	USER=$(logread | grep "auth.info : User" | grep "authenticated successfully" | awk '{print $9}' | sort | uniq)
	USER_LIST=$(sed -n '/CLIENT LIST/,/ROUTING TABLE/p' $STATUS_FILE | tail -n +4 | head -n -1 | cut -d , -f1)
	ACTIVE_AUTH_USERS=$(echo "$USER" | grep -w -f <(echo "$USER_LIST"))
	COUNT=$(echo "$ACTIVE_AUTH_USERS" | wc -l)
	echo $COUNT 
}
get_auth_user
