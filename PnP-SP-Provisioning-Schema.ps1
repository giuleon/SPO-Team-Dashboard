<#
    .SYNOPSIS
    Provisioning a PnP template on a target SharePoint 2013 or SharePoint 2016 on-premises site collection.
    .EXAMPLE
    PS C:\> .\Enable-SPResponsiveUI.ps1 -TargetSiteUrl "https://intranet.mydomain.com/sites/targetSite"
    .EXAMPLE
    PS C:\> $creds = Get-Credential
    PS C:\> .\Enable-SPResponsiveUI.ps1 -TargetSiteUrl "https://intranet.mydomain.com/sites/targetSite" -InfrastructureSiteUrl "https://intranet.mydomain.com/sites/infrastructureSite" -Credentials $creds
#>
[CmdletBinding()]
param
(

    [Parameter(Mandatory = $true, HelpMessage="Enter the URL of the office 365 admin site collection, e.g. 'https://intranet-admin.mydomain.com'")]
    [String]
    $AdminSiteUrl,

    [Parameter(Mandatory = $true, HelpMessage="Enter the URL of the target site collection, e.g. 'https://intranet.mydomain.com/sites/targetSite'")]
    [String]
    $TargetSiteUrl,

    [Parameter(Mandatory = $true, HelpMessage="Enter the PnP template path, e.g. 'SPO-template-dashboard.xml'")]
    [String]
    $TemplatePath,

    [Parameter(Mandatory = $false, HelpMessage="Enter the URL of the infrastructural site collection, if any. It is an optional parameter. Values are like: 'https://intranet.mydomain.com/sites/infrastructureSite'")]
    [String]
    $InfrastructureSiteUrl,

    [Parameter(Mandatory = $false, HelpMessage="Enter the site collection title'")]
    [String]
    $SiteTitle,

    [Parameter(Mandatory = $false, HelpMessage="Enter the site collection administrator'")]
    [String]
    $SiteOwner,

    [Parameter(Mandatory = $false, HelpMessage="Enter the site collection time zone'")]
    [int]
    $SiteTimeZone,

    [Parameter(Mandatory = $false, HelpMessage="Optional administration credentials")]
    [PSCredential]
    $Credentials
)

#if($Credentials -eq $null)
#{
#	$Credentials = Get-Credential -Message "Enter Admin Credentials"
#}
Write-Host -ForegroundColor White "--------------------------------------------------------"
Write-Host -ForegroundColor White "|               Provisioning Template                  |"
Write-Host -ForegroundColor White "--------------------------------------------------------"
Write-Host
try
{
	Write-Host -ForegroundColor Yellow "Connecting to admin site URL: $AdminSiteUrl"
    Connect-SPOnline –Url $AdminSiteUrl –Credentials $Credentials
    #Remove-SPOTenantSite -Url "https://giuleon.sharepoint.com/sites/demo" -SkipRecycleBin
    if ([bool] (Get-PnPTenantSite $TargetSiteUrl -ErrorAction SilentlyContinue) -eq $false) {
    	Write-Host -ForegroundColor Yellow "The site collection has not been found I'll create it."
        $SiteTitle = Read-Host -Prompt 'Insert the site collection title'
        $SiteOwner = Read-Host -Prompt 'Insert the site collection administrator'
        <# TIME ZONE
        39->(UTC-12:00) International Date Line West
        95->(UTC-11:00) Coordinated Universal Time-11
        15->(UTC-10:00) Hawaii
        14->(UTC-09:00) Alaska
        78->(UTC-08:00) Baja California
        13->(UTC-08:00) Pacific Time (US and Canada)
        38->(UTC-07:00) Arizona
        77->(UTC-07:00) Chihuahua, La Paz, Mazatlan
        12->(UTC-07:00) Mountain Time (US and Canada)
        55->(UTC-06:00) Central America
        11->(UTC-06:00) Central Time (US and Canada)
        37->(UTC-06:00) Guadalajara, Mexico City, Monterrey
        36->(UTC-06:00) Saskatchewan
        35->(UTC-05:00) Bogota, Lima, Quito
        10->(UTC-05:00) Eastern Time (US and Canada)
        34->(UTC-05:00) Indiana (East)
        88->(UTC-04:30) Caracas
        91->(UTC-04:00) Asuncion
        9 ->(UTC-04:00) Atlantic Time (Canada)
        81->(UTC-04:00) Cuiaba
        33->(UTC-04:00) Georgetown, La Paz, Manaus, San Juan
        28->(UTC-03:30) Newfoundland
        8 ->(UTC-03:00) Brasilia
        85->(UTC-03:00) Buenos Aires
        32->(UTC-03:00) Cayenne, Fortaleza
        60->(UTC-03:00) Greenland
        90->(UTC-03:00) Montevideo
        10->(UTC-03:00) Salvador
        65->(UTC-03:00) Santiago
        96->(UTC-02:00) Coordinated Universal Time-02
        30->(UTC-02:00) Mid-Atlantic
        29->(UTC-01:00) Azores
        53->(UTC-01:00) Cabo Verde
        86->(UTC) Casablanca
        93->(UTC) Coordinated Universal Time
        2 ->(UTC) Dublin, Edinburgh, Lisbon, London
        31->(UTC) Monrovia, Reykjavik
        4 ->(UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna
        6 ->(UTC+01:00) Belgrade, Bratislava, Budapest, Ljubljana, Prague
        3 ->(UTC+01:00) Brussels, Copenhagen, Madrid, Paris
        57->(UTC+01:00) Sarajevo, Skopje, Warsaw, Zagreb
        69->(UTC+01:00) West Central Africa
        83->(UTC+01:00) Windhoek
        79->(UTC+02:00) Amman
        5 ->(UTC+02:00) Athens, Bucharest, Istanbul
        80->(UTC+02:00) Beirut
        49->(UTC+02:00) Cairo
        98->(UTC+02:00) Damascus
        50->(UTC+02:00) Harare, Pretoria
        59->(UTC+02:00) Helsinki, Kyiv, Riga, Sofia, Tallinn, Vilnius
        101->(UTC+02:00) Istanbul
        27->(UTC+02:00) Jerusalem
        7 ->(UTC+02:00) Minsk (old)
        104->(UTC+02:00) E. Europe
        100->(UTC+02:00) Kaliningrad (RTZ 1)
        26->(UTC+03:00) Baghdad
        74->(UTC+03:00) Kuwait, Riyadh
        109->(UTC+03:00) Minsk
        51->(UTC+03:00) Moscow, St. Petersburg, Volgograd (RTZ 2)
        56->(UTC+03:00) Nairobi
        25->(UTC+03:30) Tehran
        24->(UTC+04:00) Abu Dhabi, Muscat
        54->(UTC+04:00) Baku
        106->(UTC+04:00) Izhevsk, Samara (RTZ 3)
        89->(UTC+04:00) Port Louis
        82->(UTC+04:00) Tbilisi
        84->(UTC+04:00) Yerevan
        48->(UTC+04:30) Kabul
        58->(UTC+05:00) Ekaterinburg (RTZ 4)
        87->(UTC+05:00) Islamabad, Karachi
        47->(UTC+05:00) Tashkent
        23->(UTC+05:30) Chennai, Kolkata, Mumbai, New Delhi
        66->(UTC+05:30) Sri Jayawardenepura
        62->(UTC+05:45) Kathmandu
        71->(UTC+06:00) Astana
        102->(UTC+06:00) Dhaka
        46->(UTC+06:00) Novosibirsk (RTZ 5)
        61->(UTC+06:30) Yangon (Rangoon)
        22->(UTC+07:00) Bangkok, Hanoi, Jakarta
        64->(UTC+07:00) Krasnoyarsk (RTZ 6)
        45->(UTC+08:00) Beijing, Chongqing, Hong Kong, Urumqi
        63->(UTC+08:00) Irkutsk (RTZ 7)
        21->(UTC+08:00) Kuala Lumpur, Singapore
        73->(UTC+08:00) Perth
        75->(UTC+08:00) Taipei
        94->(UTC+08:00) Ulaanbaatar
        20->(UTC+09:00) Osaka, Sapporo, Tokyo
        72->(UTC+09:00) Seoul
        70->(UTC+09:00) Yakutsk (RTZ 8)
        19->(UTC+09:30) Adelaide
        44->(UTC+09:30) Darwin
        18->(UTC+10:00) Brisbane
        76->(UTC+10:00) Canberra, Melbourne, Sydney
        43->(UTC+10:00) Guam, Port Moresby
        42->(UTC+10:00) Hobart
        99->(UTC+10:00) Magadan
        68->(UTC+10:00) Vladivostok, Magadan (RTZ 9)
        107->(UTC+11:00) Chokurdakh (RTZ 10)
        41->(UTC+11:00) Solomon Is., New Caledonia
        108->(UTC+12:00) Anadyr, Petropavlovsk-Kamchatsky (RTZ 11)
        17->(UTC+12:00) Auckland, Wellington
        97->(UTC+12:00) Coordinated Universal Time+12
        40->(UTC+12:00) Fiji
        92->(UTC+12:00) Petropavlovsk-Kamchatsky - Old
        67->(UTC+13:00) Nuku'alofa
        16->(UTC+13:00) Samoa
        #>
        $SiteTimeZone = Read-Host -Prompt 'Insert the time zone (integer value ex. 4)'
    	New-PnPTenantSite -Title $SiteTitle -Url $TargetSiteUrl -Owner $SiteOwner -Lcid 1033 -Template “STS#0” -TimeZone $SiteTimeZone -StorageQuota 1000 -RemoveDeletedSite -Wait
    } 
	Connect-SPOnline $TargetSiteUrl -Credentials $Credentials
	Write-Host -ForegroundColor Yellow "Provisoning a template on a target site"
    Apply-SPOProvisioningTemplate -Path $TemplatePath
	Write-Host -ForegroundColor Yellow "Provisoning a template finished"
}
catch
{
    Write-Host -ForegroundColor Red "Exception occurred!" 
    Write-Host -ForegroundColor Red "Exception Type: $($_.Exception.GetType().FullName)"
    Write-Host -ForegroundColor Red "Exception Message: $($_.Exception.Message)"
}