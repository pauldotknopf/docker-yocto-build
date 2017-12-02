FROM ubuntu:xenial

RUN apt-get update

RUN apt-get install -q -y gawk wget git-core diffstat unzip texinfo gcc-multilib \
     build-essential chrpath socat cpio python python3 python3-pip python3-pexpect \
     xz-utils debianutils iputils-ping libsdl1.2-dev xterm

# Fix error "Please use a locale setting which supports utf-8."
# See https://wiki.yoctoproject.org/wiki/TipsAndTricks/ResolvingLocaleIssues
RUN apt-get install -y locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
        echo 'LANG="en_US.UTF-8"'>/etc/default/locale && \
        dpkg-reconfigure --frontend=noninteractive locales && \
        update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN apt-get clean

# When building the kernel, this is needed
RUN git config --system user.email "nobody@nobody.com"
RUN git config --system user.name "No Body"

ADD bk /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa
ADD bk /

RUN echo "StrictHostKeyChecking=no" | tee -a /etc/ssh/ssh_config

ADD entrypoint-script /

ENTRYPOINT ["/entrypoint-script"]
