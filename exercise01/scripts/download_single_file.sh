#!/bin/bash

# Define the base URL of your Nextcloud instance
NEXTCLOUD_URL="https://localhost"

# Define the number of users you want to create

# the numuser is passed as a parameter
NUM_USERS=$1
DONWLOAD_DIR=downloaded_files



FILE='to_upload.txt'


# Loop to create users
    
DOWNLOADED_FILE="downloaded_$NUM_USERS.txt"    
USERNAME="user$NUM_USERS"
PASSWORD="this_is_a_secure_password_$NUM_USERS"

# Use the Nextcloud API to dowload a file in the user home into currend directory
# ignore the ssl certificate
#
# redirect the output to not show the progress
#
curl -k -u $USERNAME:$PASSWORD -X GET $NEXTCLOUD_URL/remote.php/dav/files/$USERNAME/$FILE -o $DONWLOAD_DIR/$DOWNLOADED_FILE 2&>1 > /dev/null 


