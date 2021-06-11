<!--
Copyright (C) 2021, RTE (http://www.rte-france.com)
SPDX-License-Identifier: CC-BY-4.0
-->

# How to deploy the CI

The following steps describe how to deploy the CI based on the Docker
images by using docker-compose.

## Environment requirements

Please make sure `docker` and `docker-compose` packages are installed on
the host machine.

## Deploying the CI

### Create docker-compose environment file

We use a docker-compose environment file in our _docker-compose.yaml_ to
configure all the environment-specific settings.

To generate this file, you can use the script _docker/generate_env.sh_.

```
./generate_env.sh
```

#### Yocto cache

The script _docker/generate_env.sh_ also creates the folder where Yocto
cache will be stored (_/var/jenkins_home/yocto_). If you ever need to
update the cache you can store the sstate Yocto cache into
_/var/jenkins_home/yocto/sstate_.

### Build the images

To build the docker images perform the following commands:

All docker-compose command must be run in the _docker_ directory at the
same directory level of the _docker-compose.yaml_ file.

```
docker-compose build
```

### Create docker-compose stack

To deploy and start the CI perform the following command:

```
docker-compose up -d
```

If you remove the _-d_ parameter it will the command in foreground and
you will have access to containers logs. You can stop it by pressing
_CTRL+C_ keys.

You can later stop the CI with `docker-compose stop` and start it with
`docker-compose start`.

To undeploy the CI use `docker-compose down`.

For more informations about the `docker-compose` command see the
official documentation at https://docs.docker.com/compose/.

### Jenkins configuration

Jenkins UI can be accessed from a navigator with `localhost:8080`. The
initial password for the `admin` user can be found inside
`/var/jenkins_home/secrets/initialAdminPassword`.

Install plugins `SSH Agent`, `Pipeline`, `Pipeline Stage View`, `JUnit`,
`Blue Ocean`, `Pipeline Utility Steps` and `Throttle Concurrent Builds`.

Following configuration can be left with the default values by selecting
`Skip and continue as admin`, `Instance configuration: Not now` and
`Start using jenkins`.

### SSH Credentials

Three SSH credentials need to be configured in order to access Gerrit
server, GitLab server and the cluster machines.

You can add them from `Manage Jenkins > Manage Credentials > Global
Credentials > Add Credentials`.

Select `Kind: SSH Username with private key` and enter its `ID`,
`Username`, `Private Key` and `Passphrase`.

Note: The `ID` for each key needs to be accordingly set to
`gerrit-credentials`, `gitlab-credentials` and `cluster`.

### Throttle Concurrent Builds

To prevent simultaneous access to the cluster machines from different
Jenkins jobs, the plugin `Throttle Concurrent Builds` is used.

Please, make sure it is installed. Then you can access its configuration
from `Manage Jenkins > Configure System > Throttle Concurrent Builds`
and set the following values under `Multi-project Throttle Categories`:

* Category Name: cluster
* Maximum Total Concurrent Builds: 1
* Maximum Concurrent Builds Per Node: 1

It is also necessary to configure another category for the
synchronization jobs:

* Category Name: sync
* Maximum Total Concurrent Builds: 1
* Maximum Concurrent Builds Per Node: 1

Finally you can save the configuration.

### Install the CI material

#### Prerequisites

To be able to use Jenkins CI Jobs, the following material is required:

* 2 hypervisor machines

Those machines must be 64 bits Intel architecture with a NIC DPDK
compatible. Each hypervisor should have 2 distinct harddisks:

* One disk for the system
* One disk for Ceph

* 1 observer machine

1 observer machine must be provided in order to create a cluster quorum.

* 1 EG-PMS2-LAN programmable power supply

This programmable power supply will be triggered by Jenkins to
electrically restart the machines.

Hypervisor and observer machines must be configured to:

1. Boot from PXE in first priority in the bios configuration
2. Automatically power on the machine

#### Network configuration

The CI needs at least three networks to work:

* a management network which includes
- The hypervisors and the observer
- The CI server

* a cluster network which includes:
- The hypervisors and the observer

* a VMs network which includes
- The two hypervisors connected with a DPDK compatible Ethernet NIC

1. Configure the PXE

A configuration (_.conf_) file for the PXE's DHCP needs to be added on
the _docker/pxe/pxe\_extra\_config\_ folder. It should be filled with
the following information:

The MAC address should be described as first argument following by its
IP address. The IP addresses should be static or have fixed DHCP
leasing.

```
# Programmable power supply
dhcp-host=??:??:??:??:??:??,???.???.???.???
# Hypervisor 1
dhcp-host=??:??:??:??:??:??,???.???.???.???
# Hypervisor 2
dhcp-host=??:??:??:??:??:??,???.???.???.???
# Observer
dhcp-host=??:??:??:??:??:??,???.???.???.???
```

2. Jenkins configuration

A Jenkins properties file is used to configure the CI (view
`docker/jenkins/extra_config/*.properties)`. Please make sure that
`/var/jenkins_home/jenkins.properties` exists. The file can be
copy-pasted from `docker/jenkins/extra_config` and modified according to
your setup.

3. Adapt the Ansible inventory

The Ansible inventory will be used by Ansible to configure each machine
of the CI and trigger the electrical reboots.

This file can be accessed from a remote repository or placed on the
local CI machine according to configuration from jenkins.properties
file.

If you need to create your own inventory you can use
inventories/seapath.yaml as a template.

### Create jobs and import pipeline from SCM

Current CI is based on three jenkins jobs and their corresponding
script:

- Jenkinsfile_sync_sfl: It handles the synchronization between Gerrit
  and GitLab sfl/master branches. It is automatically triggered when a
  new commit is added on Gerrit.

- Jenkinsfile_ci: Triggered once the previous syncronization step has
  succeed. It fetches from rte-sfl.xml manifest and checks that the
  different builds and tests pass correctly.

- Jenkinsfile_merge: Triggered once the CI succeeds in order to merge
  GitLab sfl/master into rte/master branch.

In order to create each job you can select `New item > Pipeline` from
the main Jenkins UI. Note: The name for the last two jobs needs to be
accordingly set to `ci` and `merge`.

Then, select `Pipeline script from SCM` on the `Pipeline ->
Definition` scrollable menu. The following configuration must be set:

- SCM: Git
- Repository URL: `ssh://rteci@g1.sfl.team:29419/rte/votp/ci`
- Credentials: SSH Gerrit credentials (previously configured)
- Branch specifier: `*/master`
- Script path: `docker/jenkins/Jenkinsfile_` (corresponding suffix)

You can save the job and reproduce the same process for each of the
three.

In order to apply the configuration of the Jenkinsfile_sync_sfl, its job
must be run once. After that, the three jobs should be sequentially
triggered for every new commit merged on Gerrit's sfl/master branch.

