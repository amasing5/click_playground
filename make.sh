#!/bin/sh -xe

CLICK_RUNNER=click_playground/click_router
CLICK_ENDPOINT=click_playground/click_ep
IMAGE_TAG=$CLICK_BUILDER


build() {
	IMAGE_TYPE=$1

	case "$IMAGE_TYPE" in
	"click_playground/click_router")
		docker build --tag "$CLICK_RUNNER" \
			--file clickRouter.Dockerfile .
		;;
	"click_playground/click_ep")
		docker build  --tag "$CLICK_ENDPOINT" \
		--file clickEndpoint.Dockerfile .
		;;
	 *)
	         fatal "Unknown image type: $IMAGE_TYPE"
	        ;;
     esac
}

build click_playground/click_router
build click_playground/click_ep
