FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

LABEL org.label-schema.name="Dev Container" \
	org.label-schema.description="Dev Container for local vscode dev." \
	org.label-schema.url="https://github.com/diekmann/devcontainer" \
	org.label-schema.build-date=$BUILD_DATE

# The user to be used by vscode.
RUN useradd --create-home --shell /bin/bash --uid 1000 --user-group vscode
# We don't switch to the user, since I want a root shell for installing software.
# But we will login via vscode only via ssh, restricted to the vscode user.
#USER vscode
#WORKDIR /home/vscode
# useradd by default creates locked accounts, where we cannot login, even with publickey.
RUN echo vscode:securepassword1 | chpasswd


#TODO: caching! update always with install and rm the cache.

RUN apt update && apt upgrade -y && apt dist-upgrade -y  && \
  apt install -y openssh-server && \
  rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd
COPY ./sshd_config /etc/ssh/sshd_config
COPY --chown=vscode:vscode id_ed25519.pub /home/vscode/.ssh/authorized_keys
EXPOSE 22
RUN service ssh start
ENTRYPOINT ["/usr/sbin/sshd","-D"]

# OpenTTD build deps
RUN apt update && apt install -y --no-install-recommends build-essential bzip2 ca-certificates cmake git gnupg2 libc6-dev libfile-fcntllock-perl libfontconfig-dev libicu-dev liblzma-dev liblzo2-dev libsdl1.2-dev libsdl2-dev libxdg-basedir-dev make software-properties-common tar wget xz-utils zlib1g-dev && rm -rf /var/lib/apt/lists/*

