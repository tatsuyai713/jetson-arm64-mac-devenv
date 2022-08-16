#!/bin/sh
SCRIPT_DIR=$(cd $(dirname $0); pwd)


NAME_IMAGE='jetson_docker_image'

if [ ! $# -ne 1 ]; then
	if [ "setup" = $1 ]; then
		echo "Image ${NAME_IMAGE} does not exist."
		echo 'Now building image without proxy...'
		docker build --file=./noproxy.dockerfile -t $NAME_IMAGE .
	fi
fi
if [ ! $# -ne 1 ]; then
	if [ "commit" = $1 ]; then
		docker commit jetson_docker jetson_docker_image:latest
		CONTAINER_ID=$(docker ps -a -f name=jetson_docker --format "{{.ID}}")
		docker rm $CONTAINER_ID
		exit 0
	else
		echo "Docker image is found. Setup is already finished!"
	fi
fi

XAUTH=/tmp/.docker.xauth
touch $XAUTH
xauth_list=$(xauth nlist :0 | sed -e 's/^..../ffff/')
if [ ! -z "$xauth_list" ];  then
  echo $xauth_list | xauth -f $XAUTH nmerge -
fi
chmod a+r $XAUTH

DOCKER_OPT=""
DOCKER_NAME="jetson_docker"
DOCKER_WORK_DIR="/home/nvidia"
DISPLAY=$(hostname):0

## For XWindow
DOCKER_OPT="${DOCKER_OPT} \
        --env=QT_X11_NO_MITSHM=1 \
        --volume=/tmp/.X11-unix:/tmp/.X11-unix:rw \
        --env=XAUTHORITY=${XAUTH} \
        --volume=${XAUTH}:${XAUTH} \
        --env=DISPLAY=${DISPLAY} \
        -w ${DOCKER_WORK_DIR} \
        -u nvidia \
        --hostname Jetson-`hostname`"
		
		
## Allow X11 Connection
xhost +local:Jetson-`hostname`
CONTAINER_ID=$(docker ps -a -f name=jetson_docker --format "{{.ID}}")
if [ ! "$CONTAINER_ID" ]; then
	docker run ${DOCKER_OPT} \
		-itd \
		--shm-size=1gb \
		--env=TERM=xterm-256color \
		-p 22:20022 \
		--name=${DOCKER_NAME} \
		jetson_docker_image:latest
fi

CONTAINER_ID=$(docker ps -a -f name=jetson_docker --format "{{.ID}}")
if [ ! "$CONTAINER_ID" ]; then
	docker run ${DOCKER_OPT} \
		-it \
		--shm-size=1gb \
		--env=TERM=xterm-256color \
		--name=${DOCKER_NAME} \
		jetson_docker_image:latest \
		bash
else
	docker start $CONTAINER_ID
	docker attach $CONTAINER_ID
fi

xhost -local:Jetson-`hostname`

