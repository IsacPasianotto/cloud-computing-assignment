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
        self.client.verify = False  # Add this line to disable SSL verification
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
                self.counter +=1

    @task(1)
    def download_scenario(self):
        self.download_file()

# Run the test
def main():
    os.system("locust -f download.py --host https://localhost")

if __name__ == "__main__":
    main()

