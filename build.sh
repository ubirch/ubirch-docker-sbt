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

    fix_dockerfile_version

    echo "Building SBT container"

    mkdir -p VAR && docker build -t ubirch/${CONTAINER_NAME}:${CONTAINER_LABEL} -f Dockerfile.v${GO_PIPELINE_LABEL} .


    if [ $? -ne 0 ]; then
        echo "Docker build failed"
        exit 1
	fi

}

# publish the new docker container
function publish_container() {
		
		fix_dockerfile_version
	
  echo "Publishing Docker Container with version: ${CONTAINER_LABEL}"
  docker push ubirch/${CONTAINER_NAME}:${CONTAINER_LABEL} && docker push ubirch/${CONTAINER_NAME}

  if [ $? -eq 0 ]; then
    echo ${NEW_LABEL} > VAR/GO_PIPELINE_NAME_${GO_PIPELINE_NAME}
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