from locust import HttpUser, task, between
from requests.auth import HTTPBasicAuth
import urllib3
import os

# Disable SSL warnings
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

class NextcloudUser(HttpUser):
    wait_time = between(0.5, 3)
    timeout = 10
    counter = 0

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.user_id = None
        self.counter = 0

    def on_start(self):
        self.user_id = self.environment.runner.user_count
        self.login()

    def login(self):
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
        else:
            print(f"Failed to log in for user {username}, tried with password {password}")

    def download_file(self):
        username = f"user{self.user_id}"
        password = f"this_is_a_secure_password_{self.user_id}"

        filename = "to_download.txt"
        downloaddir = "downloaded_files"
        downloadName = f"{downloaddir}/downloaded_{self.user_id}_{self.counter}.txt"
        remote_file = f"https://localhost/remote.php/dav/files/{username}/{filename}"

        response = self.client.get(
            remote_file,
            name="Download File",
            auth=(username, password),
            allow_redirects=True,
            verify=False,
        )

        if response.status_code == 200:
            print(f"User {username} downloaded the file {filename} successfully")
            with open(downloadName, "wb") as file:
                file.write(response.content)
                self.counter += 1
        else:
            print(f"Failed to download the file {filename} for user {username}")

    def upload_files(self, filename="small"):
        username = f"user{self.user_id}"
        password = f"this_is_a_secure_password_{self.user_id}"
        remotefilename = f"{username}_{filename}_{self.counter}"
        filename = f"to_upload_files/{filename}"

        # login to the server with the user credentials
        self.client.get(
            "/index.php/login",
            name="Login",
            auth=HTTPBasicAuth(username, password), 
            verify=False
        )

        # Upload the file to the server
        with open(filename, "rb") as file:
            response = self.client.put(
                f"/remote.php/dav/files/{username}/{remotefilename}",
                data=file,
                name="Upload File",
                auth=HTTPBasicAuth(username, password), 
                verify=False,  # Add this line to disable SSL verification
            )

        if response.status_code == 204:
            print(f"User {username} uploaded the file {filename} successfully")
            self.counter += 1
        else:
            print(f"Failed to upload the file {filename} for user {username}")
            print(response.content)

    @task(7)
    def download(self):
        self.download_file()

    @task(10)
    def upload_small(self):
        self.upload_files("small")

    @task(8)
    def upload_medium(self):
        self.upload_files("medium")

    @task(1)
    def upload_large(self):
        self.upload_files("large")

# Run the test
def main():
    os.system("locust -f realistic-scenario.py --host https://localhost")

if __name__ == "__main__":
    main()
