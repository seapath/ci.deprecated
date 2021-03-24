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

We use a docker-compose environment file in our _docker-compose.yaml_ to configure
all the environment-specific settings.

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

All docker-compose command must be run in the _docker_ directory at the same
directory level of the _docker-compose.yaml_ file.

```
docker-compose build
```

### Create docker-compose stack

To deploy and start the CI perform the following command:

```
docker-compose up -d
```

If you remove the _-d_ parameter it will the command in foreground and you will
have access to containers logs. You can stop it by pressing _CTRL+C_ keys.

You can later stop the CI with `docker-compose stop` and start it with
`docker-compose start`.

To undeploy the CI use `docker-compose down`.

For more informations about the `docker-compose` command see the official
documentation at https://docs.docker.com/compose/.

### Jenkins configuration

Jenkins UI can be accessed from a navigator with `localhost:8080`. The
initial password for the `admin` user can be found inside
`/var/jenkins_home/secrets/initialAdminPassword`.

Install plugins `SSH Agent`, `Pipeline`, `Pipeline Stage View` and
`JUnit`.

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
the main Jenkins UI. Then, select `Pipeline script from SCM` on the
`Pipeline -> Definition` scrollable menu. The following configuration
must be set:

- SCM: Git
- Repository URL: `ssh://rteci@g1.sfl.team:29419/rte/votp/ci`
- Credentials: SSH Gerrit credentials (previously configured)
- Branch specifier: `*/master`
- Script path: `docker/jenkins/Jenkinsfile_` (corresponding suffix)

You can save the job and reproduce the same process for each of the
three.

Jenkinsfile scripts contain the parametrization and schedule for the
job. In order to apply the configuration, each job must be run
once. After that, the button `Build with parameters` should be
available for subsequentent builds.

Once the configuration has been done the three jobs should be
sequentially triggered for every new commit merged on Gerrit's
sfl/master branch.
