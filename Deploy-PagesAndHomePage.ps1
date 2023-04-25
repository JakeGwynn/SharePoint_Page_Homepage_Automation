param(
    [Parameter(Mandatory = $true)]
    [string]$SharePointSiteURL,
    [Parameter(Mandatory = $true)]
    [string]$TemplateFileName,
    [Parameter(Mandatory = $true)]
    [string]$HomePageName
)

# Retrieve the automation account variables
$siteTemplateSharePointSiteUrl = Get-AutomationVariable -Name "SiteTemplateSharePointSiteUrl"
$siteTemplateSharePointDocumentLibraryName = Get-AutomationVariable -Name "SiteTemplateSharePointDocumentLibraryName"

# Connect to the SharePoint site
Connect-PnPOnline -Url $siteTemplateSharePointSiteUrl -Interactive

# Download the site template file to temp storage
$tempFilePath = Join-Path $env:TEMP $TemplateFileName
Get-PnPFile -ServerRelativeUrl "$siteTemplateSharePointDocumentLibraryName/$TemplateFileName" -Path $tempFilePath

# Connect to the target SharePoint site
Connect-PnPOnline -Url $SharePointSiteURL -Interactive

# Deploy the site template file
Invoke-PnPSiteTemplate -Path $tempFilePath

# Set the home page
Set-PnPHomePage -RootFolderRelativeUrl $HomePageName

# Clean up temp file
Remove-Item -Path $tempFilePath
