# Some personal notes

***TODO*** Get rid of this file asap (hoping it will be useless)

## About the scaling 

To make the instance scalable, in theory (more investigation is needed) it should be enought to use the `--scale` flag of the `docker-compose up` command. for example: 

```
export TOSCALE=2

doker-compose up -d \ 
    --scale reverse-proxy=$TOSCALE \
    --scale nextcloud-web=$TOSCALE \
    --scale mariadb-database=$TOSCALE \
    --scale nextcloud-app=$TOSCALE \
    --scale nextcloud-cron=$TOSCALE
```

Note that encreasing the value of `TOSCALE` will not ensure an increase in performance. The performance of the instance is limited by the hardware and the network, and spawning more containers will not only not help, but it will also make the system slower.




## About the IO evaluation

Docker provides the command `docker stats` wich gives some info about the I/O of the containers. This command can be used to evaluate the I/O of the containers and to understand if the system is I/O bound.

In theory no other more sophisticated tool is needed to evaluate the I/O of the containers, unlike with the load test for which I've used `locust`

Hopefuly, the I/O of the containers will be the bottleneck of the system, and not the network or the hardware. In this case, the system can be scaled by adding more containers, and the performance will increase linearly with the number of containers.

