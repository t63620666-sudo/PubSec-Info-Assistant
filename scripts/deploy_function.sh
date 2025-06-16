#!/bin/bash

azure_container_registry_name="$1"
image_name="$2"
image_tag="$3"
dockerfile_path="$4"
source_location="$5"

if [ -z "$azure_container_registry_name" ]; then
  echo "AZURE_CONTAINER_REGISTRY_NAME is not set. Exiting."
  exit 1
fi

if [ -z "$image_name" ]; then
  echo "IMAGE_NAME is not set. Exiting."
  exit 1
fi

if [ -z "$image_tag" ]; then
  echo "IMAGE_TAG is not set. Exiting."
  exit 1
fi

if [ -z "$dockerfile_path" ]; then
  dockerfile_path="Dockerfile"
fi

if [ -z "$source_location" ]; then
  source_location="."
fi

echo "Starting Docker build and push..."
echo "Using Azure Container Registry: $azure_container_registry_name"
echo "Using Dockerfile: $dockerfile_path"
echo "Using Source Location: $source_location"
echo "Using Image Name: $image_name"
echo "Using Image Tag: $image_tag"
echo "Building and pushin Docker image..."

az acr build -r "$azure_container_registry_name" -t "$image_name:$image_tag" -f "$dockerfile_path" "$source_location"

if [ $? -ne 0 ]; then
  echo "Docker build and push failed. Exiting."
  exit 1
fi

echo "Docker build and push completed successfully."