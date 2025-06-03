// entra.bicep - converted from entra.tf and variables.tf
param randomString string
param requireWebsiteSecurityMembership bool = false
param azure_websites_domain string
param isInAutomation bool = false
param aadWebClientId string
param aadMgmtClientId string
param aadMgmtServicePrincipalId string
@secure()
param aadMgmtClientSecret string
param entraOwners string = '' // Comma-separated list of owner emails
@secure()
param serviceManagementReference string
param password_lifetime int

// Owners list logic
var principal_list = empty(entraOwners) ? [] : split(entraOwners, ',')
// NOTE: Bicep does not support data.azurerm_client_config.current directly. You must pass the current objectId as a parameter if needed.
param currentObjectId string // Pass the current user's objectId from the deployment context
var owner_ids = contains(principal_list, currentObjectId) ? principal_list : union(principal_list, [currentObjectId])

resource aad_web_app 'Microsoft.Graph/applications@1.0' = if (!isInAutomation) {
  displayName: 'infoasst_web_access_${randomString}'
  identifierUris: [ 'api://infoasst-${randomString}' ]
  owners: owner_ids
  signInAudience: 'AzureADMyOrg'
  web: {
    redirectUris: [ 'https://infoasst-web-${randomString}.${azure_websites_domain}/.auth/login/aad/callback' ]
    implicitGrantSettings: {
      enableAccessTokenIssuance: true
      enableIdTokenIssuance: true
    }
  }
  // service_management_reference is not a standard property in Bicep/Graph API
}

resource aad_web_sp 'Microsoft.Graph/servicePrincipals@1.0' = if (!isInAutomation) {
  appId: aad_web_app.appId
  appRoleAssignmentRequired: requireWebsiteSecurityMembership
  owners: owner_ids
}

resource aad_mgmt_app 'Microsoft.Graph/applications@1.0' = if (!isInAutomation) {
  displayName: 'infoasst_mgmt_access_${randomString}'
  owners: owner_ids
  signInAudience: 'AzureADMyOrg'
  // service_management_reference is not a standard property in Bicep/Graph API
}

resource aad_mgmt_sp 'Microsoft.Graph/servicePrincipals@1.0' = if (!isInAutomation) {
  appId: aad_mgmt_app.appId
  owners: owner_ids
}

output azure_ad_web_app_client_id string = isInAutomation ? aadWebClientId : aad_web_app.appId
output azure_ad_mgmt_app_client_id string = isInAutomation ? aadMgmtClientId : aad_mgmt_app.appId
output azure_ad_mgmt_sp_id string = isInAutomation ? aadMgmtServicePrincipalId : aad_mgmt_sp.id
