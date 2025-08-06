# devcontainer
A hardened dev environment in a container. For use with vscode. Via ssh; not containers.dev.


## Setup

At the example of mounting `~/git/OpenTTD` into the container.

```sh
$ podman build -t devcontainer-deb-ssh-image .
$ podman run --name devcontainer-deb-ssh -p 127.0.0.1:2222:22 --user 0:0 --userns keep-id:uid=1000,gid=1000 --mount type=bind,src=${HOME:?}/git/OpenTTD,target=/home/vscode/git/OpenTTD -d devcontainer-deb-ssh-image
```


TODO:
Failed to save 'test': Unable to write file 'vscode-remote://ssh-remote+127.0.0.1/home/vscode/git/OpenTTD/test' (NoPermissions (FileSystemError): Error: EACCES: permission denied, open '/home/vscode/git/OpenTTD/test')
trying --user=vscode 
Thanks
https://www.reddit.com/r/podman/comments/103ut7z/explain_it_like_im_5_whats_the_recommended_way_of/
Options explained
By default, we run the sshd as root, so we need `--user 0:0`.
But we want to be able to access `/home/vscode/git/OpenTTD` as the `vscode` user. So we need to make make sure we propagate the this. This assumes the host user has `id -u` as 1000. TODO: test with different uid. Replace with `id -u` and make a variable to explain this.


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

Connect VS Code.



TODO 
Example to build openttd

```sh
$ podman exec -it devcontainer-deb-ssh /bin/bash
root@container:/# apt install -y --no-install-recommends bzip2 ca-certificates cmake git gnupg2 libc6-dev libfile-fcntllock-perl libfontconfig-dev libicu-dev liblzma-dev liblzo2-dev libsdl1.2-dev libsdl2-dev libxdg-basedir-dev make software-properties-common tar wget xz-utils zlib1g-dev
```

and run in bubblewrap
