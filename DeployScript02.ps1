## Script de instalação S-Works
## Modulo Web APP - Aplicação Web
## Modulo Web API - API rest para integração 
## ==========================================

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

    # 4 create application Sworks.WebApi e SWorks.WebApp IIS
    #   Import-Module WebAdministration
        Install-Module -Name 'IISAdministration'
        New-WebAppPool Sworks.WebApi
        New-WebAppPool SWorks.WebApp
        Set-ItemProperty IIS:\AppPools\Sworks.WebApi -name managedRuntimeVersion -Value "No Managed Code"
        Set-ItemProperty IIS:\AppPools\Sworks.WebApp -name managedRuntimeVersion -Value "No Managed Code"
    
    # 5 Clone repositorio da Bild.
        choco install --force git.install -y
        $env:Path += ";C:\Program Files\Git\bin"
        git clone https://gitlab.com/brandaonetwork/deployapp.git c:\simply
    
    # 6 Convert folder in aplication IIS.
        Import-Module WebAdministration
        New-IISSite -Name 'SWorks' -PhysicalPath 'C:\Simply\' -BindingInformation "*:8088:"
        New-WebVirtualDirectory -Site "SWorks" -Name "Sworks.WebApi" -PhysicalPath "C:\simply\Aplicacao\SWorks.WebApi"
        New-WebVirtualDirectory -Site "SWorks" -Name "Sworks.WebApp" -PhysicalPath "C:\simply\Aplicacao\SWorks.WebApp"
        ConvertTo-WebApplication -PSPath "IIS:\Sites\SWorks\Sworks.WebApi"
        Set-ItemProperty "IIS:\Sites\SWorks\Sworks.WebApi" -Name applicationPool -Value Sworks.WebApi
        ConvertTo-WebApplication -PSPath "IIS:\Sites\SWorks\Sworks.WebApp"
        Set-ItemProperty "IIS:\Sites\SWorks\Sworks.WebApp" -Name applicationPool -Value Sworks.WebApp
    
# 7 - Alterar arquivos de configuração.
# 8 - reiniciar o IIS