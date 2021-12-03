#  Copyright (C) 2021 Intel Corporation
#  SPDX-License-Identifier: BSD-3-Clause

PROXY_EXISTS := $(shell if [[ "${https_proxy}" || "${http_proxy}" || "${no_proxy}" ]]; then echo 1; else echo 0; fi)
DOCKERBUILD_PROXY_FLAGS := ""
DOCKERRUN_PROXY_FLAGS := ""
VERSION := "v4.1.0"
IMGTAG := "iseclbuilder:${VERSION}"
DOCKERRUN_PRIV_FLAGS := --privileged  --security-opt seccomp=unconfined --security-opt apparmor=unconfined
DOCKERRUN_MOUNT_FLAGS := -v `pwd`/out/:/out/
ifeq ($(PROXY_EXISTS),1)
	DOCKERBUILD_PROXY_FLAGS = --build-arg http_proxy=${http_proxy} --build-arg https_proxy=${https_proxy} --build-arg no_proxy=${no_proxy},gitlab.devtools.intel.com
	DOCKERRUN_PROXY_FLAGS = -e http_proxy=${http_proxy} -e https_proxy=${https_proxy} -e no_proxy=${no_proxy}
else
	undefine DOCKERBUILD_PROXY_FLAGS
	undefine DOCKERRUN_PROXY_FLAGS
endif

iseclbuilder:
	docker build ${DOCKERBUILD_PROXY_FLAGS} -t ${IMGTAG} . -f builder/Dockerfile

shell: iseclbuilder
	mkdir -p out
	docker run -it ${DOCKERRUN_MOUNT_FLAGS} ${DOCKERRUN_PRIV_FLAGS} ${DOCKERRUN_PROXY_FLAGS} --entrypoint=bash ${IMGTAG} 

%-bin: iseclbuilder
	mkdir -p out
	docker run ${DOCKERRUN_MOUNT_FLAGS} ${DOCKERRUN_PRIV_FLAGS} ${DOCKERRUN_PROXY_FLAGS} ${IMGTAG} -u $* -t bin

%-img: iseclbuilder
	mkdir -p out
	docker run ${DOCKERRUN_MOUNT_FLAGS} ${DOCKERRUN_PRIV_FLAGS} ${DOCKERRUN_PROXY_FLAGS} ${IMGTAG} -u $* -t img

%-aio: iseclbuilder
	mkdir -p out
	docker run ${DOCKERRUN_MOUNT_FLAGS} ${DOCKERRUN_PRIV_FLAGS} ${DOCKERRUN_PROXY_FLAGS} ${IMGTAG} -u $* -t aio

clean:
	rm -rf out

all: 	clean iseclbuilder
	docker run ${DOCKERRUN_MOUNT_FLAGS} ${DOCKERRUN_PRIV_FLAGS} ${DOCKERRUN_PROXY_FLAGS} ${IMGTAG} -u all -t all

help:
	builder/build.sh -h

