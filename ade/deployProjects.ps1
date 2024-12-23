New-AzResourceGroupDeployment  -TemplateFile .\modules/projects/projects.bicep -TemplateParameterFile '.\configuration/projects.bicepparam' -ResourceGroupName 'project'
