# Builder Dockerfile for Intel® Security Libraries for Data Center (ISecL-DC)

Build all ISecL-DC components for end-users in a containerized build environment. All pre-requisites are handled in the container and all targets supported by current release can be obtained.

**Pre-requisite on build host is docker daemon. Validated on Docker 19.03.x and above on RHEL 8.3 host.**

Build-args for development container:

Param Name          | Description                                              | Required | Default Value
------------------- | -------------------------------------------------------- | -------- | ----------------
ISECLRELEASEBRANCH  | Tag or branch name from which manifest files are sourced | No       | refs/tags/v4.1.1
GO_VERSION          | Version of GoLang SDK used for builds                    | No       | 1.16.7
EXT_USER            | Runtime user which should own the built artifacts        | No       | root
REGISTRY_MIRROR_URL | URL for registry mirror for fetching container images    | No       | root

Build the development container supplying proxy information if needed:

```shell
docker build \
 --build-arg http_proxy=<proxy-url> \
 --build-arg https_proxy=<proxy-url> \
 -t iseclbuilder . \
```

Use the development container to obtain the binaries, OCI images of ISecL components as needed.

```shell
docker run  --privileged  \         
--security-opt seccomp=unconfined \
--security-opt apparmor=unconfined \
-e http_proxy=$http_proxy \
-e https_proxy=$https_proxy \
-e no_proxy=$no_proxy \
-v `pwd`:/root/out/\
 iseclbuilder \
 [-u <usecase>] [-t <target>]
```

_Note: The dev container requires privileged access since **podman** tool, requires these permissions to build container images inside container.

Refer to the usage documentation on the iseclbuilder for more information on usecases and targets:

```shell
docker run iseclbuilder -h
```
