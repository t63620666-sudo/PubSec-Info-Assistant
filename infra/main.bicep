targetScope = 'subscription'

param applicationTitle string = ''
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

param assignRoles bool = false
@description('Id of the user or app to assign application roles')
param principalId string = ''

@description('Whether the deployment is running on GitHub Actions')
param runningOnGh string = ''

@description('Whether the deployment is running on Azure DevOps Pipeline')
param runningOnAdo string = ''

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
param functionMaxSecondsHideOnUpload string = '300'

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

param documentIntelligenceServiceName string = '' // Set in main.parameters.json
param documentIntelligenceResourceGroupName string = '' // Set in main.parameters.json

// Limited regions for new version:
// https://learn.microsoft.com/azure/ai-services/document-intelligence/concept-layout
@description('Location for the Document Intelligence resource group')
@allowed(['eastus', 'westus2', 'westeurope'])
@metadata({
  azd: {
    type: 'location'
  }
})
param documentIntelligenceResourceGroupLocation string
param documentIntelligenceSkuName string // Set in main.parameters.json
param documentIntelligenceApiVersion string = '2023-07-31' // Set in main.parameters.json
param cognitiveServiceName string = '' // Set in main.parameters.json
param cognitiveServiceResourceGroupName string = '' // Set in main.parameters.json

// Limited regions for new version:
// https://learn.microsoft.com/azure/ai-services/document-intelligence/concept-layout
@description('Location for the Document Intelligence resource group')
@allowed(['eastus', 'westus2', 'westeurope'])
@metadata({
  azd: {
    type: 'location'
  }
})
param cognitiveServiceResourceGroupLocation string
param cognitiveServiceSkuName string // Set in main.parameters.json

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
param searchScope string = ''
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
param chatWarningBannerText string

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
param existingEnrichIntSubnetName string = ''

param subnetBackendName string = 'backend-subnet'
param subnetAppIntName string = 'app-int-subnet'
param subnetFuncIntName string = 'func-int-subnet'
param subnetEnrichIntName string = 'enrich-int-subnet'

param vnetAddressPrefix string = '10.0.0.0/16'
param subnetBackendAddressPrefix string = '10.0.1.0/24'
param subnetAppIntAddressPrefix string = '10.0.2.0/24'
param subnetFuncIntAddressPrefix string = '10.0.3.0/24'
param subnetEnrichIntAddressPrefix string = '10.0.4.0/24'

param allowedIps string = ''

@allowed(['None', 'AzureServices'])
@description('If allowedIp is set, whether azure services are allowed to bypass the storage and AI services firewall.')
param bypass string = 'AzureServices'

@description('Use Application Insights for monitoring and performance tracing')
param useApplicationInsights bool = false

param tenantId string = tenant().tenantId
param authTenantId string = ''
@allowed(['AzureCloud', 'AzureUSGovernment'])
param azureEnvironment string = 'AzureCloud' // Set in main.parameters.json

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

param useSemanticReranker bool = true
param enableWebChat bool = true
param enableBingSafeSearch bool = true
param enableUngroundedChat bool = false
param enableMathAssitant bool = true
param enableTabularDataAssistant bool = true
param maxCsvFileSize string = '20'
param chunkTargetSize string = '750'
param targetPages string = 'ALL'
param maxSubmitRequeueCount string = '10'
param pollQueueSubmitBackoff string = '60'
param pdfSubmitQueueBackoff string = '60'
param maxPollingRequeueCount string = '10'
param submitRequeueHideSeconds string = '1200'
param pollingBackoff string = '30'
param maxReadAttempts string = '5'
param targetTranslationLanguage string = 'en'
param maxEnrichmentRequeueCount string = '10'
param enrichmentBackoff string = '60'

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
var roles = loadJsonContent('./azure_roles.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

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

resource documentIntelligenceResourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' existing = if (!empty(documentIntelligenceResourceGroupName)) {
  name: !empty(documentIntelligenceResourceGroupName) ? documentIntelligenceResourceGroupName : mainResourceGroup.name
}

resource cognitiveServiceResourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' existing = if (!empty(cognitiveServiceResourceGroupName)) {
  name: !empty(cognitiveServiceResourceGroupName) ? cognitiveServiceResourceGroupName : mainResourceGroup.name
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

module documentIntelligence 'br/public:avm/res/cognitive-services/account:0.7.2' = {
  name: 'documentintelligence'
  scope: documentIntelligenceResourceGroup
  params: {
    name: !empty(documentIntelligenceServiceName)
      ? documentIntelligenceServiceName
      : '${abbrs.cognitiveServicesDocumentIntelligence}${resourceToken}'
    kind: 'FormRecognizer'
    customSubDomainName: !empty(documentIntelligenceServiceName)
      ? documentIntelligenceServiceName
      : '${abbrs.cognitiveServicesDocumentIntelligence}${resourceToken}'
    publicNetworkAccess: publicNetworkAccess
    networkAcls: {
      defaultAction: 'Deny'
    }
    location: documentIntelligenceResourceGroupLocation
    disableLocalAuth: true
    tags: tags
    sku: documentIntelligenceSkuName
  }
}

module cognitiveServices 'br/public:avm/res/cognitive-services/account:0.7.2' = {
  name: 'cognitiveservices'
  scope: cognitiveServiceResourceGroup
  params: {
    name: !empty(cognitiveServiceName) ? cognitiveServiceName : '${abbrs.cognitiveServicesAccounts}${resourceToken}'
    kind: 'CognitiveServices'
    customSubDomainName: !empty(documentIntelligenceServiceName)
      ? documentIntelligenceServiceName
      : '${abbrs.cognitiveServicesDocumentIntelligence}${resourceToken}'
    publicNetworkAccess: publicNetworkAccess
    networkAcls: {
      defaultAction: 'Deny'
    }
    location: cognitiveServiceResourceGroupLocation
    disableLocalAuth: true
    tags: tags
    sku: cognitiveServiceSkuName
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

// TODO: Confirm empty variables
var appEnvVariables = {
  AZURE_BLOB_STORAGE_ACCOUNT: storage.outputs.name
  AZURE_BLOB_STORAGE_ENDPOINT: storage.outputs.primaryEndpoints.blob
  AZURE_BLOB_STORAGE_CONTAINER: 'content'
  AZURE_BLOB_STORAGE_UPLOAD_CONTAINER: 'upload'
  AZURE_OPENAI_SERVICE: !deployAzureOpenAi ? existingOpenAi.name : openAi.outputs.name
  AZURE_OPENAI_RESOURCE_GROUP: !deployAzureOpenAi ? openAiResourceGroup : openAiResourceGroup.name
  AZURE_OPENAI_ENDPOINT: !deployAzureOpenAi ? existingOpenAi.properties.endpoint : openAi.outputs.endpoint
  AZURE_OPENAI_AUTHORITY_HOST: azureEnvironment
  AZURE_ARM_MANAGEMENT_API: 'https://${environment().resourceManager}'
  AZURE_SEARCH_INDEX: searchIndexName
  AZURE_SEARCH_SERVICE: searchService.outputs.name
  AZURE_SEARCH_SERVICE_ENDPOINT: searchService.outputs.endpoint
  AZURE_SEARCH_AUDIENCE: searchScope
  AZURE_OPENAI_CHATGPT_DEPLOYMENT: chatGpt.deploymentName
  AZURE_OPENAI_CHATGPT_MODEL_NAME: chatGpt.modelName
  AZURE_OPENAI_CHATGPT_MODEL_VERSION: chatGpt.deploymentVersion
  USE_AZURE_OPENAI_EMBEDDINGS: true
  EMBEDDING_DEPLOYMENT_NAME: embedding.deploymentName
  AZURE_OPENAI_EMBEDDINGS_MODEL_NAME: embedding.modelName
  AZURE_OPENAI_EMBEDDINGS_MODEL_VERSION: embedding.deploymentVersion
  COSMOSDB_URL: cosmosDb.outputs.endpoint
  COSMOSDB_LOG_DATABASE_NAME: statusLogDatabaseName
  COSMOSDB_LOG_CONTAINER_NAME: statusLogDatabaseName
  QUERY_TERM_LANGUAGE: searchQueryLanguage
  AZURE_SUBSCRIPTION_ID: subscription().subscriptionId
  CHAT_WARNING_BANNER_TEXT: chatWarningBannerText
  TARGET_EMBEDDINGS_MODEL: 'azure-openai_${embedding.deploymentName}'
  ENRICHMENT_APPSERVICE_URL: enrichmentApp.outputs.defaultHostname
  AZURE_AI_ENDPOINT: cognitiveServices.outputs.endpoint
  AZURE_AI_LOCATION: cognitiveServices.outputs.location
  APPLICATION_TITLE: empty(applicationTitle) ? 'Information Assistant, built with Azure OpenAI' : applicationTitle
  USE_SEMANTIC_RERANKER: useSemanticReranker
  BING_SEARCH_ENDPOINT: ''
  ENABLE_WEB_CHAT: enableWebChat
  ENABLE_BING_SAFE_SEARCH: enableBingSafeSearch
  ENABLE_UNGROUNDED_CHAT: enableUngroundedChat
  ENABLE_MATH_ASSISTANT: enableMathAssitant
  ENABLE_TABULAR_DATA_ASSISTANT: enableTabularDataAssistant
  MAX_CSV_FILE_SIZE: maxCsvFileSize
  AZURE_AI_CREDENTIAL_DOMAIN: 'cognitiveservices.azure.com'
}

// App Service for the web application (Python Quart app with JS frontend)
module webapp 'core/host/appservice.bicep' = if (deploymentTarget == 'appservice') {
  name: 'web'
  scope: mainResourceGroup
  params: {
    name: !empty(backendServiceName) ? backendServiceName : '${abbrs.webSitesAppService}webapp-${resourceToken}'
    location: location
    tags: union(tags, { 'azd-service-name': 'webapp' })
    // Need to check deploymentTarget again due to https://github.com/Azure/bicep/issues/3990
    appServicePlanId: deploymentTarget == 'appservice' ? backendPlan.outputs.id : ''
    kind: 'app,linux,container'
    imageName: '${containerRegistry.outputs.loginServer}/webapp:latest'
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
      BLOB_STORAGE_ACCOUNT: storage.outputs.name
      BLOB_STORAGE_ACCOUNT_ENDPOINT: storage.outputs.primaryEndpoints.blob
      BLOB_STORAGE_ACCOUNT_OUTPUT_CONTAINER_NAME: storageContainerName
      BLOB_STORAGE_ACCOUNT_UPLOAD_CONTAINER_NAME: 'upload'
      BLOB_STORAGE_ACCOUNT_LOG_CONTAINER_NAME: 'logs'
      AZURE_QUEUE_STORAGE_ENDPOINT: storage.outputs.primaryEndpoints.queue
      CHUNK_TARGET_SIZE: chunkTargetSize
      TARGET_PAGES: targetPages
      FR_API_VERSION: documentIntelligenceApiVersion
      AZURE_FORM_RECOGNIZER_ENDPOINT: documentIntelligence.outputs.endpoint
      COSMOSDB_URL: cosmosDb.outputs.endpoint
      COSMOSDB_LOG_DATABASE_NAME: statusLogDatabaseName
      COSMOSDB_LOG_CONTAINER_NAME: statusLogContainerName
      PDF_SUBMIT_QUEUE: 'pdf-submit-queue'
      PDF_POLLING_QUEUE: 'pdf-polling-queue'
      NON_PDF_SUBMIT_QUEUE: 'non-pdf-submit-queue'
      MEDIA_SUBMIT_QUEUE: 'media-submit-queue'
      TEXT_ENRICHMENT_QUEUE: 'text-enrichment-queue'
      IMAGE_ENRICHMENT_QUEUE: 'image-enrichment-queue'
      MAX_SECONDS_HIDE_ON_UPLOAD: functionMaxSecondsHideOnUpload
      MAX_SUBMIT_REQUEUE_COUNT: maxSubmitRequeueCount
      POLL_QUEUE_SUBMIT_BACKOFF: pollQueueSubmitBackoff
      PDF_SUBMIT_QUEUE_BACKOFF: pdfSubmitQueueBackoff
      MAX_POLLING_REQUEUE_COUNT: maxPollingRequeueCount
      SUBMIT_REQUEUE_HIDE_SECONDS: submitRequeueHideSeconds
      POLLING_BACKOFF: pollingBackoff
      MAX_READ_ATTEMPTS: maxReadAttempts
      AZURE_AI_KEY: ''
      AZURE_AI_ENDPOINT: cognitiveServices.outputs.endpoint
      ENRICHMENT_NAME: cognitiveServices.outputs.name
      AZURE_AI_LOCATION: cognitiveServices.outputs.location
      TARGET_TRANSLATION_LANGUAGE: targetTranslationLanguage
      MAX_ENRICHMENT_REQUEUE_COUNT: maxEnrichmentRequeueCount
      ENRICHMENT_BACKOFF: enrichmentBackoff
      EMBEDDINGS_QUEUE: 'embeddings-queue'
      AZURE_SEARCH_SERVICE_ENDPOINT: searchService.outputs.endpoint
      AZURE_SEARCH_INDEX: searchIndexName
      AZURE_AI_CREDENTIAL_DOMAIN: 'cognitiveservices.azure.com'
      AZURE_OPENAI_AUTHORITY_HOST: azureEnvironment
      LOCAL_DEBUG: string(false)
    }
  }
}

module enrichmentServicePlan 'core/host/appserviceplan.bicep' = {
  name: 'enrichmentserviceplan'
  scope: mainResourceGroup
  params: {
    name: !empty(enrichmentServicePlanName)
      ? enrichmentServicePlanName
      : '${abbrs.webServerFarms}enrich-${resourceToken}'
    location: location
    tags: tags
    aseId: enrichmentServiceAseId
    sku: {
      name: enrichmentServiceSkuName
      capacity: 1
      tier: enrichmentServiceSkuTier
    }
    kind: 'linux'
  }
}

module enrichmentApp 'br/public:avm/res/web/site:0.15.1' = {
  name: 'enrichmentApp'
  scope: mainResourceGroup
  params: {
    // Required parameters
    kind: 'app,linux,container'
    tags: union(tags, { 'azd-service-name': 'enrichment' })
    name: !empty(enrichmentServiceName) ? enrichmentServiceName : '${abbrs.webSitesAppService}enrich-${resourceToken}'
    serverFarmResourceId: enrichmentServicePlan.outputs.id
    appInsightResourceId: useApplicationInsights ? monitoring.outputs.applicationInsightsId : ''
    managedIdentities: {
      systemAssigned: true
    }
    publicNetworkAccess: !empty(ipRules) ? 'Enabled' : publicNetworkAccess
    virtualNetworkSubnetId: empty(enrichmentServiceAseId) ? isolation.outputs.enrichIntSubnetId : null
    vnetImagePullEnabled: true
    vnetContentShareEnabled: true
    vnetRouteAllEnabled: true
    // Non-required parameters
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistry.outputs.loginServer}/enrichment:latest'
      ipSecurityRestrictions: map(ipRules, ipRule => {
        ipAddress: lastIndexOf(ipRule.?value, '/') == -1 ? '${ipRule.?value}/32' : ipRule.?value
        action: 'Allow'
      })
      ipSecurityRestrictionsDefaultAction: 'Deny'
      acrUseManagedIdentityCreds: true
    }
    appSettingsKeyValuePairs: {
      EMBEDDINGS_QUEUE: 'embeddings-queue'
      LOG_LEVEL: 'DEBUG'
      DEQUEUE_MESSAGE_BATCH_SIZE: 1
      AZURE_BLOB_STORAGE_ACCOUNT: storage.outputs.name
      AZURE_BLOB_STORAGE_CONTAINER: storageContainerName
      AZURE_BLOB_STORAGE_UPLOAD_CONTAINER: 'upload'
      AZURE_BLOB_STORAGE_ENDPOINT: storage.outputs.primaryEndpoints.blob
      AZURE_QUEUE_STORAGE_ENDPOINT: storage.outputs.primaryEndpoints.queue
      COSMOSDB_URL: cosmosDb.outputs.endpoint
      COSMOSDB_LOG_DATABASE_NAME: statusLogDatabaseName
      COSMOSDB_LOG_CONTAINER_NAME: statusLogContainerName
      MAX_EMBEDDING_REQUEUE_COUNT: 5
      EMBEDDING_REQUEUE_BACKOFF: 60
      AZURE_OPENAI_SERVICE: !deployAzureOpenAi ? existingOpenAi.name : openAi.outputs.name
      AZURE_OPENAI_ENDPOINT: !deployAzureOpenAi ? existingOpenAi.properties.endpoint : openAi.outputs.endpoint
      AZURE_OPENAI_EMBEDDING_DEPLOYMENT_NAME: embedding.deploymentName
      AZURE_SEARCH_INDEX: searchIndexName
      AZURE_SEARCH_SERVICE_ENDPOINT: searchService.outputs.endpoint
      AZURE_SEARCH_AUDIENCE: searchScope
      TARGET_EMBEDDINGS_MODEL: 'azure-openai_${embedding.deploymentName}'
      EMBEDDING_VECTOR_SIZE: embedding.dimensions
      AZURE_AI_CREDENTIAL_DOMAIN: 'cognitiveservices.azure.com'
      AZURE_OPENAI_AUTHORITY_HOST: azureEnvironment
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
    enrichServicePlanName: enrichmentServicePlan.outputs.name
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
    subnetEnrichIntName: useExistingVnet
      ? (!empty(existingEnrichIntSubnetName) ? existingEnrichIntSubnetName : subnetEnrichIntName)
      : subnetEnrichIntName
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
        resourceIds: [documentIntelligence.outputs.resourceId, cognitiveServices.outputs.resourceId]
      }
    ]
  : []

var websiteResourceIds = union(
  [],
  empty(appServicePlanAseId) && deploymentTarget == 'appservice' ? [webapp.outputs.id] : [],
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

// USER ROLES
var principalType = empty(runningOnGh) && empty(runningOnAdo) ? 'User' : 'ServicePrincipal'

var firstId = !deployAzureOpenAi && !empty(existingOpenAi.identity.?userAssignedIdentities)
  ? first(objectKeys(existingOpenAi.identity.userAssignedIdentities))
  : ''
var existingOpenAiUserIdentityPrincipalId = !deployAzureOpenAi && !empty(firstId)
  ? existingOpenAi.identity.userAssignedIdentities[firstId!].principalId
  : ''
var existingOpenAiManagedIdentityPrincipalId = (!deployAzureOpenAi && !empty(existingOpenAi.identity.?principalId)
  ? existingOpenAi.identity.principalId
  : existingOpenAiUserIdentityPrincipalId)

module openAiRoleUser 'core/security/role.bicep' = if (isAzureOpenAiHost && assignRoles && !empty(principalId)) {
  scope: openAiResourceGroup
  name: 'openai-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: roles.CognitiveServicesOpenAIUser
    principalType: principalType
  }
}

// For both document intelligence and computer vision
module cognitiveServicesRoleUser 'core/security/role.bicep' = if (assignRoles && !empty(principalId)) {
  scope: mainResourceGroup
  name: 'cognitiveservices-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: roles.CognitiveServicesUser
    principalType: principalType
  }
}

module storageRoleUser 'core/security/role.bicep' = if (assignRoles && !empty(principalId)) {
  scope: storageResourceGroup
  name: 'storage-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: roles.StorageBlobDataReader
    principalType: principalType
  }
}

module storageContribRoleUser 'core/security/role.bicep' = if (assignRoles && !empty(principalId)) {
  scope: storageResourceGroup
  name: 'storage-contrib-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    principalType: principalType
  }
}

module storageOwnerRoleUser 'core/security/role.bicep' = if (assignRoles && !empty(principalId)) {
  scope: storageResourceGroup
  name: 'storage-owner-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: roles.StorageBlobDataOwner
    principalType: principalType
  }
}

module searchRoleUser 'core/security/role.bicep' = if (assignRoles && !empty(principalId)) {
  scope: searchServiceResourceGroup
  name: 'search-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: roles.SearchIndexDataReader
    principalType: principalType
  }
}

module searchContribRoleUser 'core/security/role.bicep' = if (assignRoles && !empty(principalId)) {
  scope: searchServiceResourceGroup
  name: 'search-contrib-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: roles.SearchIndexDataContributor
    principalType: principalType
  }
}

module searchSvcContribRoleUser 'core/security/role.bicep' = if (assignRoles && !empty(principalId)) {
  scope: searchServiceResourceGroup
  name: 'search-svccontrib-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: roles.SearchServiceContributor
    principalType: principalType
  }
}

module cosmosDbAccountContribRoleUser 'core/security/role.bicep' = if (assignRoles && !empty(principalId)) {
  scope: cosmosDbResourceGroup
  name: 'cosmosdb-account-contrib-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: roles.DocumentDBAccountContributor
    principalType: principalType
  }
}

// RBAC for Cosmos DB
// https://learn.microsoft.com/azure/cosmos-db/nosql/security/how-to-grant-data-plane-role-based-access
module cosmosDbDataContribRoleUser 'core/security/documentdb-sql-role.bicep' = if (assignRoles && !empty(principalId)) {
  scope: cosmosDbResourceGroup
  name: 'cosmosdb-data-contrib-role-user'
  params: {
    databaseAccountName: cosmosDb.outputs.name
    principalId: principalId
    // Cosmos DB Built-in Data Contributor role
    roleDefinitionId: '/${subscription().id}/resourceGroups/${cosmosDb.outputs.resourceGroupName}/providers/Microsoft.DocumentDB/databaseAccounts/${cosmosDb.outputs.name}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002'
  }
}

module queueDataReaderRoleUser 'core/security/role.bicep' = if (assignRoles && !empty(principalId)) {
  scope: cosmosDbResourceGroup
  name: 'queue-data-reader-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: roles.StorageQueueDataReader
    principalType: principalType
  }
}

module queueDataContribRoleUser 'core/security/role.bicep' = if (assignRoles && !empty(principalId)) {
  scope: cosmosDbResourceGroup
  name: 'queue-data-contrib-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: roles.StorageQueueDataContributor
    principalType: principalType
  }
}

module queueDataMessageProcRoleUser 'core/security/role.bicep' = if (assignRoles && !empty(principalId)) {
  scope: cosmosDbResourceGroup
  name: 'queue-data-message-proc-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: roles.StorageQueueDataMessageProcessor
    principalType: principalType
  }
}

module queueDataMessageSenderRoleUser 'core/security/role.bicep' = if (assignRoles && !empty(principalId)) {
  scope: cosmosDbResourceGroup
  name: 'queue-data-message-sender-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: roles.StorageQueueDataMessageSender
    principalType: principalType
  }
}

// SYSTEM IDENTITIES
module openAiRoleBackend 'core/security/role.bicep' = if (isAzureOpenAiHost && assignRoles) {
  scope: openAiResourceGroup
  name: 'openai-role-backend'
  params: {
    principalId: (deploymentTarget == 'appservice') ? webapp.outputs.identityPrincipalId : ''
    roleDefinitionId: roles.CognitiveServicesOpenAIUser
    principalType: 'ServicePrincipal'
  }
}

module openAiRoleFunction 'core/security/role.bicep' = if (isAzureOpenAiHost && assignRoles) {
  scope: openAiResourceGroup
  name: 'openai-role-function'
  params: {
    principalId: function.outputs.?systemAssignedMIPrincipalId
    roleDefinitionId: roles.CognitiveServicesOpenAIUser
    principalType: 'ServicePrincipal'
  }
}

module openAiRoleSearchService 'core/security/role.bicep' = if (isAzureOpenAiHost && assignRoles) {
  scope: openAiResourceGroup
  name: 'openai-role-searchservice'
  params: {
    principalId: searchService.outputs.principalId
    roleDefinitionId: roles.CognitiveServicesOpenAIUser
    principalType: 'ServicePrincipal'
  }
}

module storageRoleBackend 'core/security/role.bicep' = if (assignRoles) {
  scope: storageResourceGroup
  name: 'storage-role-backend'
  params: {
    principalId: (deploymentTarget == 'appservice') ? webapp.outputs.identityPrincipalId : ''
    roleDefinitionId: roles.StorageBlobDataReader
    principalType: 'ServicePrincipal'
  }
}

module storageContribRoleBackend 'core/security/role.bicep' = if (assignRoles) {
  scope: storageResourceGroup
  name: 'storage-contrib-role-backend'
  params: {
    principalId: (deploymentTarget == 'appservice') ? webapp.outputs.identityPrincipalId : ''
    roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    principalType: 'ServicePrincipal'
  }
}

module storageContribRoleDiag 'core/security/role.bicep' = if (assignRoles) {
  scope: storageResourceGroup
  name: 'storage-contrib-role-diag'
  params: {
    principalId: '47a8880e-8e60-4153-9e25-fa98482bae5d'
    roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    principalType: 'ServicePrincipal'
  }
}

module storageRoleFunction 'core/security/role.bicep' = if (assignRoles) {
  scope: storageResourceGroup
  name: 'storage-blob-reader-role-function'
  params: {
    principalId: function.outputs.systemAssignedMIPrincipalId
    roleDefinitionId: roles.StorageBlobDataReader
    principalType: 'ServicePrincipal'
  }
}

module storageContribRoleFunction 'core/security/role.bicep' = if (assignRoles) {
  scope: storageResourceGroup
  name: 'storage-blob-contrib-role-function'
  params: {
    principalId: function.outputs.systemAssignedMIPrincipalId
    roleDefinitionId: roles.StorageBlobDataContributor
    principalType: 'ServicePrincipal'
  }
}

module storageAccountContributorRoleFunction 'core/security/role.bicep' = if (assignRoles) {
  scope: storageResourceGroup
  name: 'storage-acc-contrib-role-function'
  params: {
    principalId: function.outputs.systemAssignedMIPrincipalId
    roleDefinitionId: roles.StorageAccountContributor
    principalType: 'ServicePrincipal'
  }
}

module storageQueueContributorRoleFunction 'core/security/role.bicep' = if (assignRoles) {
  scope: storageResourceGroup
  name: 'storage-queue-contrib-role-function'
  params: {
    principalId: function.outputs.systemAssignedMIPrincipalId
    roleDefinitionId: roles.StorageQueueDataContributor
    principalType: 'ServicePrincipal'
  }
}

module storageQueueDataReaderRoleFunction 'core/security/role.bicep' = if (assignRoles) {
  scope: storageResourceGroup
  name: 'storage-queue-data-reader-role-function'
  params: {
    principalId: function.outputs.systemAssignedMIPrincipalId
    roleDefinitionId: roles.StorageQueueDataReader
    principalType: 'ServicePrincipal'
  }
}

module storageQueueMessageProcRoleFunction 'core/security/role.bicep' = if (assignRoles) {
  scope: storageResourceGroup
  name: 'storage-queue-message-proc-role-function'
  params: {
    principalId: function.outputs.systemAssignedMIPrincipalId
    roleDefinitionId: roles.StorageQueueDataMessageProcessor
    principalType: 'ServicePrincipal'
  }
}

module storageQueueMessageSenderRoleFunction 'core/security/role.bicep' = if (assignRoles) {
  scope: storageResourceGroup
  name: 'storage-queue-message-sender-role-function'
  params: {
    principalId: function.outputs.systemAssignedMIPrincipalId
    roleDefinitionId: roles.StorageQueueDataMessageSender
    principalType: 'ServicePrincipal'
  }
}

module storageQueueMessageSenderRoleBackend 'core/security/role.bicep' = if (assignRoles) {
  scope: storageResourceGroup
  name: 'storage-queue-message-sender-role-backend'
  params: {
    principalId: (deploymentTarget == 'appservice') ? webapp.outputs.identityPrincipalId : ''
    roleDefinitionId: roles.StorageQueueDataMessageSender
    principalType: 'ServicePrincipal'
  }
}

module containerRegistryRoleFunction 'core/security/role.bicep' = if (assignRoles) {
  scope: mainResourceGroup
  name: 'container-registry-role-function'
  params: {
    principalId: function.outputs.systemAssignedMIPrincipalId
    roleDefinitionId: roles.AcrPull
    principalType: 'ServicePrincipal'
  }
}

module containerRegistryRoleBackend 'core/security/role.bicep' = if (assignRoles) {
  scope: mainResourceGroup
  name: 'container-registry-role-backend'
  params: {
    principalId: webapp.outputs.identityPrincipalId
    roleDefinitionId: roles.AcrPull
    principalType: 'ServicePrincipal'
  }
}

module storageOwnerRoleBackend 'core/security/role.bicep' = if (assignRoles) {
  scope: storageResourceGroup
  name: 'storage-owner-role-backend'
  params: {
    principalId: (deploymentTarget == 'appservice') ? webapp.outputs.identityPrincipalId : ''
    roleDefinitionId: roles.StorageBlobDataOwner
    principalType: 'ServicePrincipal'
  }
}

module storageOwnerRoleFunction 'core/security/role.bicep' = if (assignRoles) {
  scope: storageResourceGroup
  name: 'storage-owner-role-function'
  params: {
    principalId: function.outputs.systemAssignedMIPrincipalId
    roleDefinitionId: roles.StorageBlobDataOwner
    principalType: 'ServicePrincipal'
  }
}

module storageRoleSearchService 'core/security/role.bicep' = if (assignRoles) {
  scope: storageResourceGroup
  name: 'storage-role-searchservice'
  params: {
    principalId: searchService.outputs.principalId
    roleDefinitionId: roles.StorageBlobDataReader
    principalType: 'ServicePrincipal'
  }
}

// Used to issue search queries
// https://learn.microsoft.com/azure/search/search-security-rbac
module searchRoleBackend 'core/security/role.bicep' = if (assignRoles) {
  scope: searchServiceResourceGroup
  name: 'search-role-backend'
  params: {
    principalId: (deploymentTarget == 'appservice') ? webapp.outputs.identityPrincipalId : ''
    roleDefinitionId: roles.SearchIndexDataReader
    principalType: 'ServicePrincipal'
  }
}

module searchRoleFunction 'core/security/role.bicep' = if (assignRoles) {
  scope: searchServiceResourceGroup
  name: 'search-role-function'
  params: {
    principalId: function.outputs.systemAssignedMIPrincipalId
    roleDefinitionId: roles.SearchIndexDataReader
    principalType: 'ServicePrincipal'
  }
}

module searchSvcContribRoleFunction 'core/security/role.bicep' = if (assignRoles) {
  scope: searchServiceResourceGroup
  name: 'search-svccontrib-role-function'
  params: {
    principalId: function.outputs.systemAssignedMIPrincipalId
    roleDefinitionId: roles.SearchServiceContributor
    principalType: 'ServicePrincipal'
  }
}

// RBAC for Cosmos DB
// https://learn.microsoft.com/azure/cosmos-db/nosql/security/how-to-grant-data-plane-role-based-access
module cosmosDbRoleBackend 'core/security/documentdb-sql-role.bicep' = if (assignRoles) {
  scope: cosmosDbResourceGroup
  name: 'cosmosdb-role-backend'
  params: {
    databaseAccountName: cosmosDb.outputs.name
    principalId: (deploymentTarget == 'appservice') ? webapp.outputs.identityPrincipalId : ''
    // Cosmos DB Built-in Data Contributor role
    roleDefinitionId: '/${subscription().id}/resourceGroups/${cosmosDb.outputs.resourceGroupName}/providers/Microsoft.DocumentDB/databaseAccounts/${cosmosDb.outputs.name}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002'
  }
}

module cosmosDbRoleFunction 'core/security/documentdb-sql-role.bicep' = if (assignRoles) {
  scope: cosmosDbResourceGroup
  name: 'cosmosdb-role-function'
  params: {
    databaseAccountName: cosmosDb.outputs.name
    principalId: function.outputs.systemAssignedMIPrincipalId
    // Cosmos DB Built-in Data Contributor role
    roleDefinitionId: '/${subscription().id}/resourceGroups/${cosmosDb.outputs.resourceGroupName}/providers/Microsoft.DocumentDB/databaseAccounts/${cosmosDb.outputs.name}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002'
  }
}

module cosmosDbRoleOpenAi 'core/security/documentdb-sql-role.bicep' = if (isAzureOpenAiHost && assignRoles) {
  scope: cosmosDbResourceGroup
  name: 'cosmosdb-role-openai'
  params: {
    databaseAccountName: cosmosDb.outputs.name
    principalId: deployAzureOpenAi
      ? openAi.outputs.systemAssignedMIPrincipalId
      : existingOpenAiManagedIdentityPrincipalId
    // Cosmos DB Built-in Data Contributor role
    roleDefinitionId: '/${subscription().id}/resourceGroups/${cosmosDb.outputs.resourceGroupName}/providers/Microsoft.DocumentDB/databaseAccounts/${cosmosDb.outputs.name}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002'
  }
}

module cosmosDbReaderRoleSearch 'core/security/documentdb-sql-role.bicep' = if (assignRoles) {
  scope: cosmosDbResourceGroup
  name: 'cosmosdb-reader-role-search'
  params: {
    databaseAccountName: cosmosDb.outputs.name
    principalId: searchService.outputs.principalId
    // Cosmos DB Built-in Data Reader role
    roleDefinitionId: '/${subscription().id}/resourceGroups/${cosmosDb.outputs.resourceGroupName}/providers/Microsoft.DocumentDB/databaseAccounts/${cosmosDb.outputs.name}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000001'
  }
}

module cosmosDbRoleSearch 'core/security/documentdb-sql-role.bicep' = if (assignRoles) {
  scope: cosmosDbResourceGroup
  name: 'cosmosdb-role-search'
  params: {
    databaseAccountName: cosmosDb.outputs.name
    principalId: searchService.outputs.principalId
    // Cosmos DB Built-in Data Contributor role
    roleDefinitionId: '/${subscription().id}/resourceGroups/${cosmosDb.outputs.resourceGroupName}/providers/Microsoft.DocumentDB/databaseAccounts/${cosmosDb.outputs.name}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002'
  }
}

module cosmosAccountReaderRoleSearch 'core/security/role.bicep' = if (assignRoles) {
  scope: searchServiceResourceGroup
  name: 'cosmos-acc-reader-role-search'
  params: {
    principalId: searchService.outputs.principalId
    roleDefinitionId: roles.CosmosDBAccountReaderRole
    principalType: 'ServicePrincipal'
  }
}

// Used to read index definitions (required when using authentication)
// https://learn.microsoft.com/azure/search/search-security-rbac
module searchReaderRoleBackend 'core/security/role.bicep' = if (useAuthentication && assignRoles) {
  scope: searchServiceResourceGroup
  name: 'search-reader-role-backend'
  params: {
    principalId: (deploymentTarget == 'appservice') ? webapp.outputs.identityPrincipalId : ''
    roleDefinitionId: roles.Reader
    principalType: 'ServicePrincipal'
  }
}

// Used to add/remove documents from index (required for user upload feature)
module searchContribRoleBackend 'core/security/role.bicep' = if (assignRoles) {
  scope: searchServiceResourceGroup
  name: 'search-contrib-role-backend'
  params: {
    principalId: (deploymentTarget == 'appservice') ? webapp.outputs.identityPrincipalId : ''
    roleDefinitionId: roles.SearchIndexDataContributor
    principalType: 'ServicePrincipal'
  }
}

module searchContribRoleOpenAi 'core/security/role.bicep' = if (isAzureOpenAiHost && assignRoles) {
  scope: searchServiceResourceGroup
  name: 'search-contrib-role-openai'
  params: {
    principalId: deployAzureOpenAi
      ? openAi.outputs.systemAssignedMIPrincipalId
      : existingOpenAiManagedIdentityPrincipalId
    roleDefinitionId: roles.SearchIndexDataContributor
    principalType: 'ServicePrincipal'
  }
}

output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenantId
output AZURE_AUTH_TENANT_ID string = authTenantId
output AZURE_RESOURCE_GROUP string = mainResourceGroup.name

// Shared by all OpenAI deployments
output OPENAI_HOST string = openAiHost
output AZURE_OPENAI_EMB_MODEL_NAME string = embedding.modelName
output AZURE_OPENAI_CHATGPT_MODEL string = chatGpt.modelName

// Specific to Azure OpenAI
output AZURE_OPENAI_SERVICE string = isAzureOpenAiHost
  ? (deployAzureOpenAi ? openAi.outputs.name : existingOpenAi.name)
  : ''
output AZURE_OPENAI_API_VERSION string = isAzureOpenAiHost ? azureOpenAiApiVersion : ''
output AZURE_OPENAI_RESOURCE_GROUP string = isAzureOpenAiHost ? openAiResourceGroup.name : ''
output AZURE_OPENAI_CHATGPT_DEPLOYMENT string = isAzureOpenAiHost ? chatGpt.deploymentName : ''
output AZURE_OPENAI_EMB_DEPLOYMENT string = isAzureOpenAiHost ? embedding.deploymentName : ''

output AZURE_SEARCH_INDEX string = searchIndexName
output AZURE_SEARCH_INDEXER string = searchIndexerName
output AZURE_SEARCH_SERVICE string = searchService.outputs.name
output AZURE_SEARCH_SERVICE_ENDPOINT string = searchService.outputs.endpoint
output AZURE_SEARCH_SERVICE_RESOURCE_GROUP string = searchServiceResourceGroup.name
output AZURE_SEARCH_SEMANTIC_RANKER string = actualSearchServiceSemanticRankerLevel
output AZURE_SEARCH_SERVICE_ASSIGNED_USERID string = searchService.outputs.principalId

output AZURE_COSMOSDB_ACCOUNT string = cosmosDb.outputs.name
output AZURE_COSMOSDB_RESOURCE_GROUP string = cosmosDbResourceGroup.name
output AZURE_CHAT_HISTORY_DATABASE string = chatHistoryDatabaseName
output AZURE_CHAT_HISTORY_CONTAINER string = chatHistoryContainerName
output AZURE_CHAT_HISTORY_VERSION string = chatHistoryVersion
output AZURE_STATUS_LOG_DATABASE string = statusLogDatabaseName
output AZURE_STATUS_LOG_CONTAINER string = statusLogContainerName
output AZURE_STATUS_LOG_VERSION string = statusLogVersion
output AZURE_VIDEO_ANALYSIS_DATABASE string = videoMetadataDatabaseName
output AZURE_VIDEO_ANALYSIS_CONTAINER string = videoMetadataContainerName
output AZURE_VIDEO_PROCESSING_DATABASE string = videoProcessingDatabaseName
output AZURE_VIDEO_PROCESSING_CONTAINER string = videoProcessingContainerName
output AZURE_VIDEO_ANALYSIS_VERSION string = videoAnalysisVersion

output AZURE_STORAGE_ACCOUNT string = storage.outputs.name
output AZURE_STORAGE_CONTAINER string = storageContainerName
output AZURE_STORAGE_RESOURCE_GROUP string = storageResourceGroup.name

output AZURE_USE_AUTHENTICATION bool = useAuthentication
output AZURE_USE_USER_UPLOAD bool = useUserUpload

output BACKEND_URI string = deploymentTarget == 'appservice' ? webapp.outputs.uri : ''
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerRegistry.outputs.loginServer
output AZURE_CONTAINER_REGISTRY_NAME string = containerRegistry.outputs.name

output AZURE_WEBAPP_SERVICE_NAME string = deploymentTarget == 'appservice' ? webapp.outputs.name : ''
output AZURE_FUNCTION_SERVICE_NAME string = function.outputs.name
