targetScope = 'subscription'

param buildNumber string = '1.0.0'

param createResourceGroup bool = true
param resourceGroupName string = ''
param location string = 'eastus'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

var tags = {
  ProjectName: 'Information Assistant'
  BuildNumber: buildNumber
}

var abbrs = loadJsonContent('./abbreviations.json')
var azureRoles = loadJsonContent('./azure_roles.json')

var selectedRoles = [
  azureRoles.CognitiveServicesOpenAIUser
  azureRoles.CognitiveServicesUser
  azureRoles.StorageBlobDataOwner
  azureRoles.StorageQueueDataContributor
  azureRoles.SearchIndexDataContributor
]

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = if (createResourceGroup) {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

resource existingResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = if (!createResourceGroup) {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
}

var selectedResourceGroupName = (createResourceGroup ? resourceGroup.name : existingResourceGroup.name)

resource mainResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: selectedResourceGroupName
}
