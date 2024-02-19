from locust import HttpUser, task, between
import urllib3

# Disable SSL warnings
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

class NextcloudUser(HttpUser):
    wait_time = between(0.5, 3)
    # max_retries = 3
    timeout = 3

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.user_id = None

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
            verify=False  # Disable SSL verification
        )
        if response.status_code == 200:
            print(f"User {username} logged in successfully")
        else:
            print(f"Failed to log in for user {username}, tried with password {password}")

        # logout to free up resources
        self.client.get(
            "/index.php/logout",
            name="Logout",
            verify=False  # Disable SSL verification
        )
        if response.status_code == 200:
            print(f"User {username} logged out successfully")
        else:
            print(f"Failed to log out for user {username}")

    

    @task(1)
    def login_scenario(self):
        self.login()

    # @task(2)
    # def download_file_scenario(self):
    #     self.login()
    #     self.download_file()
    #
    # def download_file(self):
    #     response = self.client.get(
    #         "/index.php/apps/files/to_upload.txt",
    #         name="Download File",
    #         verify=False  # Disable SSL verification
    #     )
    #     if response.status_code == 200:
    #         print(f"File downloaded successfully for user {self.user_id}")
    #     else:
    #         print(f"Failed to download file for user {self.user_id}")
    #

# Run the test: 

def main(): 
    import os
    os.system("locust -f locustfile.py --host https://localhost")


if __name__ == "__main__":
    main()
