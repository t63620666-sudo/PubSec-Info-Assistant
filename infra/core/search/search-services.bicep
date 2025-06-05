metadata description = 'Creates an Azure AI Search instance.'
param name string
param location string = resourceGroup().location
param tags object = {}

param sku object = {
  name: 'standard'
}

param authOptions object = {}
param disableLocalAuth bool = false
param encryptionWithCmk object = {
  enforcement: 'Unspecified'
}
@allowed([
  'default'
  'highDensity'
])
param hostingMode string = 'default'
@allowed([
  'enabled'
  'disabled'
])
param publicNetworkAccess string = 'enabled'
param partitionCount int = 1
param replicaCount int = 1
@allowed([
  'disabled'
  'free'
  'standard'
])
param semanticSearch string = 'disabled'

param sharedPrivateLinkStorageAccounts array = []

param sharedPrivateLinkCosmosAccounts array = []

param sharedPrivateLinkOpenAiAccounts array = []

param ipRules array = []

var searchIdentityProvider = (sku.name == 'free')
  ? null
  : {
      type: 'SystemAssigned'
    }

var sharedPrivateLinks = union(
  map(sharedPrivateLinkStorageAccounts, arg => {
    groupId: 'blob'
    privateLinkResourceId: arg
  }),
  map(sharedPrivateLinkCosmosAccounts, arg => {
    groupId: 'Sql'
    privateLinkResourceId: arg
  }),
  map(sharedPrivateLinkOpenAiAccounts, arg => {
    groupId: 'openai_account'
    privateLinkResourceId: arg
  })
)

resource search 'Microsoft.Search/searchServices@2023-11-01' = {
  name: name
  location: location
  tags: tags
  // The free tier does not support managed identity
  identity: searchIdentityProvider
  properties: {
    authOptions: disableLocalAuth ? null : authOptions
    disableLocalAuth: disableLocalAuth
    encryptionWithCmk: encryptionWithCmk
    hostingMode: hostingMode
    partitionCount: partitionCount
    publicNetworkAccess: publicNetworkAccess
    replicaCount: replicaCount
    semanticSearch: semanticSearch
    networkRuleSet: {
      ipRules: ipRules
    }
  }
  sku: sku

  @batchSize(1)
  resource sharedPrivateLinkResource 'sharedPrivateLinkResources@2023-11-01' = [
    for (resource, i) in sharedPrivateLinks: {
      name: 'shared-private-link-${i}'
      properties: {
        groupId: resource.groupId
        status: 'Approved'
        provisioningState: 'Succeeded'
        requestMessage: 'automatically created by the system'
        privateLinkResourceId: resource.privateLinkResourceId
      }
    }
  ]
}

output id string = search.id
output endpoint string = 'https://${name}.search.windows.net/'
output name string = search.name
output principalId string = !empty(searchIdentityProvider) ? search.identity.principalId : ''
