#!/bin/bash

# Define the base URL of your Nextcloud instance
NEXTCLOUD_URL="https://localhost"

# Define the number of users you want to create

# check if the number of users is passed as an argument
if [ -z "$1" ]; then
    NUM_USERS=10
else
    NUM_USERS=$1
fi


FILE='to_upload.txt'

# Copy the file into the container just once
docker cp $FILE nextcloud-app:/var/www/html/$FILE

# Loop to create users
for ((i=0; i<=$NUM_USERS; i++)); do
    USERNAME="user$i"
    PASSWORD="this_is_a_secure_password_$i"

    # Use the Nextcloud API to upload the file
    # ignotr SSL certificate with -k
    curl -k -u $USERNAME:$PASSWORD -X PUT -T $FILE $NEXTCLOUD_URL/remote.php/dav/files/$USERNAME/$FILE
    # print message to the console if the file was uploaded or not
    if [ $? -eq 0 ]; then
        echo "File $FILE uploaded successfully for user $USERNAME"
    else
        echo "File $FILE could not be uploaded for user $USERNAME"
    fi


done
