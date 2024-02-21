from locust import HttpUser, task, between
import urllib3
import os

# Disable SSL warnings
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

class NextcloudUser(HttpUser):
    wait_time = between(0.5, 3)
    timeout = 3

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.user_id = None

    def on_start(self):
        self.user_id = self.environment.runner.user_count
        

    def login(self):
        username = f"user{self.user_id}"
        password = f"this_is_a_secure_password_{self.user_id}"

        # login 

        response = self.client.post(
            "/index.php/login",
            data={"user": username, "password": password},
            name="Login",
            verify=False  # Disable SSL verification
        )
            
    @task(1)
    def login_scenario(self):
        self.login()

def main(): 
    os.system("locust -f login.py -H https://localhost")


if __name__ == "__main__":
    main()
