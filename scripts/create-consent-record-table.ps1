<#
.SYNOPSIS
Creates the planned dodbl_consent_record Dataverse table metadata.

.DESCRIPTION
Uses the Dataverse Web API metadata endpoints to create the table, columns,
local choice, lookup relationship, saved view, and publish request.

Prerequisites:
- A Dataverse environment URL, for example https://org.crm.dynamics.com or https://org.crm9.dynamics.com.
- An access token for that environment with customization privileges.
  Example token acquisition with Azure CLI:
    az account get-access-token --resource $EnvironmentUrl --query accessToken -o tsv
- Run from a machine allowed to customize the target environment.

This script does not embed secrets and does not authenticate interactively.
Review in a development environment before using against shared environments.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^https://')]
    [string] $EnvironmentUrl,

    [Parameter(Mandatory = $true)]
    [string] $AccessToken,

    [string] $SolutionUniqueName = 'DoDBannerLibrary'
)

$ErrorActionPreference = 'Stop'

$baseUrl = $EnvironmentUrl.TrimEnd('/')
$apiUrl = "$baseUrl/api/data/v9.2"
$headers = @{
    Authorization    = "Bearer $AccessToken"
    Accept           = 'application/json'
    'Content-Type'   = 'application/json; charset=utf-8'
    'OData-MaxVersion' = '4.0'
    'OData-Version'  = '4.0'
}

function New-Label {
    param([Parameter(Mandatory = $true)][string] $Text)
    @{
        LocalizedLabels = @(
            @{
                Label        = $Text
                LanguageCode = 1033
            }
        )
    }
}

function New-RequiredLevel {
    param([ValidateSet('None', 'Recommended', 'ApplicationRequired')][string] $Value = 'None')
    @{
        Value = $Value
        CanBeChanged = $true
        ManagedPropertyLogicalName = 'canmodifyrequirementlevelsettings'
    }
}

function Invoke-Dataverse {
    param(
        [Parameter(Mandatory = $true)][ValidateSet('Get', 'Post', 'Put', 'Patch')] [string] $Method,
        [Parameter(Mandatory = $true)] [string] $Path,
        [object] $Body
    )

    $uri = if ($Path.StartsWith('http')) { $Path } else { "$apiUrl/$Path" }
    $json = $null
    if ($PSBoundParameters.ContainsKey('Body')) {
        $json = $Body | ConvertTo-Json -Depth 30
    }

    if ($PSCmdlet.ShouldProcess($uri, $Method)) {
        Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -Body $json
    }
}

function Add-Column {
    param([Parameter(Mandatory = $true)][hashtable] $Metadata)
    Invoke-Dataverse -Method Post -Path "EntityDefinitions(LogicalName='dodbl_consent_record')/Attributes" -Body $Metadata | Out-Null
}

function Add-SolutionComponent {
    param(
        [Parameter(Mandatory = $true)][int] $ComponentType,
        [Parameter(Mandatory = $true)][string] $ObjectId
    )

    Invoke-Dataverse -Method Post -Path 'AddSolutionComponent' -Body @{
        ComponentType = $ComponentType
        ComponentId = $ObjectId
        SolutionUniqueName = $SolutionUniqueName
        AddRequiredComponents = $false
        DoNotIncludeSubcomponents = $false
    } | Out-Null
}

$table = @{
    '@odata.type' = 'Microsoft.Dynamics.CRM.EntityMetadata'
    SchemaName = 'dodbl_consent_record'
    DisplayName = New-Label 'Consent Record'
    DisplayCollectionName = New-Label 'Consent Records'
    Description = New-Label 'Audit trail of DoD Banner Library consent acknowledgements.'
    OwnershipType = 'UserOwned'
    IsActivity = $false
    HasActivities = $false
    HasNotes = $false
    IsAuditEnabled = @{ Value = $true }
    Attributes = @(
        @{
            '@odata.type' = 'Microsoft.Dynamics.CRM.StringAttributeMetadata'
            SchemaName = 'dodbl_name'
            DisplayName = New-Label 'Name'
            Description = New-Label 'Auto-generated audit record identifier.'
            RequiredLevel = New-RequiredLevel 'ApplicationRequired'
            MaxLength = 100
            FormatName = @{ Value = 'Text' }
            AutoNumberFormat = 'CONSENT-{SEQNUM:8}'
            IsAuditEnabled = @{ Value = $true }
        }
    )
}

Write-Host 'Creating dodbl_consent_record table...'
Invoke-Dataverse -Method Post -Path 'EntityDefinitions' -Body $table | Out-Null

Write-Host 'Creating columns...'
Add-Column @{
    '@odata.type' = 'Microsoft.Dynamics.CRM.PicklistAttributeMetadata'
    SchemaName = 'dodbl_bannertype'
    DisplayName = New-Label 'Banner Type'
    Description = New-Label 'Banner/classification value shown at acknowledgement time.'
    RequiredLevel = New-RequiredLevel 'ApplicationRequired'
    IsAuditEnabled = @{ Value = $true }
    OptionSet = @{
        IsGlobal = $false
        OptionSetType = 'Picklist'
        Options = @(
            @{ Value = 703870000; Label = New-Label 'None' },
            @{ Value = 703870001; Label = New-Label 'DoD' },
            @{ Value = 703870002; Label = New-Label 'CUI' },
            @{ Value = 703870003; Label = New-Label 'U' },
            @{ Value = 703870004; Label = New-Label 'CONFIDENTIAL' },
            @{ Value = 703870005; Label = New-Label 'SECRET' },
            @{ Value = 703870006; Label = New-Label 'TOP SECRET' }
        )
    }
}

foreach ($dateColumn in @(
    @{ SchemaName = 'dodbl_acknowledgedon'; DisplayName = 'Acknowledged On'; Description = 'UTC timestamp when the user acknowledged consent.'; Required = 'ApplicationRequired' },
    @{ SchemaName = 'dodbl_expirydate'; DisplayName = 'Expiry Date'; Description = 'UTC timestamp when the acknowledgement expires.'; Required = 'ApplicationRequired' }
)) {
    Add-Column @{
        '@odata.type' = 'Microsoft.Dynamics.CRM.DateTimeAttributeMetadata'
        SchemaName = $dateColumn.SchemaName
        DisplayName = New-Label $dateColumn.DisplayName
        Description = New-Label $dateColumn.Description
        RequiredLevel = New-RequiredLevel $dateColumn.Required
        Format = 'DateAndTime'
        DateTimeBehavior = @{ Value = 'TimeZoneIndependent' }
        IsAuditEnabled = @{ Value = $true }
    }
}

Add-Column @{
    '@odata.type' = 'Microsoft.Dynamics.CRM.MemoAttributeMetadata'
    SchemaName = 'dodbl_consenttext'
    DisplayName = New-Label 'Consent Text'
    Description = New-Label 'Snapshot of the exact consent text shown to the user.'
    RequiredLevel = New-RequiredLevel 'ApplicationRequired'
    MaxLength = 1048576
    Format = 'TextArea'
    IsAuditEnabled = @{ Value = $true }
}

Add-Column @{
    '@odata.type' = 'Microsoft.Dynamics.CRM.BooleanAttributeMetadata'
    SchemaName = 'dodbl_isactive'
    DisplayName = New-Label 'Is Active'
    Description = New-Label 'Whether the acknowledgement is active and unexpired.'
    RequiredLevel = New-RequiredLevel 'ApplicationRequired'
    DefaultValue = $true
    IsAuditEnabled = @{ Value = $true }
    OptionSet = @{
        TrueOption = @{ Value = 1; Label = New-Label 'Yes' }
        FalseOption = @{ Value = 0; Label = New-Label 'No' }
    }
}

Write-Host 'Creating SystemUser lookup relationship...'
Invoke-Dataverse -Method Post -Path 'CreateOneToMany' -Body @{
    OneToManyRelationship = @{
        '@odata.type' = 'Microsoft.Dynamics.CRM.OneToManyRelationshipMetadata'
        SchemaName = 'dodbl_systemuser_consent_records'
        ReferencedEntity = 'systemuser'
        ReferencingEntity = 'dodbl_consent_record'
        AssociatedMenuConfiguration = @{
            Behavior = 'UseLabel'
            Group = 'Details'
            Label = New-Label 'Consent Records'
            Order = 10000
        }
        CascadeConfiguration = @{
            Assign = 'NoCascade'
            Delete = 'Restrict'
            Merge = 'NoCascade'
            Reparent = 'NoCascade'
            Share = 'NoCascade'
            Unshare = 'NoCascade'
        }
    }
    Lookup = @{
        '@odata.type' = 'Microsoft.Dynamics.CRM.LookupAttributeMetadata'
        SchemaName = 'dodbl_userid'
        DisplayName = New-Label 'User'
        Description = New-Label 'User who acknowledged consent.'
        RequiredLevel = New-RequiredLevel 'ApplicationRequired'
        IsAuditEnabled = @{ Value = $true }
    }
} | Out-Null

Write-Host 'Creating Active Consent Records view...'
$fetchXml = @'
<fetch version="1.0" mapping="logical">
  <entity name="dodbl_consent_record">
    <attribute name="dodbl_name" />
    <attribute name="dodbl_userid" />
    <attribute name="dodbl_bannertype" />
    <attribute name="dodbl_acknowledgedon" />
    <attribute name="dodbl_expirydate" />
    <attribute name="dodbl_isactive" />
    <order attribute="dodbl_acknowledgedon" descending="true" />
    <filter type="or">
      <condition attribute="dodbl_isactive" operator="eq" value="1" />
      <condition attribute="dodbl_expirydate" operator="next-x-years" value="100" />
    </filter>
  </entity>
</fetch>
'@

$layoutXml = @'
<grid name="resultset" object="1" jump="dodbl_name" select="1" icon="1" preview="1">
  <row name="result" id="dodbl_consent_recordid">
    <cell name="dodbl_name" width="150" />
    <cell name="dodbl_userid" width="200" />
    <cell name="dodbl_bannertype" width="150" />
    <cell name="dodbl_acknowledgedon" width="150" />
    <cell name="dodbl_expirydate" width="150" />
    <cell name="dodbl_isactive" width="100" />
  </row>
</grid>
'@

Invoke-Dataverse -Method Post -Path 'savedqueries' -Body @{
    name = 'Active Consent Records'
    returnedtypecode = 'dodbl_consent_record'
    querytype = 0
    fetchxml = $fetchXml
    layoutxml = $layoutXml
    isdefault = $false
} | Out-Null

Write-Host 'Adding table to solution and publishing...'
$entity = Invoke-Dataverse -Method Get -Path "EntityDefinitions(LogicalName='dodbl_consent_record')?`$select=MetadataId"
if ($entity.MetadataId) {
    Add-SolutionComponent -ComponentType 1 -ObjectId $entity.MetadataId
}

Invoke-Dataverse -Method Post -Path 'PublishAllXml' -Body @{} | Out-Null

Write-Host 'Done. Verify the table, columns, auditing settings, lookup relationship, saved view, and solution membership in the maker portal before export.'
