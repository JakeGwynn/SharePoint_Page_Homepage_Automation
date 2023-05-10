param(
    [Parameter(Mandatory = $true)]
    [string]$SharePointSiteURL,
    [Parameter(Mandatory = $true)]
    [string]$TemplateFileName,
    [Parameter(Mandatory = $true)]
    [string]$HomePageName
)

# Set Variable for Credential object name
$CredentialName = "AppRegistration"

# Retrieve the automation account credentials
$Cred = Get-AutomationPSCredential -Name $CredentialName
$AppId = $Cred.UserName
$ClientSecret = $Cred.GetNetworkCredential().Password

# Retrieve the automation account variables
$siteTemplateSharePointSiteUrl = Get-AutomationVariable -Name "SiteTemplateSharePointSiteUrl"
$siteTemplateSharePointDocumentLibraryName = Get-AutomationVariable -Name "SiteTemplateSharePointDocumentLibraryName"

# Connect to the SharePoint site
Connect-PnPOnline -Url $siteTemplateSharePointSiteUrl -ClientId $AppId -ClientSecret $ClientSecret

# Download the site template file to temp storage
$tempFilePath = Join-Path $env:TEMP $TemplateFileName
Get-PnPFile -Url "$siteTemplateSharePointDocumentLibraryName/$TemplateFileName" -Path $env:TEMP -Filename $TemplateFileName -AsFile

# Connect to the target SharePoint site
Connect-PnPOnline -Url $SharePointSiteURL -ClientId $AppId -ClientSecret $ClientSecret

# Deploy the site template file
Invoke-PnPSiteTemplate -Path $tempFilePath

# Set the home page
# Set-PnPHomePage -RootFolderRelativeUrl $HomePageName

Disconnect-PnPOnline
