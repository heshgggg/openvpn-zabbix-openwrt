#!/bin/sh
STATUS_FILE="PATH_STATUS_FILE"
TOTAL_CONNECTIONS=$(sed -n '/CLIENT LIST/,/ROUTING TABLE/p' $STATUS_FILE | tail -n +4 | head -n -1 | wc -l)
echo $TOTAL_CONNECTIONS
