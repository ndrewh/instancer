# instancer

Instancer that relies on source-IP based routing for isolation.

- All instances run a SHARED (privileged) docker container -- we use nested `nsjail`s for instances.
- Instances each have an isolated network namespace; each instance can bind to the "same" port(s), and
services can interact within each instance without affecting other instances and without changing
the challenge.
- Requires `--net=host`. Maps ports 9000 (instancer) and 7000-7100 (instances) by default.
- Instances are quickly cleaned up when clients disconenct from the instancer.


## How to setup

- Update the Dockerfile to install your challenge binaries and all dependencies.
- Update `chal/start.sh` to start your challenge.
- Update `docker-compose.yml` with the following env variables
    - `CHALL_INTERNAL_PORT`: This should be whatever port your service listens on.
    - `CHALL_NUM_SERVERS`: Number of simultaneous instances
    - `POW_DIFFICULTY`: Set to nonzero to enable PoW
    - `CHALL_TIMEOUT`: Timeout in seconds
- Optional: Update `chal/jail.cfg` with your nsjail configuration

## How to run

```
docker-compose up
```

You should verify that instances are isolated (i.e. that only the source IP that
connected to the instancer can connect to the instance), since your network setup
may vary.


## ADVANCED: Running behind a TCP proxy such as Traefik

Since this instancer relies on source-ip based routing, proxies will break it since
the instancer will not be able to see the real source IP.

You can fix this by enabling PROXY2 on your proxy, and setting the
`ENABLE_PROXY2=1` environment variable.


