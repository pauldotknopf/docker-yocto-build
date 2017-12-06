FROM ubuntu:xenial

RUN apt-get update

RUN apt-get install -q -y gawk wget git-core diffstat unzip texinfo gcc-multilib \
     build-essential chrpath socat cpio python python3 python3-pip python3-pexpect \
     xz-utils debianutils iputils-ping libsdl1.2-dev xterm

# Install gitversion
RUN apt-get install -q -y mono-complete ca-certificates-mono libcurl3
RUN mkdir -p /usr/local/bin/mono/NuGet && \
     wget -O /usr/local/bin/mono/NuGet/nuget.exe https://dist.nuget.org/win-x86-commandline/v4.5.0/nuget.exe && \
     echo "#!/bin/bash" | tee /usr/local/bin/nuget && \
     echo "exec $(which mono) /usr/local/bin/mono/NuGet/nuget.exe \"\$@\"" | tee -a /usr/local/bin/nuget && \
     chmod +x /usr/local/bin/nuget
RUN mkdir -p /usr/local/bin/mono/GitVersion && \
     wget -O /usr/local/bin/mono/GitVersion/gitversion.zip https://www.nuget.org/api/v2/package/GitVersion.CommandLine/4.0.0-beta0012 && \
     unzip /usr/local/bin/mono/GitVersion/gitversion.zip -d /usr/local/bin/mono/GitVersion && \
     echo "#!/bin/bash" | tee /usr/local/bin/gitversion && \
     echo "exec $(which mono) /usr/local/bin/mono/GitVersion/tools/GitVersion.exe \"\$@\"" | tee -a /usr/local/bin/gitversion && \
     chmod +x /usr/local/bin/gitversion

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

RUN echo "StrictHostKeyChecking=no" | tee -a /etc/ssh/ssh_config

ADD entrypoint-script /

ENTRYPOINT ["/entrypoint-script"]
