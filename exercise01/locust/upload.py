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

    def upload_files(self):
        username = f"user{self.user_id}"
        password = f"this_is_a_secure_password_{self.user_id}"
        filename = "to_upload.txt"
        remotefilename = f"{username}_{filename}_{self.counter}"

        # login to the server with the user credentials
        self.client.get(
            "/index.php/login",
            name="Login",
            auth=(username, password),
            verify=False
        )

        # Upload the file to the server
        with open(filename, "rb") as file:
            response = self.client.put(
                f"/remote.php/dav/files/{username}/{remotefilename}",
                data=file,
                name="Upload File",
                auth=(username, password),
                verify=False,
            )

        if response.status_code == 201:
            print(f"User {username} uploaded the file {filename} successfully")
            self.counter += 1
        else:
            print(f"Failed to upload the file {filename} for user {username}")
            print(response.content)

    @task(1)
    def upload_scenario(self):
        self.upload_files()


# Run the test
def main():
    os.system("locust -f upload.py --host https://localhost")

if __name__ == "__main__":
    main()

