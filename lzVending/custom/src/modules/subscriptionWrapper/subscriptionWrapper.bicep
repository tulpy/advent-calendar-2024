import * as shared from '../../configuration/shared/shared.conf.bicep'
import * as type from '../../configuration/shared/shared.types.bicep'

targetScope = 'managementGroup'

metadata name = 'ALZ Bicep - Subscription Wrapper Module'
metadata description = 'Module used to wrap the Azure Landing Zone deployment.'
metadata version = '1.0.2'
metadata author = 'Insight APAC Platform Engineering'

@description('Optional. The Azure Region to deploy the resources into.')
param location string = deployment().location

@description('Required. The Subscription Id for the deployment.')
@maxLength(36)
param subscriptionId string

@description('Optional. Whether to move the Subscription to the specified Management Group supplied in the parameter `subscriptionManagementGroupId`.')
param subscriptionManagementGroupAssociationEnabled bool = true

@description('Optional. The Management Group Id to place the subscription in.')
param subscriptionMgPlacement string = ''

@maxLength(10)
@description('Required. Specifies the Landing Zone prefix for the deployment and Azure resources. This is the function of the Landing Zone AIS, SAP, AVD etc.')
param lzPrefix string

@allowed([
  'dev'
  'tst'
  'prd'
  'sbx'
])
@description('Required. Specifies the environment prefix for the deployment.')
param envPrefix string

@description('Optional. Boolean to use custom naming for resources.')
param useCustomNaming bool = false

@description('An object of Tag key & value pairs to be appended to a Subscription.')
param tags type.tagsType

@description('Optional. Whether to create a virtual network or not.')
param virtualNetworkEnabled bool = true

@description('Optional. The address space of the Virtual Network that will be created by this module, supplied as multiple CIDR blocks in an array, e.g. `["10.0.0.0/16","172.16.0.0/12"]`.')
param addressPrefixes string = ''

@description('Optional. IP Address of the centralised firewall if used.')
param nextHopIpAddress string

@description('Specifies the Subnets array - name, address space, configuration.')
param subnets type.subnetType

@description('Optional. Array of DNS Server IP addresses for the Virtual Network.')
param dnsServerIps array = []

@description('Optional. Switch which allows BGP Propagation to be disabled on the route tables.')
param disableBgpRoutePropagation bool = true

@description('Optional. ResourceId of the DdosProtectionPlan which will be applied to the Virtual Network.')
param ddosProtectionPlanId string = ''

@description('Optional. Whether to enable peering/connection with the supplied hub Virtual Network or Virtual WAN Virtual Hub.')
param virtualNetworkPeeringEnabled bool = true

@description('Optional. The resource ID of the Virtual Network or Virtual WAN Hub in the hub to which the created Virtual Network, by this module, will be peered/connected to via Virtual Network Peering or a Virtual WAN Virtual Hub Connection.')
param hubVirtualNetworkResourceId string = ''

@description('Optional. Switch to enable/disable forwarded Traffic from outside spoke network.')
param allowSpokeForwardedTraffic bool = true

@description('Optional. Switch to enable/disable VPN Gateway Transit for the hub network peering.')
param allowHubVpnGatewayTransit bool = true

@description('Optional. Enables the ability for the Virtual WAN Hub Connection to learn the default route 0.0.0.0/0 from the Hub.')
param virtualNetworkVwanEnableInternetSecurity bool = true

@description('Optional. The resource ID of the virtual hub route table to associate to the virtual hub connection (this virtual network). If left blank/empty default route table will be associated.')
param virtualNetworkVwanAssociatedRouteTableResourceId string = ''

@description('Optinonal. An array of virtual hub route table resource IDs to propagate routes to. If left blank/empty default route table will be propagated to only.')
param virtualNetworkVwanPropagatedRouteTablesResourceIds array = []

@description('Optional. An array of virtual hub route table labels to propagate routes to. If left blank/empty default label will be propagated to only.')
param virtualNetworkVwanPropagatedLabels array = []

@description('Optional. Indicates whether routing intent is enabled on the Virtual HUB within the virtual WAN.')
param vHubRoutingIntentEnabled bool = true

@description('Optional. Whether to create role assignments or not. If true, supply the array of role assignment objects in the parameter called `roleAssignments`.')
param roleAssignmentEnabled bool = false

@description('Optional. Whether to create Microsoft Entra Privileged role assignments or not. If true, supply the array of role assignment objects in the parameter called `privilegedRoleAssignments`.')
param privilegedRoleAssignmentEnabled bool = false

@description('Supply an array of objects containing the details of the role assignments to create.')
param roleAssignments type.roleAssignmentType

@description('Optional. Supply an array of objects containing the details of the privileged role assignments to create.')
param privilegedRoleAssignments array = []

@description('Specifies an array of budget configuration for the Landing Zone.')
param budgets type.budgetsType

@description('Optional. Whether to create a Landing Zone Action Group or not.')
param actionGroupEnabled bool = true

@description('Optional. Specifies an array of email addresses for the Landing Zone action group.')
param actionGroupEmails array = []

// Variables
var argPrefix = toLower('${shared.resPrefixes.resourceGroup}${shared.delimeters.dash}${shared.locPrefixes[location]}${shared.delimeters.dash}${lzPrefix}${shared.delimeters.dash}${envPrefix}')
var vntPrefix = toLower('${shared.resPrefixes.virtualNetwork}${shared.delimeters.dash}${shared.locPrefixes[location]}${shared.delimeters.dash}${lzPrefix}${shared.delimeters.dash}${envPrefix}')
var vNetAddressSpace = replace(addressPrefixes, '/', '_')

// Check hubVirtualNetworkResourceId to see if it's a virtual WAN connection instead of normal virtual network peering
var virtualHubResourceIdChecked = (!empty(hubVirtualNetworkResourceId) && contains(
    hubVirtualNetworkResourceId,
    '/providers/Microsoft.Network/virtualHubs/'
  )
  ? hubVirtualNetworkResourceId
  : '')
var hubVirtualNetworkResourceIdChecked = (!empty(hubVirtualNetworkResourceId) && contains(
    hubVirtualNetworkResourceId,
    '/providers/Microsoft.Network/virtualNetworks/'
  )
  ? hubVirtualNetworkResourceId
  : '')

var hubVirtualNetworkName = (!empty(hubVirtualNetworkResourceId) && contains(
    hubVirtualNetworkResourceId,
    '/providers/Microsoft.Network/virtualNetworks/'
  )
  ? split(hubVirtualNetworkResourceId, '/')[8]
  : '')
var hubVirtualNetworkSubscriptionId = (!empty(hubVirtualNetworkResourceId) && contains(
    hubVirtualNetworkResourceId,
    '/providers/Microsoft.Network/virtualNetworks/'
  )
  ? split(hubVirtualNetworkResourceId, '/')[2]
  : '')
var hubVirtualNetworkResourceGroup = (!empty(hubVirtualNetworkResourceId) && contains(
    hubVirtualNetworkResourceId,
    '/providers/Microsoft.Network/virtualNetworks/'
  )
  ? split(hubVirtualNetworkResourceId, '/')[4]
  : '')

var virtualWanHubName = (!empty(virtualHubResourceIdChecked) ? split(virtualHubResourceIdChecked, '/')[8] : '')
var virtualWanHubSubscriptionId = (!empty(virtualHubResourceIdChecked) ? split(virtualHubResourceIdChecked, '/')[2] : '')
var virtualWanHubResourceGroupName = (!empty(virtualHubResourceIdChecked)
  ? split(virtualHubResourceIdChecked, '/')[4]
  : '')
var virtualWanHubConnectionAssociatedRouteTable = !empty(virtualNetworkVwanAssociatedRouteTableResourceId)
  ? virtualNetworkVwanAssociatedRouteTableResourceId
  : '${virtualHubResourceIdChecked}/hubRouteTables/defaultRouteTable'
var virutalWanHubDefaultRouteTableId = {
  id: '${virtualHubResourceIdChecked}/hubRouteTables/defaultRouteTable'
}
var virtualWanHubConnectionPropogatedRouteTables = !empty(virtualNetworkVwanPropagatedRouteTablesResourceIds)
  ? virtualNetworkVwanPropagatedRouteTablesResourceIds
  : array(virutalWanHubDefaultRouteTableId)
var virtualWanHubConnectionPropogatedLabels = !empty(virtualNetworkVwanPropagatedLabels)
  ? virtualNetworkVwanPropagatedLabels
  : ['default']

var resourceGroups = {
  network: useCustomNaming && !empty(shared.customNames.networkRg)
    ? shared.customNames.networkRg
    : '${argPrefix}${shared.delimeters.dash}network'
}

var resourceNames = {
  virtualNetwork: useCustomNaming && !empty(shared.customNames.virtualNetwork)
    ? shared.customNames.virtualNetwork
    : '${vntPrefix}${shared.delimeters.dash}${vNetAddressSpace}'
  actionGroup: useCustomNaming && !empty(shared.customNames.actionGroup)
    ? shared.customNames.actionGroup
    : '${lzPrefix}${envPrefix}ActionGroup'
  actionGroupShort: useCustomNaming && !empty(shared.customNames.actionGroupShort)
    ? shared.customNames.actionGroupShort
    : '${lzPrefix}${envPrefix}AG'
}

// Module: Subscription Placement
module subscriptionPlacement '../../modules/subscriptionPlacement/subscriptionPlacement.bicep' = if (subscriptionManagementGroupAssociationEnabled && !empty(subscriptionMgPlacement)) {
  scope: managementGroup(subscriptionMgPlacement)
  name: take('subscriptionPlacement-${guid(deployment().name)}', 64)
  params: {
    subscriptionIds: [
      subscriptionId
    ]
    targetManagementGroupId: subscriptionMgPlacement
  }
}

// Module: Subscription Tags
module subscriptionTags '../CARML/resources/tags/main.bicep' = if (!empty(tags)) {
  scope: subscription(subscriptionId)
  name: take('subTags-${guid(deployment().name)}', 64)
  params: {
    tags: tags
  }
}

// Module: Subscription Budget - https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/consumption/budget
module budget 'br/public:avm/res/consumption/budget:0.3.6' = [
  for (bg, index) in budgets: if (!empty(budgets) && bg.enabled) {
    name: take('subBudget-${guid(deployment().name)}-${index}', 64)
    scope: subscription(subscriptionId)
    params: {
      // Required parameters
      amount: bg.amount
      name: bg.name
      // Non-required parameters
      contactEmails: bg.contactEmails
      location: location
      startDate: bg.startDate
      thresholdType: bg.thresholdType
      thresholds: bg.thresholds
    }
  }
]

// Module: Role Assignments - https://github.com/Azure/bicep-registry-modules/tree/main/avm/ptn/authorization/role-assignment
module roleAssignment 'br/public:avm/ptn/authorization/role-assignment:0.2.0' = [
  for assignment in roleAssignments: if (roleAssignmentEnabled && !empty(roleAssignments)) {
    name: take('roleAssignments-${uniqueString(assignment.principalId)}', 64)
    params: {
      // Required parameters
      principalId: assignment.principalId
      roleDefinitionIdOrName: assignment.roleDefinitionIdOrName
      // Non-required parameters
      location: location
      principalType: assignment.principalType
      subscriptionId: assignment.subscriptionId
    }
  }
]

// Module: Entra Privilaged Identity Management Role Assignments
module privilegedRoleAssignment '../PIM/privilegedRoleAssignment.bicep' = [
  for assignment in privilegedRoleAssignments: if (privilegedRoleAssignmentEnabled && !empty(roleAssignments)) {
    name: take('${guid(assignment.principalId)}', 64)
    scope: subscription(subscriptionId)
    params: {
      assigneeObjectId: assignment.principalId
      roleDefinitionId: assignment.definition
    }
  }
]

// Module: Resource Groups (Common) - https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/resources/resource-group
module sharedResourceGroups 'br/public:avm/res/resources/resource-group:0.4.0' = [
  for commonResourceGroup in shared.commonResourceGroupNames: {
    name: take('sharedResourceGroups-${commonResourceGroup}', 64)
    scope: subscription(subscriptionId)
    params: {
      // Required parameters
      name: commonResourceGroup
      // Non-required parameters
      location: location
      tags: tags
    }
  }
]

// Module: Action Group - https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/insights/action-group
module actionGroup 'br/public:avm/res/insights/action-group:0.4.0' = if (actionGroupEnabled && !empty(actionGroupEmails)) {
  name: take('actionGroup-${guid(deployment().name)}', 64)
  scope: resourceGroup(subscriptionId, 'alertsRG')
  dependsOn: [
    sharedResourceGroups
  ]
  params: {
    // Required parameters
    groupShortName: resourceNames.actionGroupShort
    name: resourceNames.actionGroup
    // Non-required parameters
    emailReceivers: [
      for email in actionGroupEmails: {
        emailAddress: email
        name: split(email, '@')[0]
        useCommonAlertSchema: true
      }
    ]
    location: 'Global'
  }
}

// Module: Resource Groups (Network) - https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/resources/resource-group
module resourceGroupForNetwork 'br/public:avm/res/resources/resource-group:0.4.0' = if (virtualNetworkEnabled) {
  name: take('resourceGroupForNetwork-${guid(deployment().name)}', 64)
  scope: subscription(subscriptionId)
  params: {
    // Required parameters
    name: resourceGroups.network
    // Non-required parameters
    location: location
    tags: tags
  }
}

// Module: Network Watcher - https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/network/network-watcher
module networkWatcher 'br/public:avm/res/network/network-watcher:0.3.0' = if (virtualNetworkEnabled) {
  name: take('networkWatcher-${guid(deployment().name)}', 64)
  scope: resourceGroup(subscriptionId, 'networkWatcherRG')
  dependsOn: [
    sharedResourceGroups
  ]
  params: {
    // Non-required parameters
    location: location
    tags: tags
  }
}

// Module: Spoke Networking
module spokeNetworking '../spokeNetworking/spokeNetworking.bicep' = if (virtualNetworkEnabled && !empty(addressPrefixes)) {
  scope: resourceGroup(subscriptionId, resourceGroups.network)
  name: take('spokeNetworking-${guid(deployment().name)}', 64)
  dependsOn: [
    resourceGroupForNetwork
  ]
  params: {
    addressPrefixes: addressPrefixes
    ddosProtectionPlanId: ddosProtectionPlanId
    disableBgpRoutePropagation: disableBgpRoutePropagation
    dnsServerIps: dnsServerIps
    location: location
    nextHopIpAddress: nextHopIpAddress
    subnets: subnets
    tags: tags
    virtualNetworkName: resourceNames.virtualNetwork
  }
}

// Module: Virtual Network Peering (Hub to Spoke)
module hubPeeringToSpoke '../vnetPeering/vnetPeering.bicep' = if (virtualNetworkEnabled && virtualNetworkPeeringEnabled && !empty(hubVirtualNetworkResourceIdChecked) && !empty(addressPrefixes) && !empty(hubVirtualNetworkResourceGroup) && !empty(hubVirtualNetworkSubscriptionId)) {
  scope: resourceGroup(hubVirtualNetworkSubscriptionId, hubVirtualNetworkResourceGroup)
  name: take('hubPeeringToSpoke-${guid(deployment().name)}', 64)
  params: {
    allowForwardedTraffic: allowSpokeForwardedTraffic
    allowGatewayTransit: allowHubVpnGatewayTransit
    destinationVirtualNetworkName: (!empty(hubVirtualNetworkName) ? spokeNetworking.outputs.virtualNetworkName : '')
    destinationVirtualNetworkId: (!empty(hubVirtualNetworkName) ? spokeNetworking.outputs.virtualNetworkId : '')
    sourceVirtualNetworkName: hubVirtualNetworkName
  }
}

// Module: Virtual Network Peering (Spoke to Hub)
module spokePeeringToHub '../vnetPeering/vnetPeering.bicep' = if (virtualNetworkEnabled && virtualNetworkPeeringEnabled && !empty(hubVirtualNetworkResourceIdChecked) && !empty(addressPrefixes) && !empty(hubVirtualNetworkResourceGroup) && !empty(hubVirtualNetworkSubscriptionId)) {
  scope: resourceGroup(subscriptionId, resourceGroups.network)
  name: take('spokePeeringToHub-${guid(deployment().name)}', 64)
  params: {
    allowForwardedTraffic: allowSpokeForwardedTraffic
    destinationVirtualNetworkName: hubVirtualNetworkName
    destinationVirtualNetworkId: hubVirtualNetworkResourceId
    sourceVirtualNetworkName: (!empty(hubVirtualNetworkName) ? spokeNetworking.outputs.virtualNetworkName : '')
    useRemoteGateways: allowHubVpnGatewayTransit
  }
}

// Module: Virtual Network Connection (vWAN)
module spokePeeringToVwanHub '../CARML/network/virtual-hub/hub-virtual-network-connection/main.bicep' = if (virtualNetworkEnabled && virtualNetworkPeeringEnabled && !empty(virtualHubResourceIdChecked) && !empty(addressPrefixes) && !empty(virtualWanHubResourceGroupName) && !empty(virtualWanHubSubscriptionId)) {
  dependsOn: [
    resourceGroupForNetwork
  ]
  scope: resourceGroup(virtualWanHubSubscriptionId, virtualWanHubResourceGroupName)
  name: take('spokePeeringToVwanHub-${guid(deployment().name)}', 64)
  params: {
    enableInternetSecurity: virtualNetworkVwanEnableInternetSecurity
    name: 'vhc-${guid(virtualHubResourceIdChecked, spokeNetworking.outputs.virtualNetworkName, resourceGroups.network, location, subscriptionId)}'
    remoteVirtualNetworkId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroups.network}/providers/Microsoft.Network/virtualNetworks/${spokeNetworking.outputs.virtualNetworkName}'
    routingConfiguration: !vHubRoutingIntentEnabled
      ? {
          associatedRouteTable: {
            id: virtualWanHubConnectionAssociatedRouteTable
          }
          propagatedRouteTables: {
            ids: virtualWanHubConnectionPropogatedRouteTables
            labels: virtualWanHubConnectionPropogatedLabels
          }
        }
      : {}
    virtualHubName: virtualWanHubName
  }
}
