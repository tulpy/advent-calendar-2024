New-AzManagementGroupDeployment `
    -ManagementGroupId 'mg-alz1' `
    -Location 'australiaeast' `
    -TemplateParameterFile 'src/configuration/lz.bicepparam' `
    -TemplateFile 'src/orchestration/main.bicep' `
    -Verbose
