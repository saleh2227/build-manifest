#!/bin/bash

#  Copyright (C) 2022 Intel Corporation
#  SPDX-License-Identifier: BSD-3-Clause

# Entrypoint script for iseclbuilder container that helps build components
# inside a containerized development env.
# Build targets are output to the /out/ path by default - make sure host path
# is bind-mounted to this path

helpFunction() {
    echo ""
    echo "Usage: $0 [-u usecase] [-t target]"
    echo -e "\t-u Usecase: fs|crio|all\n"
    echo -e "\t            fs: Foundational Security\n"
    echo -e "\t            crio: Container Confidentiality w/ CRIO\n"
    echo -e "\t            ds: Data Sovereignty\n"
    echo -e "\t            all: All usecases - default\n"
    echo -e "\t-t target: bin|img|all\n"
    echo -e "\t           bin: Installer binaries\n"
    echo -e "\t           img: OCI Container Images\n"
    echo -e "\t           aio: AIO microk8s deployment\n"
    echo -e "\t           all: All targets - default\n"
}

installPrereqs() {
    if [ ! -f /.prereqdone ]; then
        cd utils/build/
        echo "Installing pre-reqs for FS, WS"
        # cleanup unused repo and pre-reqs
        # remove docker from the pre-req scripts
        bash ./all-components.sh
        apt-get remove docker docker-engine docker.io containerd runc skopeo -y && \
        # Configure podman to run inside container - we could use multi-stage here but it will inevitably add more layers
        # sourced from podman:stable Dockerfile - https://github.com/containers/podman/blob/main/contrib/podmanimage/stable/Dockerfile \
        apt-get -y install podman && \
        mkdir -p /var/lib/containers/ && mkdir -p /root/.local/share/containers/ && mkdir -p /root/.config/containers/ && \
        wget https://raw.githubusercontent.com/containers/libpod/master/contrib/podmanimage/stable/containers.conf -O /etc/containers/containers.conf && \
        wget https://raw.githubusercontent.com/containers/libpod/master/contrib/podmanimage/stable/podman-containers.conf -O /root/.config/containers/containers.conf && \
        chmod 644 /etc/containers/containers.conf && \
        sed -i -e 's|^#mount_program|mount_program|g' -e '/additionalimage.*/a "/var/lib/shared",' -e 's|^mountopt[[:space:]]*=.*$|mountopt = "nodev,fsync=0"|g' /etc/containers/storage.conf && \
        mkdir -p /var/lib/shared/overlay-images/ /var/lib/shared/overlay-layers/ /var/lib/shared/vfs-images/ /var/lib/shared/vfs-layers/ && \
        touch /var/lib/shared/overlay-layers/layers.lock /var/lib/shared/vfs-images/images.lock /var/lib/shared/vfs-layers/layers.lock /var/lib/shared/overlay-images/images.lock && \
        ln -sf /usr/bin/podman /usr/bin/docker && \
        if [ ! -z "$REGISTRY_MIRROR_URL" ]; then
        cat > /etc/containers/registries.conf <<EOF
unqualified-search-registries = ["docker.io","registry.fedoraproject.org"]
[[registry]]
prefix = "docker.io"
insecure = false
location = "${REGISTRY_MIRROR_URL}"
[[registry.mirror]]
location = "${REGISTRY_MIRROR_URL}"
insecure = true
EOF
        fi
        if [ $? -eq 0 ]; then touch /.prereqdone; else echo "Pre-reqs install failed"; exit 1; fi
        cd -
        else
            echo "Skipping pre-reqs install"
        fi
}

buildTargets() {
    puc=$1
    put=$2
    # build binaries
    if [ "$put" == "all" -o "$put" == "bin" ]; then
        rm -rf /out/${puc}/binaries/
        make
        mv binaries /out/${puc}/
    fi
    # build k8s multi-node targets
    if [ "$put" == "all" -o "$put" == "img" ]; then
        rm -rf /out/${puc}/k8s/
        make k8s
        mv k8s /out/${puc}/
    fi
    # build k8s AIO targets
    if [ "$put" == "all" -o "$put" == "aio" ]; then
        rm -rf /out/${puc}/k8s_aio/
        make k8s-aio
        mv k8s /out/${puc}/k8s_aio/
    fi
}

main() {
    rm -rf /work/.repo
    DB_VERSION_UPGRADE_11_14=v11-v14
    if [ "$paramUsecase" != "all" -a "$paramUsecase" != "fs" -a "$paramUsecase" != "crio" -a "$paramUsecase" != "ds" ]; then
        echo -e "Invalid usecase: $paramUsecase\n"
        helpFunction
        exit 1
    fi

    if [ "$paramTarget" != "all" -a "$paramTarget" != "bin" -a "$paramTarget" != "img" -a "$paramTarget" != "aio" ]; then
        echo -e "Invalid target: $paramTarget\n"
        helpFunction
        exit 1
    fi

    if [ "$paramUsecase" == "all" -o "$paramUsecase" == "fs" ]; then
        mkdir -p /out/fs/
        mkdir -p /work/fs/ && cd /work/fs/
        repo init -u /build-manifest/  -b "$ISECLRELEASEBRANCH"  -m manifest/fs.xml && repo sync --force-sync
        find . -name Makefile -exec sed -i 's/env CGO_CFLAGS_ALLOW/go mod tidy \&\& env CGO_CFLAGS_ALLOW/g' {} \;
        find . -name Makefile -exec sed -i 's/env GOOS/go mod tidy \&\& env GOOS/g' {} \;
        installPrereqs
        # fixes for k8s build
        sed -i 's/skopeo copy docker-daemon.*/podman save --format oci-archive --output deployments\/container-archive\/oci\/\$\*-\$\(VERSION\)-\$\(GITCOMMIT\)\.tar localhost\/isecl\/\$\*:\$\(VERSION\)-\$\(GITCOMMIT\)/' intel-secl/Makefile
        sed -i 's/skopeo copy docker-daemon:isecl\/init-wait.*/podman save --format oci-archive --output init-wait\/init-wait-\$\(VERSION\)\.tar localhost\/isecl\/init-wait:\$\(VERSION\)/' utils/tools/containers/Makefile
        sed -i 's/skopeo copy docker-daemon:isecl\/nats-init.*/podman save --format oci-archive --output nats\/nats-init-\$\(VERSION\)\.tar localhost\/isecl\/nats-init:\$\(VERSION\)/' utils/tools/containers/Makefile
        sed -i 's/skopeo copy docker-daemon:isecl\/db-version-upgrade.*/podman save --format oci-archive --output db-version-upgrade\/db-version-upgrade-\$\(DB_VERSION_UPGRADE_11_14\)\.tar localhost\/isecl\/db-version-upgrade:\$\(DB_VERSION_UPGRADE_11_14\)/' utils/tools/containers/Makefile
        buildTargets fs $paramTarget
    fi

    # build workload confidentiality targets
    # crio
    if [ "$paramUsecase" == "all" -o "$paramUsecase" == "crio" ]; then
        mkdir -p /out/cc-crio/
        mkdir -p /work/cc-crio/ && cd /work/cc-crio/
        repo init -u /build-manifest/  -b "$ISECLRELEASEBRANCH" -m manifest/cc-crio.xml && repo sync --force-sync
        find . -name Makefile -exec sed -i 's/env CGO_CFLAGS_ALLOW/go mod tidy \&\& env CGO_CFLAGS_ALLOW/g' {} \;
        find . -name Makefile -exec sed -i 's/env GOOS/go mod tidy \&\& env GOOS/g' {} \;
        installPrereqs
        # fixes for k8s build
        sed -i 's/skopeo copy docker-daemon.*/podman save --format oci-archive --output deployments\/container-archive\/oci\/\$\*-\$\(VERSION\)-\$\(GITCOMMIT\)\.tar localhost\/isecl\/\$\*:\$\(VERSION\)-\$\(GITCOMMIT\)/' intel-secl/Makefile
        sed -i 's/skopeo copy docker-daemon:isecl\/init-wait.*/podman save --format oci-archive --output init-wait\/init-wait-\$\(VERSION\)\.tar localhost\/isecl\/init-wait:\$\(VERSION\)/' utils/tools/containers/Makefile
        sed -i 's/skopeo copy docker-daemon:isecl\/nats-init.*/podman save --format oci-archive --output nats\/nats-init-\$\(VERSION\)\.tar localhost\/isecl\/nats-init:\$\(VERSION\)/' utils/tools/containers/Makefile
        sed -i 's/skopeo copy docker-daemon:isecl\/db-version-upgrade.*/podman save --format oci-archive --output db-version-upgrade\/db-version-upgrade-\$\(DB_VERSION_UPGRADE_11_14\)\.tar localhost\/isecl\/db-version-upgrade:\$\(DB_VERSION_UPGRADE_11_14\)/' utils/tools/containers/Makefile
        # build WS targets
        buildTargets cc-crio $paramTarget
    fi

    # build data sovereignty targets
    # ds
    if [ "$paramUsecase" == "all" -o "$paramUsecase" == "ds" ]; then
        mkdir -p /out/data-sovereignty/
        mkdir -p /work/data-sovereignty/ && cd /work/data-sovereignty/
        repo init -u /build-manifest/  -b "$ISECLRELEASEBRANCH" -m manifest/data-sovereignty.xml && repo sync --force-sync
        find . -name Makefile -exec sed -i 's/env CGO_CFLAGS_ALLOW/go mod tidy \&\& env CGO_CFLAGS_ALLOW/g' {} \;
        find . -name Makefile -exec sed -i 's/env GOOS/go mod tidy \&\& env GOOS/g' {} \;
        installPrereqs
	# fixes for k8s build
	sed -i 's/skopeo copy docker-daemon.*/podman save --format oci-archive --output deployments\/container-archive\/oci\/\$\*-\$\(VERSION\)-\$\(GITCOMMIT\)\.tar localhost\/isecl\/\$\*:\$\(VERSION\)-\$\(GITCOMMIT\)/' intel-secl/Makefile
	sed -i 's/skopeo copy docker-daemon:isecl\/init-wait.*/podman save --format oci-archive --output init-wait\/init-wait-\$\(VERSION\)\.tar localhost\/isecl\/init-wait:\$\(VERSION\)/' utils/tools/containers/Makefile
        sed -i 's/skopeo copy docker-daemon:isecl\/nats-init.*/podman save --format oci-archive --output nats\/nats-init-\$\(VERSION\)\.tar localhost\/isecl\/nats-init:\$\(VERSION\)/' utils/tools/containers/Makefile
        sed -i 's/skopeo copy docker-daemon:isecl\/db-version-upgrade.*/podman save --format oci-archive --output db-version-upgrade\/db-version-upgrade-\$\(DB_VERSION_UPGRADE_11_14\)\.tar localhost\/isecl\/db-version-upgrade:\$\(DB_VERSION_UPGRADE_11_14\)/' utils/tools/containers/Makefile
        # build WS targets
        buildTargets data-sovereignty $paramTarget
    fi

    # change output file ownership to the external-user to avoid permission issues
    if [[ ! -z "$EXT_USER" ]]; then
        chown -R $EXT_USER:$EXT_USER /out/
    fi
}

while getopts "u:t:h" opt; do
    case "$opt" in
    u) paramUsecase="$OPTARG" ;;
    t) paramTarget="$OPTARG" ;;
    h)
        helpFunction
        exit 0
        ;;
    esac
done

if [ -z "$paramUsecase" -o -z  "$paramTarget" ]; then
    if [ "$1" == "prereq" ]; then
       installPrereqs
       exit $?
    fi

    helpFunction
    exit 0
fi

# Trigger main
main

