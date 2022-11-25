#!/bin/sh -xe

CLICK_RUNNER=click_playground/click_pg
CLICK_ENDPOINT=click_playground/click_ep
IMAGE_TAG=$CLICK_BUILDER


build() {
	IMAGE_TYPE=$1

	case "$IMAGE_TYPE" in
	"click_playground/click_pg")
		docker build --tag "$CLICK_RUNNER" \
			--file clickPlayground.Dockerfile .
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

build click_playground/click_pg
build click_playground/click_ep
