import * as shared from '../configuration/shared/shared.conf.bicep'
import * as type from '../configuration/shared/shared.types.bicep'

targetScope = 'managementGroup'

metadata name = 'ALZ Bicep - Subscription Vending Orchestration'
metadata description = 'Orchestration used to create a new Azure Subscription and/or parse in an existing subscription.'
metadata version = '2.0.0'
metadata author = 'Insight APAC Platform Engineering'

// Subscription Creation Module Parameters
@description ('Whether to create a new Azure Subscription using the subscriptionCreation module. If false, then supply the existingSubscriptionId parameter instead to deploy resources to an existing subscription.')
param subscriptionAliasEnabled bool = false

@maxLength(63)
@description('The name of the subscription alias. The string must be comprised of a-z, A-Z, 0-9, - and _. The maximum length is 63 characters.')
param subscriptionDisplayName string = ''

@maxLength(63)
@description('The name of the Subscription Alias, that will be created by this module.')
param subscriptionAliasName string = ''

@description('The Billing Scope for the new Subscription alias, that will be created by this module.')
param subscriptionBillingScope string = ''

@allowed([
  'DevTest'
  'Production'
])
@description('The workload type can be either `Production` or `DevTest` and is case sensitive.')
param subscriptionWorkload string = 'Production'

@maxLength(36)
@description('The Microsoft Entra Tenant ID (GUID) to which the Subscription should be attached to.')
param subscriptionTenantId string = ''

@maxLength(36)
@description('The Azure Active Directory principals object ID (GUID) to whom should be the Subscription Owner.')
param subscriptionOwnerId string = ''

// Subscription Wrapper Module Parameters
@maxLength(36)
@description('An existing subscription ID. Use this when you do not want the module to create a new subscription. But do want to manage the management group membership. A subscription ID should be provided in the example format `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`')
param existingSubscriptionId string = ''

@description('Whether to move the Subscription to the specified Management Group supplied in the parameter `subscriptionManagementGroupId`')
param subscriptionManagementGroupAssociationEnabled bool = true

@description('The destination Management Group ID for the new Subscription that will be created by this module (or the existing one provided in the parameter `existingSubscriptionId`')
param subscriptionMgPlacement string = ''

@description('The Azure Region to deploy the Landing Zone into.')
param location string = deployment().location

@maxLength(10)
@description('Specifies the Landing Zone prefix for the deployment and Azure resources. This is the function of the Landing Zone AIS, SAP, AVD etc.')
param lzPrefix string

@allowed([
  'dev'
  'tst'
  'prd'
  'sbx'
])
@description('Specifies the environment prefix for the deployment.')
param envPrefix string

@description('Optional. Boolean to use custom naming for resources.')
param useCustomNaming bool = false

@description('An object of Tag key & value pairs to be appended to a Subscription.')
param tags type.tagsType

// Spoke Networking Module Parameters
@description('Whether to create a virtual network or not.')
param virtualNetworkEnabled bool = true

@description('The address space of the Virtual Network that will be created by this module, supplied as multiple CIDR blocks in an array, e.g. `["10.0.0.0/16","172.16.0.0/12"]`')
param addressPrefixes string = ''

@description('IP Address of the centralised firewall that will be used as the next hop address.')
param nextHopIpAddress string = ''

@description('Specifies the Subnets array - name, address space, configuration.')
param subnets type.subnetType

@description('Array of DNS Server IP addresses for the VNet.')
param dnsServerIps array = []

@description('Switch which allows BGP Propagation to be disabled on the route tables.')
param disableBgpRoutePropagation bool = true

@description('ResourceId of the DdosProtectionPlan which will be applied to the Virtual Network.')
param ddosProtectionPlanId string = ''

// Virtual Networking Peering & vWAN Modules Parameters
@description('Whether to enable peering/connection with the supplied hub Virtual Network or Virtual WAN Virtual Hub.')
param virtualNetworkPeeringEnabled bool = true

@description('The resource ID of the Virtual Network or Virtual WAN Hub in the hub to which the created Virtual Network, by this module, will be peered/connected to via Virtual Network Peering or a Virtual WAN Virtual Hub Connection.')
param hubVirtualNetworkResourceId string = ''

@description('Switch to enable/disable forwarded Traffic from outside spoke network.')
param allowSpokeForwardedTraffic bool = true

@description('Switch to enable/disable VPN Gateway for the hub network peering.')
param allowHubVpnGatewayTransit bool = true

@description('Enables the ability for the Virtual WAN Hub Connection to learn the default route 0.0.0.0/0 from the Hub.')
param virtualNetworkVwanEnableInternetSecurity bool = true

@description('The resource ID of the virtual hub route table to associate to the virtual hub connection (this virtual network). If left blank/empty the `defaultRouteTable` will be associated.')
param virtualNetworkVwanAssociatedRouteTableResourceId string = ''

@description('An array of of objects of virtual hub route table resource IDs to propagate routes to. If left blank/empty the `defaultRouteTable` will be propagated to only.')
param virtualNetworkVwanPropagatedRouteTablesResourceIds array = []

@description('An array of virtual hub route table labels to propagate routes to. If left blank/empty the default label will be propagated to only.')
param virtualNetworkVwanPropagatedLabels array = []

@description('Indicates whether routing intent is enabled on the Virtual Hub within the Virtual WAN.')
param vHubRoutingIntentEnabled bool = false

// Role Assignment Modules Parameters
@description('Whether to create role assignments or not. If true, supply the array of role assignment objects in the parameter called `roleAssignments`.')
param roleAssignmentEnabled bool = true

@description('Whether to create Microsoft Entra Privileged role assignments or not. If true, supply the array of role assignment objects in the parameter called `roleAssignments`.')
param privilegedRoleAssignmentEnabled bool = false

@description('Supply an array of objects containing the details of the role assignments to create.')
param roleAssignments type.roleAssignmentType

@description('Supply an array of objects containing the details of the Microsoft Entra Privileged role assignments to create.')
param privilegedRoleAssignments array = []

@description('Specifies an array of email addresses for the Landing Zone action group.')
param actionGroupEmails array = []

@description('Specifies an array of budget configuration for the Landing Zone.')
param budgets type.budgetsType

// Orchestration Variables
var existingSubscriptionIDEmptyCheck = empty(existingSubscriptionId) ? 'No Subscription Id Provided' : existingSubscriptionId

// Module: Subscription Creation
module subscriptionCreation '../modules/subscriptionCreation/subscriptionCreation.bicep' = if (subscriptionAliasEnabled && empty(existingSubscriptionId)) {
  scope: tenant()
  name: take('subscriptionCreation-${guid(deployment().name)}', 64)
  params: {
    subscriptionBillingScope: subscriptionBillingScope
    subscriptionAliasName: subscriptionAliasName
    subscriptionDisplayName: subscriptionDisplayName
    subscriptionWorkload: subscriptionWorkload
    subscriptionTenantId: subscriptionTenantId
    subscriptionOwnerId: subscriptionOwnerId
  }
}

// Module: Subscription Wrapper
module subscriptionWrapper '../modules/subscriptionWrapper/subscriptionWrapper.bicep' = if ((subscriptionAliasEnabled || !empty(existingSubscriptionId)) && virtualNetworkEnabled) {
  name: take('subscriptionWrapper-${guid(deployment().name)}', 64)
  params: {
    location: location
    subscriptionId: (subscriptionAliasEnabled && empty(existingSubscriptionId)) ? subscriptionCreation.outputs.subscriptionId : existingSubscriptionId
    subscriptionManagementGroupAssociationEnabled: subscriptionManagementGroupAssociationEnabled
    subscriptionMgPlacement: subscriptionMgPlacement
    tags: tags
    lzPrefix: lzPrefix
    envPrefix: envPrefix
    virtualNetworkEnabled: virtualNetworkEnabled
    addressPrefixes: addressPrefixes
    nextHopIpAddress: nextHopIpAddress
    subnets: subnets
    dnsServerIps: dnsServerIps
    useCustomNaming: useCustomNaming
    disableBgpRoutePropagation: disableBgpRoutePropagation
    ddosProtectionPlanId: ddosProtectionPlanId
    virtualNetworkPeeringEnabled: virtualNetworkPeeringEnabled
    hubVirtualNetworkResourceId: hubVirtualNetworkResourceId
    allowSpokeForwardedTraffic: allowSpokeForwardedTraffic
    virtualNetworkVwanEnableInternetSecurity: virtualNetworkVwanEnableInternetSecurity
    virtualNetworkVwanAssociatedRouteTableResourceId: virtualNetworkVwanAssociatedRouteTableResourceId
    virtualNetworkVwanPropagatedRouteTablesResourceIds: virtualNetworkVwanPropagatedRouteTablesResourceIds
    virtualNetworkVwanPropagatedLabels: virtualNetworkVwanPropagatedLabels
    vHubRoutingIntentEnabled: vHubRoutingIntentEnabled
    allowHubVpnGatewayTransit: allowHubVpnGatewayTransit
    roleAssignmentEnabled: roleAssignmentEnabled
    privilegedRoleAssignmentEnabled: privilegedRoleAssignmentEnabled
    roleAssignments: roleAssignments
    privilegedRoleAssignments: privilegedRoleAssignments
    actionGroupEmails: actionGroupEmails
    budgets: budgets
  }
}

// Output
@description('The subscription Id that has either been created or provided.')
output subscriptionId string = (subscriptionAliasEnabled && empty(existingSubscriptionId)) ? subscriptionCreation.outputs.subscriptionId : contains(existingSubscriptionIDEmptyCheck, 'No Subscription Id Provided') ? existingSubscriptionIDEmptyCheck : '${existingSubscriptionId}'

@description('The subscription Resource Id that has been created or provided.')
output subscriptionResourceId string = (subscriptionAliasEnabled && empty(existingSubscriptionId)) ? subscriptionCreation.outputs.subscriptionResourceId : contains(existingSubscriptionIDEmptyCheck, 'No Subscription Id Provided') ? existingSubscriptionIDEmptyCheck : '/subscriptions/${existingSubscriptionId}'

@description('The Subscription Owner State. Only used when creating MCA Subscriptions across tenants')
output subscriptionAcceptOwnershipState string = (subscriptionAliasEnabled && empty(existingSubscriptionId) && !empty(subscriptionTenantId) && !empty(subscriptionOwnerId)) ? subscriptionCreation.outputs.subscriptionAcceptOwnershipState : 'N/A'

@description('The Subscription Ownership URL. Only used when creating MCA Subscriptions across tenants')
output subscriptionAcceptOwnershipUrl string = (subscriptionAliasEnabled && empty(existingSubscriptionId) && !empty(subscriptionTenantId) && !empty(subscriptionOwnerId)) ? subscriptionCreation.outputs.subscriptionAcceptOwnershipUrl : 'N/A'
