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

while [[ $# -gt 0 ]]; do
    case "$1" in
        -n | --num-users)
            NUM_USERS=$2
            shift 2
            ;;
        -f | --file)
            FILE=$2
            shift 2
            ;;
        -r | --remote-file)
            REMOTE_FILE=$2
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -n   --num-users <number>  Number of users in which to upload the file (default: 10)"
            echo "  -f   --file <file>         File to upload"
            echo "  -r   --remote-file <file>  Remote file name"
            echo "  --help                     Show this help message"
            exit 0
            ;;
        *)
            echo "Error: invalid option $1" >&2
            exit 1
            ;;
    esac
done

if [ -z "$NUM_USERS" ]; then
    NUM_USERS=10
fi
if ! [[ $NUM_USERS =~ ^[0-9]+$ ]]; then
    echo "Error: the argument provided is not a number" >&2
    echo "Please provide a number as the argument, which is the number of users to create"
    exit 1
fi

if [-z "$FILE" ]; then
    FILE='to_upload.txt'
fi 

if ! [ -f "$FILE" ]; then
    echo "Error: the file $FILE does not exist" >&2
    exit 1
fi

if [-z "$REMOTE_FILE" ]; then
    REMOTE_FILE=$FILE
fi

# Copy the file into the container just once
docker cp $FILE nextcloud-app:/var/www/html/$FILE

for ((i=1; i<=$NUM_USERS; i++)); do
    USERNAME="user$i"
    PASSWORD="this_is_a_secure_password_$i"
    # -k flag is used to ignore SSL certificate validation
    curl -k -u $USERNAME:$PASSWORD -X PUT -T $FILE $NEXTCLOUD_URL/remote.php/dav/files/$USERNAME/$REMOTE_FILE
    if [ $? -eq 0 ]; then
        echo "File $FILE uploaded successfully for user $USERNAME"
    else
        echo "File $FILE could not be uploaded for user $USERNAME"
    fi
done
