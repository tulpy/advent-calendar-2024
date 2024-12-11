import * as shared from './shared/shared.conf.bicep'

using '../orchestration/main.bicep'

param existingSubscriptionId = 'a50d2a27-93d9-43b1-957c-2a663ffaf37f'
param subscriptionMgPlacement = 'mg-alz1-landingzones-corp'
param lzPrefix = 'sap'
param envPrefix = 'sbx'
param roleAssignmentEnabled = true
param roleAssignments = [
  {
    principalId: '2b33ff60-edf0-4216-b2a6-66ec07050fd4'
    roleDefinitionIdOrName: 'Reader'
    principalType: 'Group'
    subscriptionId: existingSubscriptionId
  }
  {
    principalId: '20bbeee1-e70c-43d3-8c2c-b66fefa31acf'
    roleDefinitionIdOrName: 'Owner'
    principalType: 'ServicePrincipal'
    subscriptionId: existingSubscriptionId
  }
]
param tags = {
  environment: envPrefix
  applicationName: 'SAP Landing Zone'
  owner: 'Platform Team'
  criticality: 'Tier2'
  costCenter: '1234'
  contactEmail: 'stephen.tulp@outlook.com'
  dataClassification: 'Internal'
  iac: 'Bicep'
}
param budgets = [
  {
    name: 'budget-forecasted'
    enabled: true
    startDate: '2025-01-01' // Ensure startDate is updated to the current date if budget is enabled YYYY-MM-DD
    amount: 500
    thresholdType: 'Forecasted'
    thresholds: [
      90
    ]
    contactEmails: [
      'test@outlook.com'
    ]
  }
  {
    name: 'budget-actual'
    enabled: true
    startDate: '2025-01-01' // Ensure startDate is updated to the current date if budget is enabled YYYY-MM-DD
    amount: 500
    thresholdType: 'Actual'
    thresholds: [
      95
      100
    ]
    contactEmails: [
      'test@outlook.com'
    ]
  }
]
param actionGroupEmails = [
  'test@outlook.com'
]
param hubVirtualNetworkResourceId = '/subscriptions/8f8224ca-1a9c-46d1-9206-1cf2a7c51de8/resourceGroups/arg-syd-plat-conn-network/providers/Microsoft.Network/virtualNetworks/vnt-syd-plat-conn-10.10.0.0_16'
param virtualNetworkPeeringEnabled = false
param allowHubVpnGatewayTransit = false
param nextHopIpAddress = '10.1.1.1'
param addressPrefixes = '10.15.0.0/24'
param subnets = [
  {
    name: 'app'
    addressPrefix: '10.15.0.0/27'
    networkSecurityGroupName: '${shared.resPrefixes.networkSecurityGroup}${shared.delimeters.dash}${shared.locPrefixes.australiaEast}${shared.delimeters.dash}${lzPrefix}${shared.delimeters.dash}${envPrefix}${shared.delimeters.dash}app'
    securityRules: []
    routeTableName: '${shared.resPrefixes.routeTable}${shared.delimeters.dash}${shared.locPrefixes.australiaEast}${shared.delimeters.dash}${lzPrefix}${shared.delimeters.dash}${envPrefix}-app'
    routes: []
    serviceEndpoints: []
    serviceEndpointPolicies: []
    delegation: ''
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  {
    name: 'db'
    addressPrefix: '10.15.0.32/27'
    networkSecurityGroupName: '${shared.resPrefixes.networkSecurityGroup}${shared.delimeters.dash}${shared.locPrefixes.australiaEast}${shared.delimeters.dash}${lzPrefix}${shared.delimeters.dash}${envPrefix}-db'
    securityRules: []
    routeTableName: '${shared.resPrefixes.routeTable}${shared.delimeters.dash}${shared.locPrefixes.australiaEast}${shared.delimeters.dash}${lzPrefix}${shared.delimeters.dash}${envPrefix}${shared.delimeters.dash}db'
    routes: []
    serviceEndpoints: []
    serviceEndpointPolicies: []
    delegation: ''
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
]
