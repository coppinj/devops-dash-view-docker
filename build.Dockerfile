FROM	  	  fedora:30

RUN         dnf upgrade --assumeyes
RUN         dnf install findutils --assumeyes
RUN         dnf install python2 --assumeyes
RUN         ln -sfn /usr/bin/python2 /usr/bin/python
RUN         dnf install java-1.8.0-openjdk --assumeyes
RUN         dnf install java-1.8.0-openjdk-devel --assumeyes
RUN         dnf install java-1.8.0-openjdk-openjfx --assumeyes
RUN         dnf install java-1.8.0-openjdk-openjfx-devel --assumeyes
RUN         dnf install procps --assumeyes

RUN         dnf install tree --assumeyes
RUN         dnf install htop --assumeyes
RUN         dnf install psmisc --assumeyes
RUN         dnf install jq --assumeyes
RUN         dnf install zip --assumeyes

WORKDIR /devops

COPY scripts /devops/scripts
COPY tools /devops/tools

RUN chmod +x -R /devops

CMD /devops/scripts/bash/start.sh
