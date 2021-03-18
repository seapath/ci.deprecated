<!--
Copyright (C) 2021, RTE (http://www.rte-france.com)
SPDX-License-Identifier: CC-BY-4.0
-->

# How to deploy the CI

The following steps describe how to deploy the CI based on the Docker
images by using docker-compose.

## Environment requirements

Please make sure `docker` and `docker-compose` packages are installed
on the host machine.

## Deploying the CI

### Create docker-compose environment file

We use a docker-compose environment file in our docker-compose.yaml to configure
all the environment specific settings.

To generate this file, you can use the script `docker/generate_env.sh`.
Before running the script, you must retrieve the network interface name where
you want the PXE server listen to (you can archieve this with `ip addr`).

Once you have it run the script :
```
./generate_env.sh \
    --interface your_interface \
    --dhcp-range-begin first_dhcp_ip \
    --dhcp-range-end last_dhcp_ip
```
Replace your_interface by the network interface and first_dhcp_ip and
last_dhcp_ip by the IP address range you want to define for the DHCP.
This address range must be in the same network as your network interface.

### Build the images

To build the docker images perform the following commands:

```
cd docker
docker-compose -f docker-compose.yaml build
```

### Create docker-compose stack

To deploy and start the CI perform the following command:

```
docker-compose -f docker-compose.yaml up
```

You can later stop the CI with `docker-compose -f docker-compose.yaml
stop` and start it with `docker-compose -f docker-compose.yaml start`.

### Jenkins configuration

Jenkins UI can be accessed from a navigator with `localhost:8080`. The
initial password for the `admin` can be found inside
`/var/jenkins_home/secrets/initialAdminPassword`.

Install plugins `SSH Agent`, `Pipeline` and `Pipeline Stage View`.

Following configuration can be left with the default values by
selecting `Skip and continue as admin`, `Instance configuration: Not
now` and `Start using jenkins`.

### Credentials

SSH keys used to access Gerrit and GitLab servers can be added from
`Manage Jenkins > Manage Credentials > Global Credentials > Add
Credentials`.

Select `Kind: SSH Username with private key` and enter its `ID`,
`Username`, `Private Key` and `Passphrase`.

Note: The `ID` for each key needs to be accordingly set to
`gerrit-credentials` and `gitlab-credentials`.

### Create job and copy pipeline script

From the main Jenkins UI create a `New item > Pipeline` and copy the
content from `rte/votp/docker/jenkins/Jenkinsfile` inside the
`Pipeline -> Script` section.

This script contains the parametrization and schedule for the job. In
order to apply the configuration, the job must be run once. After
that, the button `Build with parameters` should be available for
subsequentent builds. The job will be automatically triggered every 15
minutes with the default values for the parameters. In order to change
this configuration, you can modify `parameters` and `triggers`
sections of the script.
