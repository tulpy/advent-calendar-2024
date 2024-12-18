New-AzManagementGroupDeployment `
    -ManagementGroupId 'mg-alz1' `
    -Location 'australiaeast' `
    -TemplateParameterFile './alzArm.param.json' `
    -TemplateUri 'https://raw.githubusercontent.com/Azure/azure-monitor-baseline-alerts/main/patterns/alz/alzArm.json' `
    -Verbose
