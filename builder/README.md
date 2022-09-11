# Builder Dockerfile for Intel® Security Libraries for Data Center (ISecL-DC)

Build all ISecL-DC components for end-users in a containerized build environment. All pre-requisites are handled in the container and all targets supported by current release can be obtained.

**Pre-requisite on build host is docker daemon, podman(only for ubuntu 22.04 and above). Validated on Docker 19.03.x and above on RHEL 8.3 host.**

Build-args for development container:

Param Name          | Description                                              | Required | Default Value
------------------- | -------------------------------------------------------- | -------- | ----------------
ISECLRELEASEBRANCH  | Tag or branch name from which manifest files are sourced | No       | refs/tags/v5.0.0
GO_VERSION          | Version of GoLang SDK used for builds                    | No       | 1.18.2
EXT_USER            | Runtime user which should own the built artifacts        | No       | root
REGISTRY_MIRROR_URL | URL for registry mirror for fetching container images    | No       | root
MANIFEST            | manifest filename e.g manifest/tee.xml                   | Yes      | 

Copy .netrc to build-manifest directory

Build the development container supplying proxy information if needed:

```shell
cd applications.security.isecl.tools.build-manifest
docker build \
 --build-arg http_proxy=<proxy-url> \
 --build-arg https_proxy=<proxy-url> \
 --build-arg ISECLRELEASEBRANCH=<branch/tag> \
 --build-arg MANIFEST=manifest/tee.xml
 --build-arg GO_VERSION=1.18.2
 -t iseclbuilder . \ 
 -f builder/Dockerfile
```

Use the development container to obtain the binaries, OCI images of ISecL components as needed.

```shell
mkdir out
docker run  --privileged  -v /sys/fs/cgroup:/sys/fs/cgroup \         
--security-opt seccomp=unconfined \
--security-opt apparmor=unconfined \
-e http_proxy=$http_proxy \
-e https_proxy=$https_proxy \
-e no_proxy=$no_proxy \
-v `pwd`/out:/out/ \
 iseclbuilder \
 [-u <usecase>] [-t <target>]
```

### For Ubuntu 22.04 system please use podman command as below
```shell
cd applications.security.isecl.tools.build-manifest
podman build \
 --build-arg http_proxy=<proxy-url> \
 --build-arg https_proxy=<proxy-url> \
 --build-arg ISECLRELEASEBRANCH=<branch/tag> \
 --build-arg MANIFEST=manifest/tee.xml
 --build-arg GO_VERSION=1.18.2
 -t iseclbuilder . \ 
 -f builder/Dockerfile
```

 Use the development container to obtain the binaries, OCI images of ISecL components as needed.

```shell
mkdir out
podman run  --privileged  -v /sys/fs/cgroup:/sys/fs/cgroup \         
--security-opt seccomp=unconfined \
--security-opt apparmor=unconfined \
-e http_proxy=$http_proxy \
-e https_proxy=$https_proxy \
-e no_proxy=$no_proxy \
-v `pwd`/out:/out/ \
 iseclbuilder \
 [-u <usecase>] [-t <target>]
```


The container images would be available in applications.security.isecl.tools.build-manifest/out/<usecase>/k8s/images/
_Note: The dev container requires privileged access since **podman** tool, requires these permissions to build container images inside container.

Refer to the usage documentation on the iseclbuilder for more information on usecases and targets:

```shell
docker run iseclbuilder -h
```

 
 
