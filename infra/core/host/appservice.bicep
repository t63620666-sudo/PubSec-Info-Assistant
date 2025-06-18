metadata description = 'Creates an Azure App Service in an existing Azure App Service plan.'
param name string
param location string = resourceGroup().location
param tags object = {}

// Reference Properties
param applicationInsightsName string = ''
param appServicePlanId string
param keyVaultName string = ''
param managedIdentity bool = !empty(keyVaultName)
param virtualNetworkSubnetId string = ''
param isHostedInAse bool = false

// Runtime Properties
@allowed([
  'dotnet'
  'dotnetcore'
  'dotnet-isolated'
  'node'
  'python'
  'java'
  'powershell'
  'custom'
])
param runtimeName string = 'python'
param runtimeNameAndVersion string = '${runtimeName}|${runtimeVersion}'
param runtimeVersion string = '3.11'

// Microsoft.Web/sites Properties
@allowed([
  'app,linux'
  'app,linux,container'
])
param kind string = 'app,linux'

param imageName string = ''

// Microsoft.Web/sites/config
param allowedOrigins array = []
param additionalScopes array = []
param additionalAllowedAudiences array = []
param allowedApplications array = []
param alwaysOn bool = true
param appCommandLine string = ''
@secure()
param appSettings object = {}
param clientAffinityEnabled bool = false
param enableOryxBuild bool = contains(kind, 'linux')
param functionAppScaleLimit int = -1
param linuxFxVersion string = contains(kind, 'container')
  ? 'DOCKER|${!empty(imageName) ? imageName : 'mcr.microsoft.com/appsvc/python:latest'}'
  : runtimeNameAndVersion
param minimumElasticInstanceCount int = -1
param numberOfWorkers int = -1
param scmDoBuildDuringDeployment bool = false
param use32BitWorkerProcess bool = false
param ftpsState string = 'FtpsOnly'
param healthCheckPath string = ''
param clientAppId string = ''
param serverAppId string = ''
@secure()
param clientSecretSettingName string = ''
param authenticationIssuerUri string = ''
@allowed(['Enabled', 'Disabled'])
param publicNetworkAccess string = 'Enabled'
param enableUnauthenticatedAccess bool = false
param disableAppServicesAuthentication bool = false
param ipRules array = []

// .default must be the 1st scope for On-Behalf-Of-Flow combined consent to work properly
// Please see https://learn.microsoft.com/entra/identity-platform/v2-oauth2-on-behalf-of-flow#default-and-combined-consent
var requiredScopes = ['api://${serverAppId}/.default', 'openid', 'profile', 'email', 'offline_access']
var requiredAudiences = ['api://${serverAppId}']

resource appService 'Microsoft.Web/sites@2024-04-01' = {
  name: name
  location: location
  tags: tags
  kind: kind
  properties: {
    serverFarmId: appServicePlanId
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      alwaysOn: alwaysOn
      ftpsState: ftpsState
      appCommandLine: appCommandLine
      numberOfWorkers: numberOfWorkers != -1 ? numberOfWorkers : null
      minimumElasticInstanceCount: minimumElasticInstanceCount != -1 ? minimumElasticInstanceCount : null
      minTlsVersion: '1.2'
      acrUseManagedIdentityCreds: managedIdentity
      use32BitWorkerProcess: use32BitWorkerProcess
      functionAppScaleLimit: functionAppScaleLimit != -1 ? functionAppScaleLimit : null
      healthCheckPath: healthCheckPath
      cors: {
        allowedOrigins: allowedOrigins
      }
      ipSecurityRestrictions: map(ipRules, ipRule => {
        ipAddress: lastIndexOf(ipRule.?value, '/') == -1 ? '${ipRule.?value}/32' : ipRule.?value
        action: 'Allow'
      })
      ipSecurityRestrictionsDefaultAction: 'Deny'
    }
    clientAffinityEnabled: clientAffinityEnabled
    httpsOnly: true
    vnetImagePullEnabled: !empty(virtualNetworkSubnetId)
    vnetContentShareEnabled: !empty(virtualNetworkSubnetId)
    vnetRouteAllEnabled: !empty(virtualNetworkSubnetId)
    vnetBackupRestoreEnabled: !empty(virtualNetworkSubnetId)
    publicNetworkAccess: publicNetworkAccess
    virtualNetworkSubnetId: isHostedInAse ? null : (!empty(virtualNetworkSubnetId) ? virtualNetworkSubnetId : null)
  }
  identity: { type: managedIdentity ? 'SystemAssigned' : 'None' }

  resource configAppSettings 'config' = {
    name: 'appsettings'
    properties: union(
      appSettings,
      {
        SCM_DO_BUILD_DURING_DEPLOYMENT: string(scmDoBuildDuringDeployment)
        ENABLE_ORYX_BUILD: string(enableOryxBuild)
      },
      runtimeName == 'python' ? { PYTHON_ENABLE_GUNICORN_MULTIWORKERS: 'true' } : {},
      !empty(applicationInsightsName)
        ? { APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsights.properties.ConnectionString }
        : {},
      !empty(keyVaultName) ? { AZURE_KEY_VAULT_ENDPOINT: keyVault.properties.vaultUri } : {}
    )
  }

  resource configLogs 'config' = {
    name: 'logs'
    properties: {
      applicationLogs: { fileSystem: { level: 'Verbose' } }
      detailedErrorMessages: { enabled: true }
      failedRequestsTracing: { enabled: true }
      httpLogs: { fileSystem: { enabled: true, retentionInDays: 1, retentionInMb: 35 } }
    }
    dependsOn: [
      configAppSettings
    ]
  }

  resource basicPublishingCredentialsPoliciesFtp 'basicPublishingCredentialsPolicies' = {
    name: 'ftp'
    properties: {
      allow: false
    }
  }

  resource basicPublishingCredentialsPoliciesScm 'basicPublishingCredentialsPolicies' = {
    name: 'scm'
    properties: {
      allow: false
    }
  }

  resource configAuth 'config' = if (!(empty(clientAppId)) && !disableAppServicesAuthentication) {
    name: 'authsettingsV2'
    properties: {
      globalValidation: {
        requireAuthentication: true
        unauthenticatedClientAction: enableUnauthenticatedAccess ? 'AllowAnonymous' : 'RedirectToLoginPage'
        redirectToProvider: 'azureactivedirectory'
      }
      identityProviders: {
        azureActiveDirectory: {
          enabled: true
          registration: {
            clientId: clientAppId
            clientSecretSettingName: clientSecretSettingName
            openIdIssuer: authenticationIssuerUri
          }
          login: {
            loginParameters: ['scope=${join(union(requiredScopes, additionalScopes), ' ')}']
          }
          validation: {
            allowedAudiences: union(requiredAudiences, additionalAllowedAudiences)
            defaultAuthorizationPolicy: {
              allowedApplications: allowedApplications
            }
          }
        }
      }
      login: {
        tokenStore: {
          enabled: true
        }
      }
      httpSettings: {
        forwardProxy: {
          convention: 'Standard'
        }
      }
    }
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = if (!(empty(keyVaultName))) {
  name: keyVaultName
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = if (!empty(applicationInsightsName)) {
  name: applicationInsightsName
}

output id string = appService.id
output identityPrincipalId string = managedIdentity ? appService.identity.principalId : ''
output name string = appService.name
output uri string = 'https://${appService.properties.defaultHostName}'
