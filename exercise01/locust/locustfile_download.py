from locust import HttpUser, task, between
import urllib3
import os 

# Disable SSL warnings
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

class NextcloudUser(HttpUser):
    wait_time = between(0.5, 3)
    timeout = 3
    counter = 0

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.user_id = None
        self.auth_token = None
        self.client.verify = False  # Add this line to disable SSL verification
        self.counter = 0

    def on_start(self):
        self.user_id = self.environment.runner.user_count
        self.login()

    def login(self):
        # Log in and capture authentication token
        username = f"user{self.user_id}"
        password = f"this_is_a_secure_password_{self.user_id}"

        response = self.client.post(
            "/index.php/login",
            data={"user": username, "password": password},
            name="Login",
            verify=False
        )

        if response.status_code == 200:
            print(f"User {username} logged in successfully")
            # Extract authentication token from response headers
            self.auth_token = response.headers.get("Set-Cookie", "").split("oc_sessionPassphrase=")[-1].split(";")[0]
        else:
            print(f"Failed to log in for user {username}, tried with password {password}")

    def download_file(self):
        # Download the file from the server
        username = f"user{self.user_id}"
        password = f"this_is_a_secure_password_{self.user_id}"

        filename = "to_upload.txt"
        downloaddir = "downloaded_files"
        downloadName = f"{downloaddir}/downloaded_{self.user_id}_{self.counter}.txt"
        remote_file = f"https://localhost/remote.php/dav/files/{username}/{filename}"

        response = self.client.get(
            remote_file,
            name="Download File",
            auth=(username, password),  # Use the auth parameter for basic authentication
            allow_redirects=True,
            verify=False,
        )

        if response.status_code == 200:
            print(f"User {username} downloaded the file {filename} successfully")
            # write as fast as possible the file: 
            
            with open(downloadName, "wb") as file:
                file.write(response.content)
                self.counter +=1
        else:
            print(f"Failed to download the file {filename} for user {username}")
            # print(response.content)
        
    @task(1)
    def download_scenario(self):
        self.download_file()

# Run the test
def main():
    # Do not show the output of the script
    os.system("locust -f locustfile_download.py --host https://localhost")

if __name__ == "__main__":
    main()

