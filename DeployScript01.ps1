#Script de atualização S-Works para ambientes de homologação
#===========================================================
Param(
    [Parameter(Mandatory=$true)]
    [string]$CredPwd
)

$ErrorActionPreference = "Stop"

#Leitura dos diretórios do pacote de instalação
$pathPacote = $env:PathPacote

#Criar hashtable com as informações dos módulos de instalação
$tableWebApp = @{
    Servidor    = $env:ServidorWebApp;
    Servico     = $env:NomeAppPoolWebApp;
    PathOrigem  = $pathPacote + "\Aplicacao\SWorks.WebApp\*";
    PathDestino = $env:PathWebApp
}

$tableWebService = @{
    Servidor    = $env:ServidorWebService;
    Servico     = $env:NomeAppPoolWebService;
    PathOrigem  = $pathPacote + "\Aplicacao\SWorks.WebApi\*";
    PathDestino = $env:PathWebService
}

$tableChassi = @{
    Servidor    = $env:ServidorChassi;
    Servico     = $env:NomeServiceChassi;
    PathOrigem  = $pathPacote + "\Aplicacao\SWorks.SVC\*";
    PathDestino = $env:PathChassi
}

$tableDispatcher = @{
    Servidor    = $env:ServidorDispatcher;
    Servico     = $env:NomeServiceDispatcher;
    PathOrigem  = $pathPacote + "\Aplicacao\SWorks.ActivityDispatcher\*";
    PathDestino = $env:PathDispatcher
}

function RecuperarSessao {
    param (
        [string]$servidor
    )

    Write-Host "Procurando sessao existente no servidor $($servidor)..."

    $session = Get-PSSession -ComputerName $servidor -State "Opened" -ErrorAction SilentlyContinue

    if (!$session) {
        return CriarSessao $servidor
    }

    Write-Host "Sessao existente encontrada!"

    return $session    
}

function CriarSessao {
    param (
        [string]$servidor
    )

    Write-Host "Criando sessao no servidor $($servidor) com usuario $($env:CredUser)..."

    #Criar sessão com autorização elevada
    $passwd = ConvertTo-SecureString -AsPlainText -Force -String $CredPwd

    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $env:CredUser, $passwd

    $session = New-PSSession -ComputerName $servidor -Credential $cred

    Write-Host "Sessao criada!"

    return $session
}

function InterromperAppPool {
    param ( [string]$servidor, [string]$nome )
    
    if ([string]::IsNullOrEmpty($nome)) {
        return;
    }

    Write-Host "Interrompendo application pool $($servidor)\$($nome)..."


    if ([string]::IsNullOrEmpty($servidor)) {
        Stop-WebAppPool -Name $nome -ErrorAction SilentlyContinue
    }
    else {
        $session = RecuperarSessao $servidor
        Invoke-Command -Session $session -ScriptBlock { Stop-WebAppPool -Name $using:nome -ErrorAction SilentlyContinue } -ErrorAction SilentlyContinue
    }

}

function IniciarAppPool {
    param ([string]$servidor, [string]$nome)
    
    if ([string]::IsNullOrEmpty($nome)) {
        return;
    }

    Write-Host "Iniciando application pool $($servidor)\$($nome)..."

    if ([string]::IsNullOrEmpty($servidor)) {
        Start-WebAppPool -Name $nome -ErrorAction SilentlyContinue
    }
    else {
        $session = RecuperarSessao $servidor
        Invoke-Command -Session $session -ScriptBlock { Start-WebAppPool -Name $using:nome -ErrorAction SilentlyContinue } -ErrorAction SilentlyContinue
    }
    
}

function InterromperWindowsService {
    param (
        [string]$servidor, [string]$nome
    )

    if ([string]::IsNullOrEmpty($nome)) {
        return;
    }

    Write-Host "Interrompendo Windows Service $($servidor)\$($nome)..."

    if ([string]::IsNullOrEmpty($servidor)) {
        Get-Service -Name $nome -ErrorAction SilentlyContinue | Stop-Service -Force -ErrorAction SilentlyContinue
    }
    else {
        $session = RecuperarSessao $servidor
        Invoke-Command -Session $session -ScriptBlock { Get-Service -Name $using:nome -ErrorAction SilentlyContinue | Stop-Service -Force -ErrorAction SilentlyContinue } -ErrorAction SilentlyContinue
    }
    
}

function IniciarWindowsService {
    param (
        [string]$servidor, [string]$nome
    )

    if ([string]::IsNullOrEmpty($nome)) {
        return;
    }

    Write-Host "Iniciando Windows Service $($servidor)\$($nome)..."

    if ([string]::IsNullOrEmpty($servidor)) {
        Get-Service -Name $nome -ErrorAction SilentlyContinue | Start-Service -ErrorAction SilentlyContinue
    }
    else {
        $session = RecuperarSessao $servidor
        Invoke-Command -Session $session -ScriptBlock { Get-Service -Name $using:nome -ErrorAction SilentlyContinue | Start-Service -ErrorAction SilentlyContinue } -ErrorAction SilentlyContinue 
    }
    
}

function CopiarArquivos {
    param (
        [string]$pathOrigem, [string]$servidor, [string]$pathDestino
    )

    if ([string]::IsNullOrEmpty($pathOrigem)) {
        return;
    }

    Write-Host "Copiando arquivos $($pathOrigem) -> $($servidor)\$($pathDestino)..."

    if (![string]::IsNullOrEmpty($servidor)) {
        $session = RecuperarSessao $servidor
        Copy-Item -Path $pathOrigem -Destination $pathDestino -Recurse -Verbose -Force -ToSession $session 
    }
    else {
        Copy-Item -Path $pathOrigem -Destination $pathDestino -Recurse -Verbose -Force
    }
}
 

#Interromper serviços existentes em execução

InterromperAppPool $tableWebApp.Servidor $tableWebApp.Servico

InterromperAppPool $tableWebService.Servidor $tableWebService.Servico

InterromperWindowsService $tableChassi.Servidor $tableChassi.Servico

InterromperWindowsService $tableDispatcher.Servidor $tableDispatcher.Servico

#Copiar arquivos de instalação nos diretórios de destino
CopiarArquivos $tableWebApp.PathOrigem $tableWebApp.Servidor $tableWebApp.PathDestino

CopiarArquivos $tableWebService.PathOrigem $tableWebService.Servidor $tableWebService.PathDestino

CopiarArquivos $tableChassi.PathOrigem $tableChassi.Servidor $tableChassi.PathDestino

CopiarArquivos $tableDispatcher.PathOrigem $tableDispatcher.Servidor $tableDispatcher.PathDestino

#Reiniciando serviços
IniciarAppPool $tableWebApp.Servidor $tableWebApp.Servico

IniciarAppPool $tableWebService.Servidor $tableWebService.Servico

IniciarWindowsService $tableChassi.Servidor $tableChassi.Servico

IniciarWindowsService $tableDispatcher.Servidor $tableDispatcher.Servico