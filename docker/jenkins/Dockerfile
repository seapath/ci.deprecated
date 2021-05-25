# Copyright (C) 2021, RTE (http://www.rte-france.com)
# SPDX-License-Identifier: Apache-2.0

FROM jenkins/jenkins

# Needs to be set to docker group
ARG dockergid=134

# Avoid '@' symbol on workspace paths
ENV JAVA_OPTS="-Dhudson.slaves.WorkspaceList=X -Djava.awt.headless=true"

USER root

RUN groupadd --gid ${dockergid} docker

RUN apt-get update && \
    apt-get install -y \
        docker.io \
        python3 \
        python3-libvirt \
        python3-setuptools \
        git \
        make \
        pkg-config \
        bash-completion

ADD https://bootstrap.pypa.io/get-pip.py get-pip.py
RUN python3 ./get-pip.py
RUN pip install ansible==2.9
RUN pip install netaddr
RUN pip install docker
RUN pip install six

RUN usermod -aG docker jenkins

RUN git clone https://github.com/savoirfairelinux/cqfd.git
RUN cd cqfd && make install

RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo
RUN sed -i '1s/python/python3/g' /usr/local/bin/repo
RUN chmod a+rx /usr/local/bin/repo

VOLUME /var/jenkins_home
VOLUME /var/run/docker.sock
VOLUME /tmp

EXPOSE 8080/tcp
EXPOSE 50000/tcp

USER jenkins
