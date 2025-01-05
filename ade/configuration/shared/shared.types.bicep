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

// User Defined Type for Subnets
@export()
type projectType = {
  @description('Required. The Name of the project resource.')
  name: string

  @description('Optional. The description of the project.')
  description: string?

  @description('Optional. The displayName of the project.')
  displayName: string?

  @description('Optional. The Object Id of the Entra security group.')
  @maxLength(36)
  groupObjectId: string?

  @description('Optional. When specified, limits the maximum number of Dev Boxes a single user can create across all pools in the project. This will have no effect on existing Dev Boxes when reduced.')
  maxDevBoxesPerUser: int

  @description('Optional. The Project Pool resource.')
  pools: poolsType

}

// User Defined Type for Routes
@export()
type poolsType = {
  @description('Required. The Name of the project pool.')
  name: string

  @description('Required. The Dev Box Definition Name.')
  devBoxDefinitionName: string

  @description('Optional. The display name of the pool.')
  displayName: string?

  @description('Optional. Specifies the license type indicating the caller has already acquired licenses for the Dev Boxes that will be created.')
  licenseType: ('Windows_Client')?

  @description('Required. Indicates whether owners of Dev Boxes in this pool are added as local administrators on the Dev Box.')
  localAdministrator : ('Enabled' | 'Disabled')

  @description('Optional. Name of a Network Connection in parent Project of this Pool')
  networkConnectionName : string?

  @description('Required. Indicates whether Dev Boxes in this pool are created with single sign on enabled. The also requires that single sign on be enabled on the tenant.')
  singleSignOnStatus : ('Enabled' | 'Disabled')

  @description('Optional. Indicates whether Dev Boxes in this pool are stopped when the user disconnects from the Dev Box.')
  stopOnDisconnect: {
    @description('Optional. Whether the feature to stop the Dev Box on disconnect once the grace period has lapsed is enabled.')
    status : ('Enabled' | 'Disabled')?

    @description('Optional. The specified time in minutes to wait before stopping a Dev Box once disconnect is detected.')
    gracePeriodMinutes: int?
  }

  @description('Optional. Indicates whether Dev Boxes in this pool are stopped when the user does not connect to the Dev Box within the specified grace period.')
  stopOnNoConnect: {
    @description('Optional. Enables the feature to stop a started Dev Box when it has not been connected to, once the grace period has lapsed.')
    status : ('Enabled' | 'Disabled')?

    @description('Optional. The specified time in minutes to wait before stopping a Dev Box if no connection is made.')
    gracePeriodMinutes: int?
  }
}[]
