# Miscellaneous packages built with Docker/Podman in Debian

The viewer discretion is advised:
builds packages in containers and installs into locally mounted directories, preferably with Podman (rootless)

```
# Example: build and run ardour package from squashfs image
#
cd ardour
podman run --rm --name builder --mount type=bind,source=$(pwd),target=/build -it debian:bullseye /build/build.sh
sudo mount ardour.sqfs /opt/ardour/ -t squashfs
/opt/ardour/bin/ardour6
```
