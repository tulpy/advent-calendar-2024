New-AzManagementGroupDeployment `
    -ManagementGroupId 'mg-alz1' `
    -Location 'australiaeast' `
    -TemplateParameterFile 'lz.bicepparam' `
    -Verbose
