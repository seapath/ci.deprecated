<!--
Copyright (C) 2021, RTE (http://www.rte-france.com)
SPDX-License-Identifier: CC-BY-4.0
-->

# How to test the Jenkins docker image

The following setup is based on the project
https://github.com/jenkinsci/docker.

The Jenkins docker image is intended to be launched by
docker-compose. It is however possible to launch it in standalone mode
to test.

## Preparation environement

On the host machine create `/var/jenkins_home` and give user
ownership:

```
mkdir /var/jenkins_home
sudo chown -R 1000:1000 /var/jenkins_home
```

## Build and launch Jenkins docker

Build-time variable `dockergid` needs to be set to the docker group.

```
docker_gid=$(cut -d: -f3 <(getent group docker))
docker build -t jenkins_test --build-arg dockergid=${docker_gid}  .
docker run -p 8080:8080 -v /var/jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock -v /tmp:/tmp jenkins_test
```

Note: `/var/jenkins_home`, `/var/run/docker.sock` and `/tmp` are used
as volumes in order to be capable of launching *cqfd* on the
dockerized Jenkins server.

## Test jenkins server

The dockerized jenkins server can be accessed from
localhost:8080. Modifications done on the server will be saved on the
host `/var/jenkins_home` folder, that can also be used to share the
configuration with another machine.
