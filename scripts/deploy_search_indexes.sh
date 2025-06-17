#!/bin/bash

set -e

# Get the directory that this script is in
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

searchIndexName=$(azd env get-value AZURE_SEARCH_INDEX)

if [ -z "$searchIndexName" ]; then    
    searchIndexName="vector-index"
    echo "Search index name is not provided. Using default name: $searchIndexName" 
fi

search_url=$(azd env get-value AZURE_SEARCH_SERVICE_ENDPOINT)
embedding_vector_size=$(azd env get-value AZURE_OPENAI_EMB_VECTOR_SIZE)
search_index_analyzer=$(azd env get-value SEARCH_INDEX_ANALYZER)
azure_search_endpoint=$(azd env get-value TF_VAR_azure_search_scope)

if [ -z "$search_url" ]; then
    echo "Error: AZURE_SEARCH_SERVICE_ENDPOINT is empty."
    exit 1
fi

if [ -z "$embedding_vector_size" ]; then
    echo "Error: EMBEDDING_VECTOR_SIZE is empty."
    exit 1
fi

if [ -z "$search_index_analyzer" ]; then
    search_index_analyzer="standard.lucene"
    echo "SEARCH_INDEX_ANALYZER is not set. Using default: $search_index_analyzer"
fi

if [ -z "$azure_search_endpoint" ]; then
    azure_search_endpoint="https://search.windows.net"
    echo "TF_VAR_azure_search_scope is not set. Using default: $azure_search_endpoint"
fi

# Obtain an access token for Azure Search
echo "Fetching access token for Azure Search..."
access_token=$(az account get-access-token --resource "https://search.windows.net" --query accessToken -o tsv)

# Fetch existing index definition if it exists
echo "Updating index file with environment variables..."

base_index_vector_file="${DIR}/../azure_search/create_vector_index.json"
index_vector_file="index.json"

cp $base_index_vector_file $index_vector_file

echo "Replacing __SEARCH_INDEX_NAME__ with $searchIndexName ..."
sed -i "s/__SEARCH_INDEX_NAME__/${searchIndexName}/g" $index_vector_file

echo "Replacing __SEARCH_INDEX_ANALYZER__ with $search_index_analyzer ..."
sed -i "s/__SEARCH_INDEX_ANALYZER__/${search_index_analyzer}/g" $index_vector_file

echo "Replacing __EMBEDDING_VECTOR_SIZE__ with $embedding_vector_size ..."
sed -i "s/__EMBEDDING_VECTOR_SIZE__/${embedding_vector_size}/g" $index_vector_file

index_vector_json=$(cat $index_vector_file)
index_vector_name="$searchIndexName"

echo "Checking if index $index_vector_name already exists..."
existing_index=$(curl -s --header "Authorization: Bearer $access_token" $search_url/indexes/$index_vector_name?api-version=2024-05-01-preview)

if [[ "$existing_index" != *"No index with the name"* ]]; then
    existing_dimensions=$(echo "$existing_index" | jq -r '.fields | map(select(.name == "contentVector")) | .[0].dimensions')
    existing_index_name=$(echo "$existing_index" | jq -r '.name')
    # Compare existing dimensions with current $EMBEDDING_VECTOR_SIZE
    if [[ -n "$existing_dimensions" ]] && [[ "$existing_dimensions" != "$embedding_vector_size" ]]; then
        echo "Dimensions mismatch: Existing dimensions: $existing_dimensions, Current dimensions: $embedding_vector_size. Deleting the existing index..."
        echo "Deleting the existing index $existing_index_name..."
        curl -X DELETE --header "Authorization: Bearer $access_token" $search_url/indexes/$existing_index_name?api-version=2024-05-01-preview
        echo "Index $index_vector_name deleted."
    fi
fi    

# Create vector index
echo "Creating index $index_vector_name ..."
curl -s -X PUT --header "Content-Type: application/json" --header "Authorization: Bearer $access_token" --data "$index_vector_json" $search_url/indexes/$index_vector_name?api-version=2024-05-01-preview

echo -e "\n"
echo "Successfully deployed $index_vector_name."
