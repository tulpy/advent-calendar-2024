// Shared User Defined Types for Azure Services, exported for reuse in other modules.

// User Defined Type for Tags
@export()
type tagsType = {
  environment: 'sbx' | 'dev' | 'tst' | 'prd'
  applicationName: string
  owner: string
  criticality: 'Tier0' | 'Tier1' | 'Tier2' | 'Tier3'
  costCenter: string
  contactEmail: string
  dataClassification: 'Internal' | 'Confidential' | 'Secret' | 'Top Secret'
  iac: 'Bicep'
  *: string
}

// User Defined Type for Role Assignments
@export()
type roleAssignmentType = {
  @description('Required. The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.')
  roleDefinitionIdOrName: string

  @description('Required. The principal ID of the principal (user/group/identity) to assign the role to.')
  principalId: string

  @description('Optional. The principal type of the assigned principal ID.')
  principalType: ('ServicePrincipal' | 'Group' | 'User' | 'ForeignGroup' | 'Device')?

  @maxLength(36)
  @description('An existing subscription ID. Use this when you do not want the module to create a new subscription. But do want to manage the management group membership. A subscription ID should be provided in the example format `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`')
  subscriptionId: string
}[]

// User Defined Type for Subnets
@export()
type subnetType = {
  @description('Required. The Name of the subnet resource.')
  name: string

  @description('Conditional. The address prefix for the subnet. Required if `addressPrefixes` is empty.')
  addressPrefix: string?

  @description('Conditional. List of address prefixes for the subnet. Required if `addressPrefix` is empty.')
  addressPrefixes: string[]?

  @description('Optional. The delegation to enable on the subnet.')
  delegation: string?

  @description('Optional. The name of the network security group to assign to the subnet.')
  networkSecurityGroupName: string

  @description('Optional. Security Rules for the network security group.')
  securityRules: securityRulesType

  @description('Optional. enable or disable apply network policies on private endpoint in the subnet.')
  privateEndpointNetworkPolicies: ('Disabled' | 'Enabled')

  @description('Optional. enable or disable apply network policies on private link service in the subnet.')
  privateLinkServiceNetworkPolicies: ('Disabled' | 'Enabled')

  @description('Optional. The name of the route table to assign to the subnet.')
  routeTableName: string

  @description('Optional. User Defined Routes for the route table.')
  routes: routeType

  @description('Optional. An array of service endpoint policies.')
  serviceEndpointPolicies: object[]?

  @description('Optional. The service endpoints to enable on the subnet.')
  serviceEndpoints: string[]?

  @description('Optional. Set this property to false to disable default outbound connectivity for all VMs in the subnet. This property can only be set at the time of subnet creation and cannot be updated for an existing subnet.')
  defaultOutboundAccess: bool?

  @description('Optional. Set this property to Tenant to allow sharing subnet with other subscriptions in your AAD tenant. This property can only be set if defaultOutboundAccess is set to false, both properties can only be set if subnet is empty.')
  sharingScope: ('DelegatedServices' | 'Tenant')?
}[]?

// User Defined Type for Routes
@export()
type routeType = {
  @description('Required. Name of the route.')
  name: string?

  @description('Required. Properties of the route.')
  properties: {
    @description('Required. The type of Azure hop the packet should be sent to.')
    nextHopType: ('VirtualAppliance' | 'VnetLocal' | 'Internet' | 'VirtualNetworkGateway' | 'None')

    @description('Optional. The destination CIDR to which the route applies.')
    addressPrefix: string?

    @description('Optional. A value indicating whether this route overrides overlapping BGP routes regardless of LPM.')
    hasBgpOverride: bool?

    @description('Optional. The IP address packets should be forwarded to. Next hop values are only allowed in routes where the next hop type is VirtualAppliance.')
    nextHopIpAddress: string?
  }
}[]

// User Defined Type for Security Rules
@export()
type securityRulesType = {
  @description('Required. The name of the security rule.')
  name: string

  @description('Required. The properties of the security rule.')
  properties: {
    @description('Required. Whether network traffic is allowed or denied.')
    access: ('Allow' | 'Deny')

    @description('Optional. The description of the security rule.')
    description: string?

    @description('Optional. Optional. The destination address prefix. CIDR or destination IP range. Asterisk "*" can also be used to match all source IPs. Default tags such as "VirtualNetwork", "AzureLoadBalancer" and "Internet" can also be used.')
    destinationAddressPrefix: string?

    @description('Optional. The destination address prefixes. CIDR or destination IP ranges.')
    destinationAddressPrefixes: string[]?

    @description('Optional. The resource IDs of the application security groups specified as destination.')
    destinationApplicationSecurityGroupResourceIds: string[]?

    @description('Optional. The destination port or range. Integer or range between 0 and 65535. Asterisk "*" can also be used to match all ports.')
    destinationPortRange: string?

    @description('Optional. The destination port ranges.')
    destinationPortRanges: string[]?

    @description('Required. The direction of the rule. The direction specifies if rule will be evaluated on incoming or outgoing traffic.')
    direction: ('Inbound' | 'Outbound')

    @minValue(100)
    @maxValue(4096)
    @description('Required. Required. The priority of the rule. The value can be between 100 and 4096. The priority number must be unique for each rule in the collection. The lower the priority number, the higher the priority of the rule.')
    priority: int

    @description('Required. Network protocol this rule applies to.')
    protocol: ('Ah' | 'Esp' | 'Icmp' | 'Tcp' | 'Udp' | '*')

    @description('Optional. The CIDR or source IP range. Asterisk "*" can also be used to match all source IPs. Default tags such as "VirtualNetwork", "AzureLoadBalancer" and "Internet" can also be used. If this is an ingress rule, specifies where network traffic originates from.')
    sourceAddressPrefix: string?

    @description('Optional. The CIDR or source IP ranges.')
    sourceAddressPrefixes: string[]?

    @description('Optional. The resource IDs of the application security groups specified as source.')
    sourceApplicationSecurityGroupResourceIds: string[]?

    @description('Optional. The source port or range. Integer or range between 0 and 65535. Asterisk "*" can also be used to match all ports.')
    sourcePortRange: string?

    @description('Optional. The source port ranges.')
    sourcePortRanges: string[]?
  }
}[]

// User Defined Type for budgets
@export()
type budgetsType = {
  @description('Required. The name of the budget.')
  name: string?
  
  @description('Optional. Enable or Disable the deployment of the Azure Budget.')
  enabled: bool

  @description('Optional. The start date for the budget. Start date should be the first day of the month and cannot be in the past (except for the current month).')
  startDate: string?

  @description('Required. The total amount of cost or usage to track with the budget.')
  amount: int

  @description('Required. The type of threshold to use for the budget. The threshold type can be either `Actual` or `Forecasted`.')
  thresholdType: 'Actual' | 'Forecasted'

  @maxLength(5)
  @description('Optional. Percent thresholds of budget for when to get a notification. Can be up to 5 thresholds, where each must be between 1 and 1000.')
  thresholds: array

  @description('Conditional. The list of email addresses to send the budget notification to when the thresholds are exceeded. Required if neither `contactRoles` nor `actionGroups` was provided.')
  contactEmails: array?
}[]?
