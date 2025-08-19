# devcontainer

A hardened dev environment in a container. For use with vscode. Via ssh.

## Related Work

The VS-Code-native [containers.dev](https://containers.dev) by Microsoft also provides development containers.
It's probably a smoother and more convenient setup.

After testing it out, I chose to build my own, because

* containers.dev seems to work best with (root) docker, whereas I prefer to work with rootless podman
  * Side-note: I tried the containers.dev with rootless podman and I was very confused that `podman ps -a` did not show a single containers.dev container.
  I'm very sure this was a side effect of running VS Code via the official Snap package on Ubuntu.
  A Snap is basically a container itself.
  And starting podman from this environment likely confuses uses the Snap containers `$XDG_RUNTIME_DIR`, not using my user's `/run/user/$UID`.
  [podman heavily relies on this folder to store the state for running containers](https://www.redhat.com/en/blog/sudo-rootless-podman).
* containers.dev allows to check in the container definition into the target repository into `.devcontainer/`.
This is a great feature to ship the source code and the definition of the build environment in one go.
At the same time, pulling a random repository and opening it in VS Code means arbitrary code execution (after clicking I trust the repo) on my host machine.
It's a great setup for trusted code.
But my requirements are different: I want to assume I don't fully trust the random remote repository and I want to run it and its VS Code extensions somewhat isolated from my host system.
This requires that the devcontainer definition is *not* part of the source code, but provided by a trusted separate party.
It's a security tradeoff where I chose inconvenience in exchange for better control over the supply chain.
* It is fun building and exploring environments.

## Setup

At the example of mounting `~/git/OpenTTD` into the container.

We assume rootless podman.

```sh
$ cp ~/.ssh/id_ed25519.pub .
$ podman build -t devcontainer-deb-ssh-image .
```

To create a container to build the image:

```sh
$ podman run --name devcontainer-deb-ssh -p 127.0.0.1:2222:22 --user 0:0 --userns keep-id:uid=1000,gid=1000 --mount type=bind,src=${HOME:?}/git/OpenTTD,target=/home/vscode/git/OpenTTD -d devcontainer-deb-ssh-image
```


Options explained

* The sshd in the container is bound to `127.0.0.1:2222`, not externally reachable.
* By default, we run the sshd as root, so we need `--user 0:0`.
* But we want to be able to access `/home/vscode/git/OpenTTD` as the `vscode` user.
  The `--userns keep-id:uid=1000,gid=1000` maps our local host user to the container uid 1000 (hard-coded in the Dockerfile), so the mounted `${HOME:?}/git/OpenTTD` is effectively owned by the same non-root user in the host and in the container.
  (thanks [reddit](https://www.reddit.com/r/podman/comments/103ut7z/explain_it_like_im_5_whats_the_recommended_way_of/))
  


To actually run OpenTTD with graphics from the container, the initial `podman run` additionally needs to mount the wayland socket into the container: `--mount type=bind,src="${XDG_RUNTIME_DIR:?}/${WAYLAND_DISPLAY:?}",target=/run/user/1000/wayland-0,ro=true`.
For hardware acceleration, add `--device /dev/dri`.
Security warning: the more we expose the host system into the container, the worse the isolation gets!

```sh
$ podman run --name devcontainer-deb-ssh -p 127.0.0.1:2222:22 --user 0:0 --userns keep-id:uid=1000,gid=1000 --mount type=bind,src=${HOME:?}/git/OpenTTD,target=/home/vscode/git/OpenTTD --mount type=bind,src="${XDG_RUNTIME_DIR:?}/${WAYLAND_DISPLAY:?}",target=/run/user/1000/wayland-0,ro=true -e XDG_RUNTIME_DIR=/run/user/1000 -e WAYLAND_DISPLAY=wayland-0 --device /dev/dri -d devcontainer-deb-ssh-image
```


## Starting

```sh
$ podman start devcontainer-deb-ssh
```

Debug that the container is up and that we can connect to it and accept the fingerprint:

```sh
$ ssh -p2222 vscode@127.0.0.1
```

Manage (root shell):

```sh
$ podman exec -it devcontainer-deb-ssh /bin/bash
```

## Connect VS Code.

![VS Code](readme/img/install1.png)

![VS Code](readme/img/install2.png)

![VS Code](readme/img/install3.png)

![VS Code](readme/img/install4.png)

![VS Code](readme/img/connect.png)

![VS Code](readme/img/done.png)


## Example to run openttd

OpenTTD can be started from inside the container.

```sh
$ podman exec -it --user 1000:1000 --workdir /home/vscode devcontainer-deb-ssh /bin/bash
vscode@container:~$ ./git/OpenTTD/build/openttd
```

Also install `libdecor-0-plugin-1-cairo` in debain if OpenTTD comes up without window bar and an error `Couldn't open plugin directory: ` ... `No plugins found, falling back on no decorations`.

TODO: compile statically and run on host in bubblewrap
