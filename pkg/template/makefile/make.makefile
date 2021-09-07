.DEFAULT_GOAL := v

########### CUSTOM VARS ##################
SERVICE_NAME := {{ .ServiceName }}

DEV_GCP := {{ .GcpProjectIdDev }}
DEV_ESP_API := {{ .GcpEspUrlDev }}
REGION := {{ .GcpRegion }}
##########################################
CURRENT_DIR := $(shell pwd)

.PHONY: proto-install proto-generate deploy-espV2-dev deploy-cloudendpoint-dev build-cloudendpoint-dev build-deploy-cloudendpoints-dev services-enabled

proto-install:
	go get -u github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger
	go get google.golang.org/protobuf/cmd/protoc-gen-go
	#GRPC Modules
	go get google.golang.org/grpc/cmd/protoc-gen-go-grpc


proto-generate:
	protoc --proto_path="${CURRENT_DIR}" --include_source_info  --include_imports  --descriptor_set_out=proto/${SERVICE_NAME}/${SERVICE_NAME}_annotated.pb --go_out=pkg/. --go-grpc_out=pkg/. proto/${SERVICE_NAME}/${SERVICE_NAME}_annotated.proto


build-cloudendpoint-dev:
	./esp/gcloud_build_image.sh -s ${DEV_ESP_API} -c $(shell head -n 1 dev_tag_version) -p ${DEV_GCP} > ./esp/image_info
	grep -o -e  "gcr.*\d.*  " ./esp/image_info > ./esp/image_name
	sleep 1

deploy-cloudendpoint-dev:
	gcloud run deploy cloudendpoint-${SERVICE_NAME} \
	--image=$(shell head -n 1 ./esp/image_name) \
	--project=${DEV_GCP} \
	--allow-unauthenticated \
	--platform managed \
	--region=${REGION}

deploy-espV2-dev:
	gcloud endpoints services deploy --project=${DEV_GCP}  ./proto/${SERVICE_NAME}/${SERVICE_NAME}_annotated.pb  ./cloudendpoints/dev_api_config.yaml
	gcloud endpoints configs list --project=${DEV_GCP}  --service=${DEV_ESP_API} --format="value(CONFIG_ID)" > ./esp/dev_config_ids ; head -n 1 ./esp/dev_config_ids > dev_tag_version
	gcloud services enable --project=${DEV_GCP} ${DEV_ESP_API}

# Must enable these services on Project Level to ensure API Keys can be Validated
services-enabled:
	gcloud services enable servicemanagement.googleapis.com --project=${DEV_GCP}
	gcloud services enable servicecontrol.googleapis.com --project=${DEV_GCP}
	gcloud services enable endpoints.googleapis.com --project=${DEV_GCP}

.PHONY: build-deploy-server-dev build-server-dev deploy-server-dev
build-server-dev:
	pack build gcr.io/${DEV_GCP}/${SERVICE_NAME}-server:latest --builder gcr.io/buildpacks/builder:v1 --env GOOGLE_BUILDABLE="./cmd/server" --publish

deploy-server-dev:
	gcloud run deploy ${SERVICE_NAME}-server \
	--image="gcr.io/${DEV_GCP}/${SERVICE_NAME}-server:latest" \
	--platform managed \
	--project=${DEV_GCP} \
	--region=${REGION}

build-deploy-server-dev: build-server-dev deploy-server-dev
build-deploy-cloudendpoints-dev: proto-install proto-generate deploy-espV2-dev build-cloudendpoint-dev deploy-cloudendpoint-dev