#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname $0)" && pwd)
DOCKER=$(which docker)
ID=$(which id)
IMAGE=unifi-controller:latest

# imagename:tag to containerId
# @imagename:tag
getContainerId() {
    imageName=$1
    echo $($DOCKER ps -aq -f "ancestor=$imageName")
}

# check if container is running
# @containerId
isContainerRunning() {
    containerId=$1
    if [ "$containerId" == "" ]; then
        echo "no"
        return
    fi

    if [ "$($DOCKER ps -q -f "id=$containerId,status=running")" == "$containerId" ]; then
        echo "yes"
    else
        echo "no"
    fi
}

# check if image is available
# @imageNameTag
isImageAvailable() {
    imageNameTag=$1

    if [ "$($DOCKER images -q $imageNameTag)" == "" ]; then
        echo "no"
    else
        echo "yes"
    fi
}

buildImage() {
    imageNameTag=$1

    if [ "$(isImageAvailable $imageNameTag)" == "no" ]; then
        echo "No image '$imageNameTag' found. Trying to build..."
        pushd $SCRIPT_DIR/docker
        $DOCKER build --tag $imageNameTag .
        popd
    fi
}

startContainer() {
    imageNameTag=$1
    containerId=$(getContainerId $imageNameTag)

    if [ "$containerId" == "" ]; then
        buildImage $imageNameTag
        if  [ "$(isImageAvailable $imageNameTag)" == "yes" ]; then
            echo "Starting container..."
            $DOCKER run \
		--hostname unifi.home \
                --volume $SCRIPT_DIR/unifidata:/var/lib/unifi \
                $imageNameTag
        else
            echo "Cant start container. Image '$imageNameTag' is not available"
        fi
    else
        echo "Container found"
        if [ "$(isContainerRunning $containerId)" == "no" ]; then
            echo "Not running. Starting..."
            $DOCKER start --attach $containerId
        else
            echo "Already running"
        fi
    fi
}

stopContainer() {
    imageNameTag=$1
    containerId=$(getContainerId $imageNameTag)

    if [ "$(isContainerRunning $containerId)" == "yes" ]; then
        $DOCKER stop $containerId
    fi
}

flush() {
    imageNameTag=$1
    containerId=$(getContainerId $imageNameTag)

    if [ "$containerId" != "" ]; then
        $DOCKER rm -v $containerId
    fi
    if [ "$(isImageAvailable $imageNameTag)" == "yes" ]; then
        $DOCKER rmi $imageNameTag
    fi
}

case "$1" in
    start)
        startContainer $IMAGE
        ;;
    stop)
        stopContainer $IMAGE
        ;;
    flush)
        stopContainer $IMAGE
        flush $IMAGE
        ;;
    *)
        echo "Usage $(basename $0) {start|stop|flush}" >&2
        ;;
esac

