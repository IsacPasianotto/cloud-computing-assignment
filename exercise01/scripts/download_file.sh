#!/bin/bash

# Define the base URL of your Nextcloud instance
NEXTCLOUD_URL="https://localhost"

# Define the number of users you want to create
NUM_USERS=5
FILE='to_upload.txt'


# Loop to create users
for ((i=1; i<=$NUM_USERS; i++)); do
    
    DOWNLOADED_FILE="downloaded_$i.txt"    
    USERNAME="user$i"
    PASSWORD="this_is_a_secure_password_$i"

    # Use the Nextcloud API to dowload a file in the user home into currend directory
    # ignore the ssl certificate
    curl -k -u $USERNAME:$PASSWORD -X GET $NEXTCLOUD_URL/remote.php/dav/files/$USERNAME/$FILE -o $DOWNLOADED_FILE


done
