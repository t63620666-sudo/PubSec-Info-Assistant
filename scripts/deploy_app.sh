#!/bin/bash

deploy_component="$1"

if [ -z "$deploy_component" ]; then
    deploy_component="all"
    echo "No component specified. Defaulting to 'all'."
fi

if [ "$deploy_component" != "function" ] && [ "$deploy_component" != "backend" ] && [ "$deploy_component" != "all" ]; then
    echo "Invalid component: $deploy_component"
    echo "Available components: function, backend, all"
    exit 1
fi

resource_group=$(azd env get-value AZURE_RESOURCE_GROUP)
acr_name=$(azd env get-value AZURE_CONTAINER_REGISTRY_ENDPOINT)

if [ "$deploy_component" == "function" ] || [ "$deploy_component" == "all" ]; then
    echo "Deploying function..."
    
    function_name=$(azd env get-value AZURE_FUNCTION_SERVICE_NAME)
    function_image_name="function"

    . ./app/functions/docker-build.sh "$resource_group" "$acr_name" "$function_name" "$function_image_name"
fi

if [ "$deploy_component" == "backend" ] || [ "$deploy_component" == "all" ]; then
    echo "Deploying backend..."
    
    backend_name=$(azd env get-value AZURE_WEBAPP_SERVICE_NAME)
    backend_image_name="backend"

    . ./app/backend/docker-build.sh "$resource_group" "$acr_name" "$backend_name" "$backend_image_name"
fi

echo "Done."
