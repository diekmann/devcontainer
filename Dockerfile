ARG DISTRO=debian
ARG RELEASE=bookworm-slim
FROM ${DISTRO}:${RELEASE}

ENV DEBIAN_FRONTEND=noninteractive

LABEL org.label-schema.name="Dev Container" \
	org.label-schema.description="Dev Container for local vscode dev." \
	org.label-schema.url="https://github.com/diekmann/devcontainer" \
	org.label-schema.build-date=$BUILD_DATE

# The user to be used by vscode.
RUN useradd -ms /bin/bash vscode
# We don't switch to the user, since I want a root shell for installing software.
# But we will login via vscode only via ssh, restricted to the vscode user.
#USER vscode
#WORKDIR /home/vscode
# useradd by default creates locked accounts, where we cannot login, even with publickey.
RUN echo vscode:securepassword1 | chpasswd


RUN apt update && apt upgrade -y && apt dist-upgrade -y

# For debugging: ss
RUN apt install -y --no-install-recommends iproute2

RUN apt install -y openssh-server
RUN mkdir /var/run/sshd
COPY ./sshd_config /etc/ssh/sshd_config
RUN mkdir /home/vscode/.ssh
COPY id_ed25519.pub /home/vscode/.ssh/
RUN cat /home/vscode/.ssh/id_ed25519.pub > /home/vscode/.ssh/authorized_keys
EXPOSE 22
RUN service ssh start
ENTRYPOINT ["/usr/sbin/sshd","-D"]
