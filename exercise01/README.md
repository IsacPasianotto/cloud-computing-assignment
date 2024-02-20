# Solution for the `Cloud-base` module assignment.

This folder contains the provided solution for the [`Cloud-base` module assignment](https://github.com/Foundations-of-HPC/Cloud-Basic-2023/blob/main/Assignments/Exercise.md). 

The assignment file I've considered (it may be changed after this solution is published) is also available in the [assignment.md](./assignment.md) file. 

## How to run and stop: 

To deploy the provided [`docker-compose.yml`](./docker-compose.yml) file, you need to have `docker` and `docker-compose` installed on your machine, then run:

```bash 
docker network create nextcloud_network
docker volume create nextcloud_data
docker volume create db_data
docker volume create caddy_data

docker-compose up -d
```

Then you can access the Nextcloud instance at `https://localhost` and create an admin account.

*Note:*  A warning is expected due to the self-signed certificate used in the Caddy server.

To stop the running containers, you can run:

```bash
docker-compose down
```

## Load testing

To perform the load test, [`locust`](https://locust.io/) was used. Before to actually perform it, you'll need to set up the installation adding users and some dummy data. 

For example, if you want to add 50 users, you can just run:

```bash
cd scripts
./add_users.sh 50
./upload_files.sh -n 50 -f <file_to_upload> -r <uploaded_file_name>
```


Then, you can run the locust test (if you have not installed it yet, you can do it with `pip install locust`):

```bash
python3 file.py
```

Where `file.py` is the locust file you want to run, some examples are available in the [locust](./locust) folder.

Then you can access the locust web interface at `http://localhost:8089` and start the test.