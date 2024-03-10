from locust import HttpUser, task, between
from requests.auth import HTTPBasicAuth
import urllib3
import random 
import os

# Disable SSL warnings
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

class NextcloudUser(HttpUser):
    wait_time = between(1, 1)
    timeout = between(0.5, 3)
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
            with open(downloadName, "wb") as file:
                file.write(response.content)
                self.counter += 1

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

    # Weighted tasks will assign to a user always the same task.
    # In this case, every user will perform a random action at each request
    @task(1)
    def perform_an_action(self):
        random_float = random.random()
        #  Task:         Prob
        #  Download       0.3
        #  Upload small   0.3
        #  Upload medium  0.35
        #  Upload large   0.05
        if random_float < 0.3:
            self.download_file()
        elif random_float < 0.6:
            self.upload_files("small")
        elif random_float < 0.95:
            self.upload_files("medium")
        else:
            self.upload_files("large")

    

# Run the test
def main():
    os.system("locust -f realistic-scenario.py --host https://localhost")

if __name__ == "__main__":
    main()
