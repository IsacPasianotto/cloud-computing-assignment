#!/bin/bash

# Define the base URL of your Nextcloud instance
NEXTCLOUD_URL="https://localhost"


# check if there is a given argument
# if not, set NUM_USERS to 10
#
if [ -z "$1" ]
then
    NUM_USERS=10
else
    NUM_USERS=$1
fi

# Loop to create users
for ((i=0; i<=$NUM_USERS; i++)); do
    USERNAME="user$i"
    PASSWORD="this_is_a_secure_password_$i"
    
    # Run the OCC command to create the user and set the password
    docker exec -i -u 33 nextcloud-app bash -c "export OC_PASS=$PASSWORD && /var/www/html/occ user:add $USERNAME --password-from-env"

    # Set the email address for the user
    # docker exec -u 33 nextcloud-app php occ user:setting $USERNAME settings email "user$i@$NEXTCLOUD_URL"
done

