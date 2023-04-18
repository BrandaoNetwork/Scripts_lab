## Script de instalação S-Works
## Modulo Web APP - Aplicação Web
## Modulo Web API - API rest para integração 
## ==========================================

# 1. Instalar o Chocolatey
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# 2. Instalar o .Net Core Runtime Hosting Bundle
choco install dotnetcore-3.1-aspnetruntime    
choco install aspnetcore-runtimepackagestore  

# 3. Habilitar recursos do IIS
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

# 7 - Alterar arquivos de configuração.
    # Arquivo de configuração do Web App
    $webappConfigFile = "C:\Simply\Aplicacao\SWorks.WebApp\appsettings.json"
    $webappConfig = Get-Content $webappConfigFile -Raw | ConvertFrom-Json
    $webappConfig.ConnectionStrings.DefaultConnection = "Server=(local);Database=SWorks;Trusted_Connection=True;MultipleActiveResultSets=true"
    Set-Content -Path $webappConfigFile -Value ($webappConfig | ConvertTo-Json -Depth 10)
    
    # Arquivo de configuração do Web API
    $webapiConfigFile = "C:\Simply\Aplicacao\SWorks.WebApi\appsettings.json"
    $webapiConfig = Get-Content $webapiConfigFile -Raw | ConvertFrom-Json
    $webapiConfig.ConnectionStrings.DefaultConnection = "Server=(local);Database=SWorks;Trusted_Connection=True;MultipleActiveResultSets=true"
    Set-Content -Path $webapiConfigFile -Value ($webapiConfig | ConvertTo-Json -Depth 10)

# 8 - Reiniciar o IIS
    Restart-WebAppPool Sworks.WebApi
    Restart-WebAppPool SWorks.WebApp
    iisreset

Write-Host "Instalação concluída com sucesso."