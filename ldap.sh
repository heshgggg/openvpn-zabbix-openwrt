#!/bin/sh
urname=ldap_auth.sh
facility=auth

ldapserver=server 
domain=domain
vpngroup=group_for_access
basedn='CN=group,DC=domain,DC=domain,DC=random'


auth_file="$1"

if [ -z "$auth_file" ] || [ ! -f "$auth_file" ]; then
  logger -p "${facility}.err" -t "${ourname}" "No authentication file provided or file does not exist"
  exit 0
fi

username=$(sed -n '1p' "$auth_file")
password=$(sed -n '2p' "$auth_file")

if [ -z "$username" ] || [ -z "$password" ]; then
  logger -p "${facility}.err" -t "${ourname}" "Username or password is empty in auth file $auth_file"
  exit 0
fi

bindname=${username}@${domain}

filter="(&(sAMAccountName=$username)(memberOf=CN=$vpngroup,$basedn)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))"

output=$(mktemp)
error=$(mktemp)

trap "rm -f ${output} ${error}" EXIT

logger -p "${facility}.info" -t "$ourname" "Trying to authenticate user ${bindname} against AD"

ldapsearch -L -s sub -x -w "$password" -D "$bindname" -b "$basedn" -H "ldap://${ldapserver}.${domain}" "$filter" dn >"$output" 2>"$error"

status=$?

log_query="-L -s sub -x -w xxxxxxxx -D '$bindname' -b '$basedn' -H 'ldap://${ldapserver}.${domain}' '$filter' dn"

if [ $status -ne 0 ]; then
  logger -p "${facility}.err" -t "${ourname}" "There was an error authenticating user ${username} (${bindname}) against AD."
  logger -p "${facility}.err" -t "${ourname}" "The query was: ldapsearch $log_query"
  logger -p "${facility}.err" -t "${ourname}" "The error was: $(tr '\n' ' ' < "${error}")"
  exit 1
fi

numentries=$(awk '/numEntries:/{ne = $3} END{print ne + 0}' "$output")

if [ $numentries -eq 1 ]; then
  logger -p "${facility}.info" -t "${ourname}" "User ${username} authenticated successfully"
  exit 0
else
  logger -p "${facility}.err" -t "${ourname}" "User ${username} NOT authenticated (user not in group?)"
  logger -p "${facility}.err" -t "${ourname}" "The query was: ldapsearch $log_query"
  exit 1
fi
