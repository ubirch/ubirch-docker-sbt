#!/bin/bash -x


CONTAINER_NAME="sbt-build"

if [ "v${GO_PIPELINE_LABEL}" = "v" ];then
	GO_PIPELINE_LABEL=latest
fi



function fix_dockerfile_version() {
  if [ "v${GO_DEPENDENCY_LABEL_JAVA_BASE_CONTAINER}" = "v" ]; then
    CONTAINER_LABEL=latest
  else
    CONTAINER_LABEL="v${GO_DEPENDENCY_LABEL_JAVA_BASE_CONTAINER}"
  fi
  sed "s#FROM ubirch/java#FROM ubirch/java:${CONTAINER_LABEL}#g" Dockerfile > Dockerfile.v${GO_PIPELINE_LABEL}
  diff Dockerfile Dockerfile.v${GO_PIPELINE_LABEL}
}

# build the docker container
function build_container() {

    # fix_dockerfile_version

	if [ "v${GO_PIPELINE_LABEL}" = "v" ]; then
		PUBLISH_VERSION="latest"
	else
		PUBLISH_VERSION="vOpenJDK_${GO_PIPELINE_LABEL}"
	fi

    echo "Building SBT container"

    mkdir -p VAR && docker build -t ubirch/${CONTAINER_NAME}:${PUBLISH_VERSION} -f Dockerfile .


    if [ $? -ne 0 ]; then
        echo "Docker build failed"
        exit 1
	fi

}

# publish the new docker container
function publish_container() {


	if [ "v${GO_PIPELINE_LABEL}" = "v" ]; then
		PUBLISH_VERSION="latest"
	else
		PUBLISH_VERSION="v${GO_PIPELINE_LABEL}"
	fi


  echo "Publishing Docker Container with version: ${PUBLISH_VERSION}"
  docker push ubirch/${CONTAINER_NAME}:${PUBLISH_VERSION}
    if [ $? -ne 0 ]; then
        echo "Could not push ubirch/${CONTAINER_NAME}:${PUBLISH_VERSION} to Docker hub"
        exit 1
    fi
  docker tag ubirch/${CONTAINER_NAME}:${PUBLISH_VERSION} ubirch/${CONTAINER_NAME}:latest
  docker push ubirch/${CONTAINER_NAME}:latest

  if [ $? -eq 0 ]; then
    echo ${PUBLISH_VERSION} > VAR/GO_PIPELINE_NAME_${GO_PIPELINE_NAME}
  else
    echo "Docker push faild"
    exit 1
  fi

}


case "$1" in
    build)
        build_container
        ;;
    publish)
        publish_container
        ;;
    *)
        echo "Usage: $0 {build|publish}"
        exit 1
esac

exit 0
