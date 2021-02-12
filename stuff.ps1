
### Version check code block

#Requires -Version 7.0
'Requires version 7.0'
"Running PowerShell $($PSVersionTable.PSVersion)."


###########################################
# Set trusted PowerShell gallery and check for Azure modules installed (install AZ module if not present).
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

# check if AzureRM installed
if ($PSVersionTable.PSEdition -eq 'Desk' -and (Get-InstalledModule -Name AzureRM)) {
    write-warning ('AzureRM module is installed. This script requires the newer AZ module. ' + 
       'Having both AzureRM & AZ modules installed at the same time is not supported.') 
} elseif ($PSVersionTable.PSEdition -eq 'Core' -and (Get-InstalledModule -Name Az)) {
    Write-host -ForegroundColor Green 'AZ module is already installed'
} else {
    Install-Module -Name Az -AllowClobber
}

###########################################
# function get-blobs
function Get-blobs (
    [string] $TenantID,
    [string] $ContainerName, 
    [string] $ApplicationID, 
    [string] $SecretFilePath,
    [string] $SourceAZStorageAccount
    )

{
    $ClientSecret = Get-Content $SecretFilePath
    $Secret = ConvertTo-SecureString -String $clientSecret -AsPlainText -Force
    $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ApplicationID, $secret
    
    Connect-AzAccount -Credential $Credential -Tenant $TenantID -ServicePrincipal
    
    $Context = New-AzStorageContext -StorageAccountName $SourceAZStorageAccount -UseConnectedAccount
    $Container = Get-AzStorageContainer -context $context -name $containerName
    $Blobs = Get-AzStorageBlob -Container $ContainerName -Context $Context

    $blobs
}


###########################################
