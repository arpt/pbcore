# Proton Build Core 

## Description

Core Libraries to Setup GitHub Repository and Project Layout Directives to Build GCP Cloud Endpoints directly from Protobufs and Deploy Secure API's

This Library will automate the creation of the necessary tooling to enable this by providing an CLI tool to generate the packaging layout and github actions workflows to automate the entire process

## Overview

GCP Cloud Endpoints ESPv2 utilizes Envoy to route requests to the backend services.    




## Project layout

| dir | description | 
|-----|-------|
| gen | base dir | 
| gen/proto/ | proto definitions |
| gen/.github/ | github workflow dir | 
| gen/makefile | makefile for project |
| gen/cmd/server/ | GRPC API Server | 
| gen/pkg/grpcserver | GRPC Server | 


## 