# 1 Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# 2 Install .Net Core Runtime Hosting Bundle
    choco install dotnetcore-3.1-aspnetruntime    
    choco install aspnetcore-runtimepackagestore  
    
# 3 Enable IIS Features
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServer
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-CommonHttpFeatures
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpErrors
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpRedirect
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationDevelopment
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebDAV
    Enable-WindowsOptionalFeature -Online -FeatureName NetFx4Extended-ASPNET45
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-NetFxExtensibility45
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-HealthAndDiagnostics
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpLogging
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-LoggingLibraries
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-RequestMonitor
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpTracing
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-Security
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-RequestFiltering
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-Performance
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerManagementTools
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-IIS6ManagementCompatibility
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-Metabase
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementConsole
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-BasicAuthentication
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-WindowsAuthentication
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-StaticContent
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-DefaultDocument
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebSockets
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationInit
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIExtensions
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIFilter
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpCompressionStatic
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET45

# 4 create application Sworks.WebApi and SWorks.WebApp in IIS
#   Import-Module WebAdministration
    Install-Module -Name 'IISAdministration'
    New-WebAppPool Sworks.WebApi
    New-WebAppPool SWorks.WebApp
    Set-ItemProperty IIS
# 7 Update configuration files
$appSettingsFile = 'C:\Simply\Aplicacao\SWorks.WebApi\appsettings.json'
$connectionStringsFile = 'C:\Simply\Aplicacao\SWorks.WebApi\appsettings.connectionStrings.json'
$webConfigFile = 'C:\Simply\Aplicacao\SWorks.WebApp\web.config'
$appSettings = Get-Content $appSettingsFile | ConvertFrom-Json
$connectionStrings = Get-Content $connectionStringsFile | ConvertFrom-Json
$webConfig = [xml](Get-Content $webConfigFile)

$appSettings.ConnectionStrings = $connectionStrings.ConnectionStrings
$appSettings.Logging.Log4Net.ConfigPath = "log4net.config"
$appSettings.WebAppSettings.WebApiBaseUrl = "http://localhost:8088/api/"

$appSettings | ConvertTo-Json -Depth 100 | Out-File $appSettingsFile -Force
$webConfig.configuration.appSettings.add | where {$_.key -eq "apiBaseUrl"} | %{$_.value = "http://localhost:8088/api/"}
$webConfig.Save($webConfigFile)

# 8 Restart IIS
iisreset

Write-Host "Installation completed successfully." -ForegroundColor Green