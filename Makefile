.DEFAULT_GOAL := v
CURRENT_DIR := $(shell pwd)

########### GCP Project Configuration ###########
GCP_PROJECT_ID := gcp-project-id
GCP_ESP_API := "https://gcp-esp-api-url"
GCP_REPO := gcr.io
########### Configuration ###########
SERVICE_NAME := event
CLOUD_ENDPOINTS_NAME := cloudendpoints-api
########### Base Config ##########
API_BASE := api/event
PROTO_BASE := proto/event
GO_PKG_BASE := pkg
SERVICE_IMAGE_TAG := latest

SERVICE_NAME_SUFFIX := grpc

API_SPEC     := ${API_BASE}/${SERVICE_NAME}.yaml

SERVICE_IMAGE_NAME := ${SERVICE_NAME}-${SERVICE_NAME_SUFFIX}
SERVICE_REPO_IMAGE := ${GCP_REPO}/${PROJECT_ID}/${SERVICE_IMAGE_NAME}:${SERVICE_IMAGE_TAG}
######## Static Config #########
PROTO_OUT := ${PROTO_BASE}/${SERVICE_NAME}.proto

ANNOTATED_DESCRIPTION := annotated
PROTO_ANNOTATED_OUT := ${PROTO_BASE}/${SERVICE_NAME}-${ANNOTATED_DESCRIPTION}.proto
PROTO_ANNOTATED_OUT_PB := ${PROTO_BASE}/${SERVICE_NAME}-${ANNOTATED_DESCRIPTION}.pb

TAG_VERSION :=$(shell head -n 1 tag_version)


#ESPv2_ARGS := ^++^--cors_preset=basic++--cors_allow_credentials++-cors_allow_headers=DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization,x-user-agent

.PHONY: dir-setup proto-install  swagger-client swagger-mixin openapi2proto proto-generate run-generate openapi2proto-install get-yaml swagger-make-models swagger-models mod-yaml-for-proto get-swaggerhub-yaml run-deploy-cloudendpoint-dev git-tag run-deploy-tag run

dir-setup:
	mkdir -p  ${PROTO_BASE} ${GO_PKG_BASE}

proto-install:
	go get -u github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger
	go get google.golang.org/protobuf/cmd/protoc-gen-go
	#GRPC Modules
	go get google.golang.org/grpc/cmd/protoc-gen-go-grpc
	go get -u github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway

openapi2proto-install:
	go get -u github.com/NYTimes/openapi2proto/cmd/openapi2proto


openapi2proto:
	openapi2proto -annotate -spec ${API_SPEC} -out ${PROTO_ANNOTATED_OUT}
	openapi2proto  -spec  ${API_SPEC} -out ${PROTO_OUT}

proto-generate:
	protoc --proto_path="${CURRENT_DIR}" --include_source_info  --include_imports  --descriptor_set_out=${PROTO_ANNOTATED_OUT_PB} --go_out=${GO_PKG_BASE}/. --go-grpc_out=${GO_PKG_BASE}/. ${PROTO_ANNOTATED_OUT}

run-generate: dir-setup proto-install openapi2proto proto-generate

run: run-generate


.PHONY: deploy

deploy:
	gcloud builds submit --tag ${SERVICE_REPO_IMAGE}
	gcloud run deploy ${SERVICE_IMAGE_NAME} --image="${SERVICE_REPO_IMAGE}"    --platform managed   --project ${PROJECT_ID} --update-env-vars "PROJECT_ID=${PROJECT_ID}"


run-deploy-cloudendpoint-dev: build-cloudendpoint deploy-cloudendpoint


build-cloudendpoint:
	./esp/gcloud_build_image.sh -s ${GCP_ESP_API} -c $(shell head -n 1 tag_version) -p ${GCP_PROJECT_ID} > ./esp/image_info
	grep -o -e  "gcr.*\d.*  " ./esp/image_info > ./esp/image_name
	sleep 1

deploy-cloudendpoint:
	gcloud run deploy ${CLOUD_ENDPOINTS_NAME} --image=$(shell head -n 1 ./esp/image_name) --project=${GCP_PROJECT_ID} --allow-unauthenticated --platform managed


git-tag:
	echo TAG VERSION v0.0.0-$(shell head -n 1 ./esp/config_ids)
	git add --all
	git commit -am "AutoCommit $(shell head -n 1 ./esp/config_ids)"
	git tag v0.0.0-$(shell head -n 1 ./esp/config_ids)
	git push origin refs/tags/v0.0.0-$(shell head -n 1 ./esp/config_ids)
	git push cloud refs/tags/v0.0.0-$(shell head -n 1 ./esp/config_ids)


go-build:
	go test ./...
	go build ./...