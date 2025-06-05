targetScope = 'subscription'

param buildNumber string = '1.0.0'

param createResourceGroup bool = true
param resourceGroupName string = ''
param location string = 'eastus'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@allowed(['appservice', 'containerapps'])
param deploymentTarget string = 'appservice'

param appServicePlanAseId string = '' // Set in main.parameters.json
param appServicePlanName string = '' // Set in main.parameters.json
param backendServiceName string = '' // Set in main.parameters.json
param appServiceSkuName string // Set in main.parameters.json
param appServiceSkuTier string // Set in main.parameters.json

param functionServiceAseId string = '' // Set in main.parameters.json
param functionServicePlanName string = '' // Set in main.parameters.json
param functionServiceSkuName string // Set in main.parameters.json
param functionServiceSkuTier string // Set in main.parameters.json
param functionServiceName string = '' // Set in main.parameters.json

param enrichmentServiceAseId string = '' // Set in main.parameters.json
param enrichmentServiceName string = '' // Set in main.parameters.json
param enrichmentServicePlanName string = '' // Set in main.parameters.json
param enrichmentServiceSkuName string // Set in main.parameters.json
param enrichmentServiceSkuTier string // Set in main.parameters.json

param applicationInsightsDashboardName string = '' // Set in main.parameters.json
param applicationInsightsName string = '' // Set in main.parameters.json
param logAnalyticsName string = '' // Set in main.parameters.json

param storageAccountName string = '' // Set in main.parameters.json
param storageResourceGroupName string = '' // Set in main.parameters.json
param storageResourceGroupLocation string = location
param storageContainerName string = 'content'
param storageSkuName string // Set in main.parameters.json
param storageTokenContainerName string = 'tokens'

@allowed(['free', 'provisioned', 'serverless'])
param cosmosDbSkuName string // Set in main.parameters.json
param cosmodDbResourceGroupName string = ''
param cosmosDbLocation string = ''
param cosmosDbAccountName string = ''
param cosmosDbThroughput int = 400
param statusLogDatabaseName string = 'status-log-database'
param statusLogContainerName string = 'status-log'
param statusLogVersion string = 'cosmosdb-v2'
param videoMetadataDatabaseName string = 'video-metadata-database'
param videoMetadataContainerName string = 'video-metadata'
param videoProcessingDatabaseName string = 'video-processing-database'
param videoProcessingContainerName string = 'video-processing'
param videoAnalysisVersion string = 'cosmosdb-v2'
param chatHistoryDatabaseName string = 'chat-database'
param chatHistoryContainerName string = 'chat-history-v2'
param chatHistoryVersion string = 'cosmosdb-v2'

param searchServiceName string = '' // Set in main.parameters.json
param searchServiceResourceGroupName string = '' // Set in main.parameters.json
param searchServiceLocation string = '' // Set in main.parameters.json
// The free tier does not support managed identity (required) or semantic search (optional)
@allowed(['free', 'basic', 'standard', 'standard2', 'standard3', 'storage_optimized_l1', 'storage_optimized_l2'])
param searchServiceSkuName string // Set in main.parameters.json
param searchIndexName string // Set in main.parameters.json
param searchIndexerName string // Set in main.parameters.json
param searchQueryLanguage string // Set in main.parameters.json
param searchQuerySpeller string // Set in main.parameters.json
param searchServiceSemanticRankerLevel string // Set in main.parameters.json
var actualSearchServiceSemanticRankerLevel = (searchServiceSkuName == 'free')
  ? 'disabled'
  : searchServiceSemanticRankerLevel

@allowed(['azure', 'openai', 'azure_custom'])
param openAiHost string // Set in main.parameters.json
param isAzureOpenAiHost bool = startsWith(openAiHost, 'azure')
param deployAzureOpenAi bool = true
param deployAzureOpenModels bool = true
param azureOpenAiCustomUrl string = ''
param azureOpenAiApiVersion string = ''
@secure()
param azureOpenAiApiKey string = ''
param azureOpenAiDisableKeys bool = false
param openAiServiceName string = ''
param openAiResourceGroupName string = ''
// https://learn.microsoft.com/azure/ai-services/openai/concepts/models?tabs=python-secure%2Cstandard%2Cstandard-chat-completions#standard-deployment-model-availability
@description('Location for the OpenAI resource group')
@allowed([
  'canadaeast'
  'eastus'
  'eastus2'
  'francecentral'
  'switzerlandnorth'
  'uksouth'
  'japaneast'
  'northcentralus'
  'australiaeast'
  'swedencentral'
])
@metadata({
  azd: {
    type: 'location'
  }
})
param openAiLocation string
param openAiSkuName string = 'S0'
@secure()
param openAiApiKey string = ''
param openAiApiOrganization string = ''

param chatGptModelName string = ''
param chatGptDeploymentName string = ''
param chatGptDeploymentVersion string = ''
param chatGptDeploymentSkuName string = ''
param chatGptDeploymentCapacity int = 0

var chatGpt = {
  modelName: !empty(chatGptModelName)
    ? chatGptModelName
    : startsWith(openAiHost, 'azure') ? 'gpt-35-turbo' : 'gpt-3.5-turbo'
  deploymentName: !empty(chatGptDeploymentName) ? chatGptDeploymentName : 'chat'
  deploymentVersion: !empty(chatGptDeploymentVersion) ? chatGptDeploymentVersion : '0125'
  deploymentSkuName: !empty(chatGptDeploymentSkuName) ? chatGptDeploymentSkuName : 'Standard'
  deploymentCapacity: chatGptDeploymentCapacity != 0 ? chatGptDeploymentCapacity : 30
}

param embeddingModelName string = ''
param embeddingDeploymentName string = ''
param embeddingDeploymentVersion string = ''
param embeddingDeploymentSkuName string = ''
param embeddingDeploymentCapacity int = 0
param embeddingDimensions int = 0

var embedding = {
  modelName: !empty(embeddingModelName) ? embeddingModelName : 'text-embedding-ada-002'
  deploymentName: !empty(embeddingDeploymentName) ? embeddingDeploymentName : 'embedding'
  deploymentVersion: !empty(embeddingDeploymentVersion) ? embeddingDeploymentVersion : '2'
  deploymentSkuName: !empty(embeddingDeploymentSkuName) ? embeddingDeploymentSkuName : 'Standard'
  deploymentCapacity: embeddingDeploymentCapacity != 0 ? embeddingDeploymentCapacity : 30
  dimensions: embeddingDimensions != 0 ? embeddingDimensions : 1536
}

// Network isolation
@description('Public network access value for all deployed resources')
@allowed(['Enabled', 'Disabled'])
param publicNetworkAccess string = 'Disabled'
@description('Add a private endpoints for network connectivity')
param usePrivateEndpoint bool = false
param useExistingPrivateDnsZones bool = false
param privateDnsZonesSubscriptionId string = ''
param privateDnsZonesResourceGroupName string = ''
param linkPrivateEndpointToPrivateDnsZone bool = false
param skipPrivateDnsZones bool = false

param useExistingVnet bool = false
param existingVnetSubscriptionId string = ''
param existingVnetResourceGroupName string = ''
param existingVnetName string = ''
param existingBackendSubnetName string = ''
param existingAppIntSubnetName string = ''
param existingFuncIntSubnetName string = ''

param subnetBackendName string = 'backend-subnet'
param subnetAppIntName string = 'app-int-subnet'
param subnetFuncIntName string = 'func-int-subnet'

param vnetAddressPrefix string = '10.0.0.0/16'
param subnetBackendAddressPrefix string = '10.0.1.0/24'
param subnetAppIntAddressPrefix string = '10.0.2.0/24'
param subnetFuncIntAddressPrefix string = '10.0.3.0/24'

param allowedIps string = ''

@allowed(['None', 'AzureServices'])
@description('If allowedIp is set, whether azure services are allowed to bypass the storage and AI services firewall.')
param bypass string = 'AzureServices'

@description('Use Application Insights for monitoring and performance tracing')
param useApplicationInsights bool = false

param tenantId string = tenant().tenantId
param authTenantId string = ''

// Used for the optional login and document level access control system
param useAuthentication bool = false
param useUserUpload bool = false
param enforceAccessControl bool = false
// Force using MSAL app authentication instead of built-in App Service authentication
// https://learn.microsoft.com/azure/app-service/overview-authentication-authorization
param disableAppServicesAuthentication bool = false
param enableGlobalDocuments bool = false
param enableUnauthenticatedAccess bool = false
param serverAppId string = ''
@secure()
param serverAppSecret string = ''
param clientAppId string = ''
@secure()
param clientAppSecret string = ''
// Used for optional CORS support for alternate frontends
param allowedOrigin string = '' // should start with https://, shouldn't end with a /

// Configure CORS for allowing different web apps to use the backend
// For more information please see https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS
var msftAllowedOrigins = ['https://portal.azure.com', 'https://ms.portal.azure.com']
var loginEndpoint = environment().authentication.loginEndpoint
var loginEndpointFixed = lastIndexOf(loginEndpoint, '/') == length(loginEndpoint) - 1
  ? substring(loginEndpoint, 0, length(loginEndpoint) - 1)
  : loginEndpoint
var allMsftAllowedOrigins = !(empty(clientAppId)) ? union(msftAllowedOrigins, [loginEndpointFixed]) : msftAllowedOrigins
// Combine custom origins with Microsoft origins, remove any empty origin strings and remove any duplicate origins
var allowedOrigins = reduce(
  filter(union(split(allowedOrigin, ';'), allMsftAllowedOrigins), o => length(trim(o)) > 0),
  [],
  (cur, next) => union(cur, [next])
)

var tenantIdForAuth = !empty(authTenantId) ? authTenantId : tenantId
var authenticationIssuerUri = '${environment().authentication.loginEndpoint}${tenantIdForAuth}/v2.0'

var tags = {
  ProjectName: 'Information Assistant'
  BuildNumber: buildNumber
}

var abbrs = loadJsonContent('./abbreviations.json')
var azureRoles = loadJsonContent('./azure_roles.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

var selectedRoles = [
  azureRoles.CognitiveServicesOpenAIUser
  azureRoles.CognitiveServicesUser
  azureRoles.StorageBlobDataOwner
  azureRoles.StorageQueueDataContributor
  azureRoles.SearchIndexDataContributor
]

var ipRules = reduce(
  filter(array(split(allowedIps, ';')), o => length(trim(o)) > 0),
  [],
  (cur, next) =>
    union(cur, [
      {
        value: next
      }
    ])
)

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

resource storageResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = if (!empty(storageResourceGroupName)) {
  name: !empty(storageResourceGroupName) ? storageResourceGroupName : mainResourceGroup.name
}

resource openAiResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = if (!empty(openAiResourceGroupName)) {
  name: !empty(openAiResourceGroupName) ? openAiResourceGroupName : mainResourceGroup.name
}

resource searchServiceResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = if (!empty(searchServiceResourceGroupName)) {
  name: !empty(searchServiceResourceGroupName) ? searchServiceResourceGroupName : mainResourceGroup.name
}

resource cosmosDbResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = if (!empty(cosmodDbResourceGroupName)) {
  name: !empty(cosmodDbResourceGroupName) ? cosmodDbResourceGroupName : mainResourceGroup.name
}

module storage 'core/storage/storage-account.bicep' = {
  name: 'storage'
  scope: storageResourceGroup
  params: {
    name: !empty(storageAccountName) ? storageAccountName : '${abbrs.storageStorageAccounts}${resourceToken}'
    location: storageResourceGroupLocation
    tags: tags
    publicNetworkAccess: !empty(ipRules) ? 'Enabled' : publicNetworkAccess
    networkAcls: {
      bypass: bypass
      defaultAction: 'Deny'
      ipRules: map(ipRules, ipRule => {
        value: ipRule.?value
        action: 'Allow'
      })
    }
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    sku: {
      name: storageSkuName
    }
    deleteRetentionPolicy: {
      enabled: true
      days: 2
    }
    containers: [
      {
        name: storageContainerName
        publicAccess: 'None'
      }
      {
        name: storageTokenContainerName
        publicAccess: 'None'
      }
      {
        name: 'website'
        publicAccess: 'None'
      }
      {
        name: 'upload'
        publicAccess: 'None'
      }
      {
        name: 'function'
        publicAccess: 'None'
      }
      {
        name: 'logs'
        publicAccess: 'None'
      }
      {
        name: 'config'
        publicAccess: 'None'
      }
    ]
    queues: map(
      [
        'pdf-submit-queue'
        'pdf-polling-queue'
        'non-pdf-submit-queue'
        'media-submit-queue'
        'text-enrichment-queue'
        'image-enrichment-queue'
        'embeddings-queue'
      ],
      arg => {
        name: arg
      }
    )
  }
}

module monitoring 'core/monitor/monitoring.bicep' = if (useApplicationInsights) {
  name: 'monitoring'
  scope: mainResourceGroup
  params: {
    location: location
    tags: tags
    applicationInsightsName: !empty(applicationInsightsName)
      ? applicationInsightsName
      : '${abbrs.insightsComponents}${resourceToken}'
    logAnalyticsName: !empty(logAnalyticsName)
      ? logAnalyticsName
      : '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    publicNetworkAccess: publicNetworkAccess
    linkedStorageAccountId: storage.outputs.id
  }
}

var openAiDeployments = [
  {
    name: chatGpt.deploymentName
    model: {
      format: 'OpenAI'
      name: chatGpt.modelName
      version: chatGpt.deploymentVersion
    }
    sku: {
      name: chatGpt.deploymentSkuName
      capacity: chatGpt.deploymentCapacity
    }
  }
  {
    name: embedding.deploymentName
    model: {
      format: 'OpenAI'
      name: embedding.modelName
      version: embedding.deploymentVersion
    }
    sku: {
      name: embedding.deploymentSkuName
      capacity: embedding.deploymentCapacity
    }
  }
]

module openAi 'br/public:avm/res/cognitive-services/account:0.7.2' = if (isAzureOpenAiHost && deployAzureOpenAi) {
  name: 'openai'
  scope: openAiResourceGroup
  params: {
    name: !empty(openAiServiceName) ? openAiServiceName : '${abbrs.cognitiveServicesAccounts}${resourceToken}'
    location: openAiLocation
    tags: tags
    kind: 'OpenAI'
    managedIdentities: {
      systemAssigned: true
    }
    customSubDomainName: !empty(openAiServiceName)
      ? openAiServiceName
      : '${abbrs.cognitiveServicesAccounts}${resourceToken}'
    publicNetworkAccess: !empty(ipRules) ? 'Enabled' : publicNetworkAccess
    networkAcls: {
      defaultAction: 'Deny'
      bypass: bypass
      ipRules: ipRules
    }
    sku: openAiSkuName
    deployments: openAiDeployments
    disableLocalAuth: azureOpenAiDisableKeys
  }
}

resource existingOpenAi 'Microsoft.CognitiveServices/accounts@2024-10-01' existing = if (isAzureOpenAiHost && !deployAzureOpenAi) {
  name: openAiServiceName
  scope: openAiResourceGroup
}

module openAiDeploymentsInExistingOpenAi 'core/ai/openai-deployments.bicep' = if (isAzureOpenAiHost && !deployAzureOpenAi && deployAzureOpenModels) {
  name: 'openai-deployments'
  scope: openAiResourceGroup
  params: {
    deployments: openAiDeployments
    openAiServiceName: existingOpenAi.name
  }
}

module searchService 'core/search/search-services.bicep' = {
  name: 'search-service'
  scope: searchServiceResourceGroup
  params: {
    name: !empty(searchServiceName) ? searchServiceName : 'gptkb-${resourceToken}'
    location: !empty(searchServiceLocation) ? searchServiceLocation : location
    tags: tags
    disableLocalAuth: true
    sku: {
      name: searchServiceSkuName
    }
    semanticSearch: actualSearchServiceSemanticRankerLevel
    ipRules: ipRules
    publicNetworkAccess: !empty(ipRules)
      ? 'enabled'
      : (publicNetworkAccess == 'Enabled' ? 'enabled' : (publicNetworkAccess == 'Disabled' ? 'disabled' : null))
    sharedPrivateLinkStorageAccounts: usePrivateEndpoint ? [storage.outputs.id] : []
    sharedPrivateLinkCosmosAccounts: usePrivateEndpoint ? [cosmosDb.outputs.resourceId] : []
    sharedPrivateLinkOpenAiAccounts: usePrivateEndpoint && isAzureOpenAiHost
      ? [deployAzureOpenAi ? openAi.outputs.resourceId : existingOpenAi.id]
      : []
  }
}

module cosmosDb 'br/public:avm/res/document-db/database-account:0.6.1' = {
  name: 'cosmosdb'
  scope: cosmosDbResourceGroup
  params: {
    name: !empty(cosmosDbAccountName) ? cosmosDbAccountName : '${abbrs.documentDBDatabaseAccounts}${resourceToken}'
    location: !empty(cosmosDbLocation) ? cosmosDbLocation : location
    locations: [
      {
        locationName: !empty(cosmosDbLocation) ? cosmosDbLocation : location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    enableFreeTier: cosmosDbSkuName == 'free'
    capabilitiesToAdd: cosmosDbSkuName == 'serverless' ? ['EnableServerless'] : []
    networkRestrictions: {
      ipRules: map(ipRules, ipRule => lastIndexOf(ipRule.?value, '/') == -1 ? '${ipRule.?value}/32' : ipRule.?value)
      networkAclBypass: bypass
      publicNetworkAccess: !empty(ipRules) ? 'Enabled' : publicNetworkAccess
      virtualNetworkRules: []
    }
    sqlDatabases: [
      {
        name: chatHistoryDatabaseName
        throughput: (cosmosDbSkuName == 'serverless') ? null : cosmosDbThroughput
        containers: [
          {
            name: chatHistoryContainerName
            kind: 'MultiHash'
            paths: [
              '/entra_oid'
              '/session_id'
            ]
            indexingPolicy: {
              indexingMode: 'consistent'
              automatic: true
              includedPaths: [
                {
                  path: '/entra_oid/?'
                }
                {
                  path: '/session_id/?'
                }
                {
                  path: '/timestamp/?'
                }
                {
                  path: '/type/?'
                }
              ]
              excludedPaths: [
                {
                  path: '/*'
                }
              ]
            }
          }
        ]
      }
      {
        name: statusLogDatabaseName
        throughput: (cosmosDbSkuName == 'serverless') ? null : cosmosDbThroughput
        containers: [
          {
            name: statusLogContainerName
            kind: 'Hash'
            paths: [
              '/file_name'
            ]
            indexingPolicy: {
              indexingMode: 'consistent'
              automatic: true
              includedPaths: [
                {
                  path: '/file_name/?'
                }
                {
                  path: '/file_path/?'
                }
              ]
              excludedPaths: [
                {
                  path: '/*'
                }
              ]
            }
          }
        ]
      }
      {
        name: videoMetadataDatabaseName
        throughput: (cosmosDbSkuName == 'serverless') ? null : cosmosDbThroughput
        containers: [
          {
            name: videoMetadataContainerName
            kind: 'Hash'
            paths: [
              '/entra_oid'
            ]
            indexingPolicy: {
              indexingMode: 'consistent'
              automatic: true
              includedPaths: [
                {
                  path: '/entra_oid/?'
                }
                {
                  path: '/video_id/?'
                }
                {
                  path: '/video_path/?'
                }
                {
                  path: '/action_summary/?'
                }
                {
                  path: '/chapter_summary/?'
                }
              ]
              excludedPaths: [
                {
                  path: '/*'
                }
              ]
            }
          }
        ]
      }
      {
        name: videoProcessingDatabaseName
        throughput: (cosmosDbSkuName == 'serverless') ? null : cosmosDbThroughput
        containers: [
          {
            name: videoProcessingContainerName
            kind: 'Hash'
            paths: [
              '/video_id'
            ]
            indexingPolicy: {
              indexingMode: 'consistent'
              automatic: true
              includedPaths: [
                {
                  path: '/video_id/?'
                }
                {
                  path: '/status/?'
                }
                {
                  path: '/steps/?'
                }
                {
                  path: '/createdAt/?'
                }
                {
                  path: '/updatedAt/?'
                }
              ]
              excludedPaths: [
                {
                  path: '/*'
                }
              ]
            }
          }
        ]
      }
    ]
  }
}

module containerRegistry 'br/public:avm/res/container-registry/registry:0.5.1' = {
  name: 'container-registry'
  scope: mainResourceGroup
  params: {
    name: '${abbrs.containerRegistryRegistries}${resourceToken}'
    location: location
    acrAdminUserEnabled: false
    tags: tags
    acrSku: 'Premium'
    networkRuleSetIpRules: !empty(ipRules) ? ipRules : null
    publicNetworkAccess: !empty(ipRules) ? 'Enabled' : publicNetworkAccess
    networkRuleSetDefaultAction: 'Deny'
    exportPolicyStatus: !empty(ipRules) ? 'enabled' : (publicNetworkAccess == 'Enabled' ? 'enabled' : 'disabled')
  }
}

module backendPlan 'core/host/appserviceplan.bicep' = if (deploymentTarget == 'appservice') {
  name: 'appserviceplan'
  scope: mainResourceGroup
  params: {
    name: !empty(appServicePlanName) ? appServicePlanName : '${abbrs.webServerFarms}${resourceToken}'
    location: location
    tags: tags
    aseId: appServicePlanAseId
    sku: {
      name: appServiceSkuName
      capacity: 1
      tier: appServiceSkuTier
    }
    kind: 'linux'
  }
}

// App Service for the web application (Python Quart app with JS frontend)
module backend 'core/host/appservice.bicep' = if (deploymentTarget == 'appservice') {
  name: 'web'
  scope: mainResourceGroup
  params: {
    name: !empty(backendServiceName) ? backendServiceName : '${abbrs.webSitesAppService}backend-${resourceToken}'
    location: location
    tags: union(tags, { 'azd-service-name': 'backend' })
    // Need to check deploymentTarget again due to https://github.com/Azure/bicep/issues/3990
    appServicePlanId: deploymentTarget == 'appservice' ? backendPlan.outputs.id : ''
    kind: 'app,linux,container'
    imageName: '${containerRegistry.outputs.loginServer}/backend:latest'
    scmDoBuildDuringDeployment: true
    managedIdentity: true
    ipRules: ipRules
    publicNetworkAccess: !empty(ipRules) || !empty(appServicePlanAseId) ? 'Enabled' : publicNetworkAccess
    virtualNetworkSubnetId: isolation.outputs.appSubnetId
    isHostedInAse: !empty(appServicePlanAseId)
    allowedOrigins: allowedOrigins
    clientAppId: clientAppId
    serverAppId: serverAppId
    enableUnauthenticatedAccess: enableUnauthenticatedAccess
    disableAppServicesAuthentication: disableAppServicesAuthentication
    clientSecretSettingName: !empty(clientAppSecret) ? 'AZURE_CLIENT_APP_SECRET' : ''
    authenticationIssuerUri: authenticationIssuerUri
    use32BitWorkerProcess: appServiceSkuName == 'F1'
    alwaysOn: appServiceSkuName != 'F1'
    appSettings: union(appEnvVariables, {
      AZURE_SERVER_APP_SECRET: serverAppSecret
      AZURE_CLIENT_APP_SECRET: clientAppSecret
    })
    applicationInsightsName: monitoring.outputs.applicationInsightsName
  }
}

module functionServicePlan 'core/host/appserviceplan.bicep' = {
  name: 'functionserviceplan'
  scope: mainResourceGroup
  params: {
    name: !empty(functionServicePlanName) ? functionServicePlanName : '${abbrs.webServerFarms}func-${resourceToken}'
    location: location
    tags: tags
    aseId: functionServiceAseId
    sku: {
      name: functionServiceSkuName
      capacity: 1
      tier: functionServiceSkuTier
    }
    kind: 'linux'
  }
}

module functionStorage 'core/storage/storage-account.bicep' = {
  name: 'function-storage'
  scope: storageResourceGroup
  params: {
    name: '${abbrs.storageStorageAccounts}func${resourceToken}'
    location: storageResourceGroupLocation
    tags: tags
    publicNetworkAccess: !empty(ipRules) ? 'Enabled' : publicNetworkAccess
    networkAcls: {
      bypass: bypass
      defaultAction: 'Deny'
      ipRules: map(ipRules, ipRule => {
        value: ipRule.?value
        action: 'Allow'
      })
    }
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    sku: {
      name: storageSkuName
    }
    deleteRetentionPolicy: {
      enabled: true
      days: 2
    }
  }
}

module function 'br/public:avm/res/web/site:0.15.1' = {
  name: 'function'
  scope: mainResourceGroup
  params: {
    // Required parameters
    kind: 'app,linux,container'
    tags: union(tags, { 'azd-service-name': 'function' })
    name: !empty(functionServiceName) ? functionServiceName : '${abbrs.webSitesFunctions}${resourceToken}'
    serverFarmResourceId: functionServicePlan.outputs.id
    appInsightResourceId: useApplicationInsights ? monitoring.outputs.applicationInsightsId : ''
    managedIdentities: {
      systemAssigned: true
    }
    publicNetworkAccess: !empty(ipRules) ? 'Enabled' : publicNetworkAccess
    virtualNetworkSubnetId: empty(functionServiceAseId) ? isolation.outputs.funcIntSubnetId : null
    vnetImagePullEnabled: true
    vnetContentShareEnabled: true
    vnetRouteAllEnabled: true
    storageAccountResourceId: functionStorage.outputs.id
    storageAccountUseIdentityAuthentication: true
    // Non-required parameters
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistry.outputs.loginServer}/function:latest'
      ipSecurityRestrictions: map(ipRules, ipRule => {
        ipAddress: lastIndexOf(ipRule.?value, '/') == -1 ? '${ipRule.?value}/32' : ipRule.?value
        action: 'Allow'
      })
      ipSecurityRestrictionsDefaultAction: 'Deny'
      acrUseManagedIdentityCreds: true
    }
    appSettingsKeyValuePairs: {
      AzureFunctionsJobHost__logging__logLevel__default: 'Trace'
      FUNCTIONS_EXTENSION_VERSION: '~4'
      FUNCTIONS_WORKER_RUNTIME: 'python'
      // TODO: Add more app settings here
    }
  }
}

module isolation 'network-isolation.bicep' = {
  name: 'networks'
  scope: mainResourceGroup
  params: {
    deploymentTarget: deploymentTarget
    location: location
    tags: tags
    vnetName: useExistingVnet
      ? (!empty(existingVnetName) ? existingVnetName : '${abbrs.networkVirtualNetworks}${resourceToken}')
      : '${abbrs.networkVirtualNetworks}${resourceToken}'
    // Need to check deploymentTarget due to https://github.com/Azure/bicep/issues/3990
    appServicePlanName: deploymentTarget == 'appservice' ? backendPlan.outputs.name : ''
    funcServicePlanName: functionServicePlan.outputs.name
    usePrivateEndpoint: usePrivateEndpoint
    vnetAddressPrefix: vnetAddressPrefix
    subnetAppIntAddressPrefix: subnetAppIntAddressPrefix
    subnetBackendAddressPrefix: subnetBackendAddressPrefix
    subnetFuncIntAddressPrefix: subnetFuncIntAddressPrefix
    useExistingVnet: useExistingVnet
    existingVnetSubscriptionId: existingVnetSubscriptionId
    existingVnetResourceGroupName: existingVnetResourceGroupName
    subnetAppIntName: useExistingVnet
      ? (!empty(existingAppIntSubnetName) ? existingAppIntSubnetName : subnetAppIntName)
      : subnetAppIntName
    subnetBackendName: useExistingVnet
      ? (!empty(existingBackendSubnetName) ? existingBackendSubnetName : subnetBackendName)
      : subnetBackendName
    subnetFuncIntName: useExistingVnet
      ? (!empty(existingFuncIntSubnetName) ? existingFuncIntSubnetName : subnetFuncIntName)
      : subnetFuncIntName
  }
}

var environmentData = environment()

var openAiPrivateEndpointConnection = (isAzureOpenAiHost && deployAzureOpenAi)
  ? [
      {
        groupId: 'account'
        dnsZoneName: 'privatelink.openai.azure.com'
        resourceIds: [openAi.outputs.resourceId]
      }
    ]
  : []

var cognitiveServicesPrivateEndpointConnection = (usePrivateEndpoint)
  ? [
      {
        groupId: 'account'
        dnsZoneName: 'privatelink.cognitiveservices.azure.com'
        resourceIds: [speech.outputs.resourceId]
      }
    ]
  : []

var websiteResourceIds = union(
  [],
  empty(appServicePlanAseId) && deploymentTarget == 'appservice' ? [backend.outputs.id] : [],
  empty(functionServiceAseId) ? [function.outputs.resourceId] : []
)

var otherPrivateEndpointConnections = (usePrivateEndpoint)
  ? union(
      [
        {
          groupId: 'blob'
          dnsZoneName: 'privatelink.blob.${environmentData.suffixes.storage}'
          resourceIds: [storage.outputs.id, functionStorage.outputs.id]
        }
        {
          groupId: 'table'
          dnsZoneName: 'privatelink.table.${environmentData.suffixes.storage}'
          resourceIds: [storage.outputs.id, functionStorage.outputs.id]
        }
        {
          groupId: 'queue'
          dnsZoneName: 'privatelink.queue.${environmentData.suffixes.storage}'
          resourceIds: [storage.outputs.id, functionStorage.outputs.id]
        }
        {
          groupId: 'file'
          dnsZoneName: 'privatelink.file.${environmentData.suffixes.storage}'
          resourceIds: [storage.outputs.id, functionStorage.outputs.id]
        }
        {
          groupId: 'dfs'
          dnsZoneName: 'privatelink.dfs.${environmentData.suffixes.storage}'
          resourceIds: [storage.outputs.id, functionStorage.outputs.id]
        }
        {
          groupId: 'searchService'
          dnsZoneName: 'privatelink.search.windows.net'
          resourceIds: [searchService.outputs.id]
        }
        {
          groupId: 'sql'
          dnsZoneName: 'privatelink.documents.azure.com'
          resourceIds: [cosmosDb.outputs.resourceId]
        }
        {
          groupId: 'registry'
          dnsZoneName: 'privatelink.azurecr.io'
          resourceIds: [containerRegistry.outputs.resourceId]
        }
      ],
      !empty(websiteResourceIds)
        ? [
            {
              groupId: 'sites'
              dnsZoneName: 'privatelink.azurewebsites.net'
              resourceIds: websiteResourceIds
            }
          ]
        : []
    )
  : []

var privateEndpointConnections = concat(
  otherPrivateEndpointConnections,
  openAiPrivateEndpointConnection,
  cognitiveServicesPrivateEndpointConnection
)

module privateEndpoints 'private-endpoints.bicep' = if (usePrivateEndpoint) {
  name: 'privateEndpoints'
  scope: mainResourceGroup
  params: {
    location: location
    tags: tags
    resourceToken: resourceToken
    privateEndpointConnections: privateEndpointConnections
    applicationInsightsId: useApplicationInsights ? monitoring.outputs.applicationInsightsId : ''
    logAnalyticsWorkspaceId: useApplicationInsights ? monitoring.outputs.logAnalyticsWorkspaceId : ''
    vnetName: isolation.outputs.vnetName
    vnetPeSubnetName: isolation.outputs.backendSubnetId
    privateDnsZonesSubscriptionId: privateDnsZonesSubscriptionId
    privateDnsZonesResourceGroupName: privateDnsZonesResourceGroupName
    useExistingPrivateDnsZones: useExistingPrivateDnsZones
    linkPrivateEndpointToPrivateDnsZone: linkPrivateEndpointToPrivateDnsZone
    skipPrivateDnsZones: skipPrivateDnsZones
  }
}
