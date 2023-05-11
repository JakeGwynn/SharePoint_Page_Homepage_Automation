# Applying custom SPO templates with home page

## 1. Create SPO site and document library to house site template XML files

A SharePoint Online site and document library is needed to house the different site XLM Templates.

## 2. Create Logic App - [How to create logic apps](https://learn.microsoft.com/en-us/azure/logic-apps/create-single-tenant-workflows-azure-portal?tabs=standard)
1.  Trigger - Webhook 
    - Schema:
		- HomePage Name (optional): Contains name of homepage to apply to site. The homepage can also be specified in the template.xml file instead of here.
		- `templateName`: Name of template.xml file to apply to the SharePoint site
		- `webUrl`: URL of SharePoint site that will get template applied to it.
            ```{
                "properties": {
                    "parameters": {
                        "properties": {
                            "homepageName": {
                                "type": "string"
                            },
                            "templateName": {
                                "type": "string"
                            }
                        },
                        "type": "object"
                    },
                    "webUrl": {
                        "type": "string"
                    }
                },
                "type": "object"
            }
				
2. Action - Trigger Azure Automation Runbook
3. Managed Identity - enable the "System assigned" managed identity.

## 3. Azure Automation Runbook - [How to create a PowerShell Workflow runbook](https://learn.microsoft.com/en-us/azure/automation/learn/automation-tutorial-runbook-textual)

1.  Access Control (IAM):
    - To allow the Logic App to start this Runbook, we assign the Logic App System assigned managed identity the "Automation Operator" role in the Azure Automation Account. 
    - [How to assign an Azure Role](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal)
3.  Variables:
    - `SiteTemplateSharePointSiteUrl` - URL for SharePoint Site that will store Site Template XML files
    - `SiteTemplateSharePointDocumentLibraryName` - Document Library name for SharePoint Site Document Library that will store Site Template XML files
4. Credentials:
    - Create a credential called "AppRegistration" that has the AppId of the app registration in the UserName field and the ClientSecret in the password field.
5. Runbook:
    - Parameters
        - `$SharePointSiteURL`: Site to apply template to (webUrl from LogicApp)
        - `$TemplateFileName`: template.xml file name for template xml file to apply to site. 
        - `$HomePageName` (optional): Name of homepage.aspx to apply. Only required if HomePage is not specified in template.xml file.
    - Action:
        - Retrieves Sitetemplate.xml from SiteURL and document library specified in the Azure Automation Account variables
        - Invokes Site Template
        - (optional) Applies site homepage		
		
## 4. Site Design
1. Create Site Script (Get-SPOSiteScriptFromWeb)
2. Add Power Automate/Logic App Action
        
        $JSON = @'
        {
            "$schema": "schema.json",
            "actions": [
            {
                    "verb": "triggerFlow",
                    "url": "https://prod-19.westus2.logic.azure.com:443/workflows/785cf8d0b5464e9c8c137499276a8494/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=287DEZfUNkwqArbrSCINaQjrfUgP0yzAmjgMXCN_Zqc",
                    "name": "Apply Template",
                    "parameters": {
                        "templateName":"SiteTemplate.xml",
                        "homepageName": "JakePage1.aspx"
                    }
            }
            ],
            "bindata": {},
            "version": 1
        }
        '@
3. Upload Site Script 
	- `Add-PnPSiteScript -Title "Apply PnP SiteTemplate.xml for JakePage1.aspx - Runbook Direct" -Content $JSON`
	- Create Site Design - Creates the template in SPO User's view that user's can apply to their SharePoint site
    - `Add-PnPSiteDesign -Title "Site with SiteTemplate.xml" -SiteScriptIds <Replace withyourSiteID> -WebTemplate TeamSite`
