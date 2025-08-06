# devcontainer
A hardened dev environment in a container. For use with vscode. Via ssh; not containers.dev.


## Setup

TODO: mount volume git

```sh
$ podman build -t devcontainer-deb-ssh-image .
$ podman run --name devcontainer-deb-ssh -p 127.0.0.1:2222:22 -d devcontainer-deb-ssh-image
```

## Starting

```sh
$ podman start devcontainer-deb-ssh
```

Debug that the container is up:

```sh
$ ssh -v -p2222 vscode@127.0.0.1
```

Manage (root shell):

```sh
$ podman exec -it devcontainer-deb-ssh /bin/bash
```

TODO 
Example to build openttd

apt install -y --no-install-recommends bzip2 ca-certificates cmake git gnupg2 libc6-dev libfile-fcntllock-perl libfontconfig-dev libicu-dev liblzma-dev liblzo2-dev libsdl1.2-dev libsdl2-dev libxdg-basedir-dev make software-properties-common tar wget xz-utils zlib1g-dev

and run in bubblewrap
