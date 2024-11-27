PKG_VERSION=0.17.0
PKG_REL_PREFIX=1hn1
ifdef NO_CACHE
DOCKER_NO_CACHE=--no-cache
endif

GO_VERSION=1.23.3

LOGUNLIMITED_BUILDER=logunlimited

# Ubuntu 24.04
deb-ubuntu2404: build-ubuntu2404
	docker run --rm -v ./carbonapi-${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu24.04:/dist ats-ubuntu2404 bash -c \
	"cp /src/carbonapi*${PKG_VERSION}* /dist/"
	sudo tar zcf carbonapi-${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu24.04.tar.gz ./carbonapi-${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu24.04/

build-ubuntu2404: buildkit-logunlimited
	sudo mkdir -p carbonapi-${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu24.04
	(set -x; \
	git submodule foreach --recursive git remote -v; \
	git submodule status --recursive; \
	docker buildx build --progress plain --builder ${LOGUNLIMITED_BUILDER} --load \
		${DOCKER_NO_CACHE} \
		--build-arg OS_TYPE=ubuntu --build-arg OS_VERSION=24.04 \
		--build-arg PKG_VERSION=${PKG_VERSION} \
		--build-arg PKG_RELEASE=${PKG_REL_PREFIX}ubuntu24.04 \
		--build-arg GO_VERSION=${GO_VERSION} \
		-t ats-ubuntu2404 . \
	) 2>&1 | sudo tee carbonapi-${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu24.04/carbonapi_${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu24.04.build.log
	sudo xz --force carbonapi-${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu24.04/carbonapi_${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu24.04.build.log

run-ubuntu2404:
	docker run --rm -it ats-ubuntu2404 bash

# Ubuntu 22.04
deb-ubuntu2204: build-ubuntu2204
	docker run --rm -v ./carbonapi-${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu22.04:/dist ats-ubuntu2204 bash -c \
	"cp /src/carbonapi*${PKG_VERSION}* /dist/"
	sudo tar zcf carbonapi-${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu22.04.tar.gz ./carbonapi-${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu22.04/

build-ubuntu2204: buildkit-logunlimited
	sudo mkdir -p carbonapi-${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu22.04
	(set -x; \
	git submodule foreach --recursive git remote -v; \
	git submodule status --recursive; \
	docker buildx build --progress plain --builder ${LOGUNLIMITED_BUILDER} --load \
		${DOCKER_NO_CACHE} \
		--build-arg OS_TYPE=ubuntu --build-arg OS_VERSION=22.04 \
		--build-arg PKG_VERSION=${PKG_VERSION} \
		--build-arg PKG_RELEASE=${PKG_REL_PREFIX}ubuntu22.04 \
		--build-arg GO_VERSION=${GO_VERSION} \
		-t ats-ubuntu2204 . \
	) 2>&1 | sudo tee carbonapi-${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu22.04/carbonapi_${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu22.04.build.log
	sudo xz --force carbonapi-${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu22.04/carbonapi_${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu22.04.build.log

run-ubuntu2204:
	docker run --rm -it ats-ubuntu2204 bash

buildkit-logunlimited:
	if ! docker buildx inspect logunlimited 2>/dev/null; then \
		docker buildx create --bootstrap --name ${LOGUNLIMITED_BUILDER} \
			--driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=-1 \
			--driver-opt env.BUILDKIT_STEP_LOG_MAX_SPEED=-1; \
	fi

exec:
	docker exec -it $$(docker ps -q) bash

.PHONY: deb-ubuntu2204 run-ubuntu2204 build-ubuntu2204 buildkit-logunlimited exec
