#!/bin/bash

NEXTCLOUD_URL="https://localhost"

if ! [ -x "$(command -v docker)" ]; then
    echo "Error: docker is not installed." >&2
    exit 1
fi

if ! docker ps | grep -q nextcloud-app; then
    echo "Error: nextcloud-app container is not running." >&2
    exit 1
fi

if [ $# -gt 1 ]
then
    echo "Error: too many arguments provided" >&2
    echo "Please provide only one argument, which is the number of users to create or leave it empty to create 10 users." 
    exit 1
fi

if [ -z "$1" ]
then
    NUM_USERS=10
else
    if ! [[ $1 =~ ^[0-9]+$ ]]
    then
        echo "Error: the argument provided is not a number" >&2
        echo "Please provide a number as the argument, which is the number of users to create"
        exit 1
    else
        NUM_USERS=$1
    fi
fi

for ((i=1; i<=$NUM_USERS; i++)); do
    USERNAME="user$i"
    PASSWORD="this_is_a_secure_password_$i"
    docker exec -i -u 33 nextcloud-app bash -c "export OC_PASS=$PASSWORD && /var/www/html/occ user:add $USERNAME --password-from-env"
done

