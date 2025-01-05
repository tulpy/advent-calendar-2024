import * as shared from './configuration/shared/shared.conf.bicep'
import * as type from './configuration/shared/shared.types.bicep'

targetScope = 'subscription'

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

@description('Optional. The Azure Region to deploy the resources into.')
param location string = deployment().location

@description('Optional. An object of Tag key & value pairs to be appended to a Subscription.')
param tags type.tagsType

@description('Required. Name of Environment Type associated with Dev Center and Project')
param environmentTypeName string

@description('User object ID is required to assign the necessary role permission to create an environment. Leave this blank if you want to do so at a later time. For more details on finding the user ID, https://learn.microsoft.com/en-us/partner-center/find-ids-and-domain-names')
param userObjectId string = ''

// Spoke Networking Parameters
@description('The subnet resource id if the user wants to use existing subnet')
param existingSubnetId string = ''


// Variables
var argPrefix = toLower('${shared.resPrefixes.resourceGroup}${shared.delimeters.dash}${shared.locPrefixes[location]}${shared.delimeters.dash}${lzPrefix}${shared.delimeters.dash}${envPrefix}')
var adcPrefix = toLower('${shared.resPrefixes.devCenter}${shared.delimeters.dash}${shared.locPrefixes[location]}${shared.delimeters.dash}${lzPrefix}${shared.delimeters.dash}${envPrefix}')
var prjPrefix = toLower('${shared.resPrefixes.project}${shared.delimeters.dash}${shared.locPrefixes[location]}${shared.delimeters.dash}${lzPrefix}${shared.delimeters.dash}${envPrefix}')

var uniqueSuffix = substring(uniqueString(subscription().subscriptionId), 0, 6)

var resourceGroups = {
  devcenter: '${argPrefix}${shared.delimeters.dash}devcenter'
}

var resourceNames = {
  devcenter: '${adcPrefix}${shared.delimeters.dash}${uniqueSuffix}'
  project: '${prjPrefix}${shared.delimeters.dash}project001'
}

// Module: Resource Groups (devCenter) - https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/resources/resource-group
module resourceGroupForDevCenter 'br/public:avm/res/resources/resource-group:0.4.0' = {
  name: take('resourceGroupForNetwork-${guid(deployment().name)}', 64)
  scope: subscription(subscription().subscriptionId)
  params: {
    // Required parameters
    name: resourceGroups.devcenter
    // Non-required parameters
    location: location
    tags: tags
  }
}

// Azure Dev Center Module
module devCenter './modules/devCenter.bicep' = {
  scope: az.resourceGroup(resourceGroups.devcenter)
  name: take('devCenter-${guid(deployment().name)}', 64)
  dependsOn: [
    resourceGroupForDevCenter
  ]
  params: {
    devCenterName: resourceNames.devcenter
    subnetId:  !empty(existingSubnetId) ? existingSubnetId : ''
    location: location
    networkingResourceGroupName: 'nics'
  }
}

// Identity Module
module identity './modules/identity.bicep' = {
  scope: subscription(subscription().subscriptionId)
  name: take('identity-${guid(deployment().name)}', 64)
  params: {
    devCenterName: devCenter.outputs.devCenterName
    resourceGroupName: resourceGroupForDevCenter.outputs.name
  }
}
