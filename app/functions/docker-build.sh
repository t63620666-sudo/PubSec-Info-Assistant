#!/bin/bash

set -eo pipefail

resource_group="$1"
acr_name="$2"
function_name="$3"
image_name="$4"

function login_to_acr() {
  local acr_name="$1"
  echo "Logging in to ACR: $acr_name"
  token=$(az acr login --name "$acr_name" --expose-token --output tsv --query accessToken --only-show-errors)
  docker login "$acr_name" --username 00000000-0000-0000-0000-000000000000 --password-stdin <<<"$token"
}

if [ -z "$resource_group" ] || [ -z "$acr_name" ] || [ -z "$function_name" ] || [ -z "$image_name" ]; then
  echo "Usage: $0 <resource_group> <acr_name> <function_name> <image_name>"
  exit 1
fi

# Get the directory that this script is in
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Build the Docker image with the correct context
echo "Building Docker image: $function_name"
echo -e "\n"
docker build -t "$function_name" "${DIR}" --build-arg BUILDKIT_INLINE_CACHE=1

# Generate a unique tag for the image
tag=$(date -u +"%Y%m%d-%H%M%S")
image_latest="$acr_name/$image_name:latest"
image="$acr_name/$image_name:$tag"

echo "Tagging image with: $tag, latest"
docker tag "$function_name" "$image"
docker tag "$function_name" "$image_latest"

if [[ -z $SKIP_ACR_LOGIN ]] || [[ $SKIP_ACR_LOGIN != "true" ]]; then
  login_to_acr "$acr_name"
else
  echo "Skipping ACR login as SKIP_ACR_LOGIN is set to true."
fi

echo "Pushing image to ACR: $acr_name"
docker push "$image"
docker push "$image_latest"

echo "Build and tagging complete. Tag: $tag"
echo -e "\n"

echo "Updating function app with new image $image"
az functionapp config container set \
  --name "$function_name" \
  --resource-group "$resource_group" \
  --image "$image"
