
# DOESNT STILL WORK, REMOVEM RERENCES IN CODE AND REMOVE THIS FILE 
<#
  startup.ps1 (versão final com melhorias e ajustes)

  - Define política de execução do PowerShell para evitar bloqueios.
  - Log centralizado com timestamp e header indicando nova execução.
  - Substitui tempos fixos por verificações dinâmicas (UDP/TCP).
  - Usa Get-NetUDPEndpoint (se disponível) para health check UDP, ou fallback em .NET.
  - Trata erros com detalhes de tipo de exceção e stack trace.
  - Usa códigos de saída semânticos (1 = falha no .bat, 2 = falha no .dll).
  - Restaura diretório original após executar o IW4MAdmin.
#>

# === 1) DEFINIR POLÍTICA DE EXECUÇÃO E VARIÁVEIS GLOBAIS ===
Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force

$gamePath        = "C:\Program Files (x86)\Steam\steamapps\common\Call of Duty Modern Warfare Remastered"
$batPath         = Join-Path $gamePath "server_default.bat"
$iw4AdminDllPath = "C:\Program Files (x86)\Steam\steamapps\common\Call of Duty Modern Warfare Remastered\IW4MAdmin-2024.11.29.1\IW4MAdmin.dll"
$gamePort        = 27016
$iw4AdminPort    = 1624
$logFile         = "C:\hmw_server_startup.log"

# Certifica-se de que o arquivo de log exista
if (-Not (Test-Path $logFile)) {
    New-Item -ItemType File -Path $logFile | Out-Null
}

# === 2) FUNÇÃO DE LOG CONSOLIDADA ===
function Log {
    param([string]$message)
    $timestamp = Get-Date -Format 's'
    "$timestamp - $message" | Out-File $logFile -Encoding utf8 -Append
    Write-Host "$timestamp - $message"
}

# === 3) FUNÇÃO DE HEALTH CHECK UDP (com fallback e Get-NetUDPEndpoint) ===
function Test-UDPPort {
    param(
        [string] $RemoteHost = "127.0.0.1",
        [int]    $Port       = 27016,
        [int]    $TimeoutMs  = 3000
    )
    # Se o cmdlet Get-NetUDPEndpoint existir, use para verificar listener
    if (Get-Command -Name Get-NetUDPEndpoint -ErrorAction SilentlyContinue) {
        try {
            $endpoint = Get-NetUDPEndpoint -LocalPort $Port -ErrorAction SilentlyContinue
            return $endpoint -ne $null
        } catch {
            # fallback para versão .NET abaixo
        }
    }
    # Fallback: tenta enviar/receber pacote via UdpClient .NET
    try {
        $udpClient = New-Object System.Net.Sockets.UdpClient
        $udpClient.Client.ReceiveTimeout = $TimeoutMs
        $endpoint = New-Object System.Net.IPEndPoint ([System.Net.IPAddress]::Parse($RemoteHost)), $Port
        $bytes = [byte[]]@(0)
        $udpClient.Send($bytes, $bytes.Length, $endpoint) | Out-Null
        $udpClient.Receive([ref]$endpoint) | Out-Null
        $udpClient.Close()
        return $true
    } catch {
        return $false
    }
}

# === 4) FUNÇÃO DE HEALTH CHECK TCP ===
function Test-TCPPort {
    param(
        [string] $RemoteHost = "127.0.0.1",
        [int]    $Port       = 1624
    )
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.Connect($RemoteHost, $Port)
        $tcpClient.Close()
        return $true
    } catch {
        return $false
    }
}

# === 5) INÍCIO DO SCRIPT ===
Log "===== Início de nova execução do HMW Startup Script ====="

# === 6) VERIFICAÇÃO DO server_default.bat ===
if (-Not (Test-Path $batPath)) {
    Log "Erro: server_default.bat não encontrado em $batPath"
    exit 1
}

# === 7) EXECUTAR O SERVIDOR DO JOGO ===
try {
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$batPath`"" -WindowStyle Minimized
    Log "Iniciou server_default.bat"
} catch {
    Log "Erro ao iniciar server_default.bat: $($_.Exception.GetType().FullName) - $($_.Exception.Message)"
    Log "StackTrace: $($_.Exception.StackTrace)"
    exit 1
}

# === 8) HEALTH CHECK DINÂMICO DO SERVIDOR (UDP $gamePort) ===
$maxAttempts = 18   # até ~3 minutos (18 * 10s)
$attempt     = 0
$portaOK     = $false

while ($attempt -lt $maxAttempts -and -Not $portaOK) {
    Start-Sleep -Seconds 10
    $attempt++
    if (Test-UDPPort -RemoteHost "127.0.0.1" -Port $gamePort -TimeoutMs 3000) {
        $portaOK = $true
        Log "Servidor do jogo ativo na porta UDP $gamePort (tentativa $attempt)"
    } else {
        Log "Servidor do jogo não respondeu na porta UDP $gamePort (tentativa $attempt)"
    }
}

if (-Not $portaOK) {
    Log "WARNING: Servidor do jogo NÃO respondeu na porta UDP $gamePort após $maxAttempts tentativas"
    # Não aborta aqui, prossegue para iniciar IW4MAdmin
}

# === 9) VERIFICAÇÃO DO IW4MAdmin.dll ===
if (-Not (Test-Path $iw4AdminDllPath)) {
    Log "Erro: IW4MAdmin.dll não encontrado em $iw4AdminDllPath"
    exit 2
}

# === 10) EXECUTAR O IW4MAdmin COM RESTAURAÇÃO DE DIRETÓRIO ===
try {
    $origDir = Get-Location
    $iw4Dir  = Split-Path $iw4AdminDllPath
    Set-Location $iw4Dir

    # Configura processo para redirecionar STDIN (para respostas automáticas, se desejar)
    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName            = "dotnet"
    $processInfo.Arguments           = "`"$iw4AdminDllPath`""
    $processInfo.RedirectStandardInput  = $true
    $processInfo.RedirectStandardOutput = $true
    $processInfo.RedirectStandardError  = $true
    $processInfo.UseShellExecute        = $false
    $processInfo.CreateNoWindow         = $true

    $proc = [System.Diagnostics.Process]::Start($processInfo)

    # Se quiser enviar respostas automáticas, descomente e ajuste:
    <#
    $respostas = @(
        "y"   # Enable webfront?
        "n"   # Enable multiple owners?
        "n"   # Display social media?
        "n"   # Server-side anti-cheat?
        "n"   # Profanity deterring?
    )
    $inputParaIW4 = $respostas -join "`n"
    $proc.StandardInput.WriteLine($inputParaIW4)
    $proc.StandardInput.Close()
    #>

    Log "Processo IW4MAdmin iniciado via dotnet (PID=$($proc.Id))"
    Start-Sleep -Seconds 2
} catch {
    Log "Erro ao iniciar IW4MAdmin: $($_.Exception.GetType().FullName) - $($_.Exception.Message)"
    Log "StackTrace: $($_.Exception.StackTrace)"
    # Restaura diretório original antes de sair
    if ($origDir) { Set-Location $origDir }
    exit 2
}

# Restaura o diretório original após iniciar IW4MAdmin
if ($origDir) { Set-Location $origDir }

# === 11) HEALTH CHECK DINÂMICO DO IW4MAdmin (TCP $iw4AdminPort) ===
$maxAttempts = 5
$attempt     = 0
$portaOK     = $false

while ($attempt -lt $maxAttempts -and -Not $portaOK) {
    Start-Sleep -Seconds 10
    $attempt++
    if (Test-TCPPort -RemoteHost "127.0.0.1" -Port $iw4AdminPort) {
        $portaOK = $true
        Log "IW4MAdmin ativo na porta TCP $iw4AdminPort (tentativa $attempt)"
    } else {
        Log "IW4MAdmin não respondeu na porta TCP $iw4AdminPort (tentativa $attempt)"
    }
}

if (-Not $portaOK) {
    Log "WARNING: IW4MAdmin NÃO respondeu na porta TCP $iw4AdminPort após $maxAttempts tentativas"
    # Prossegue sem abortar; você pode acessar o painel manualmente
}

# === 12) CONCLUSÃO ===
Log "===== Script de inicialização concluído com sucesso ====="
exit 0
