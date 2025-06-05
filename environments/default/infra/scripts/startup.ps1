<#
  startup.ps1 (simplificado)

  - Roda automaticamente ao iniciar a VM Windows.
  - Inicia o servidor HorizonMW via `server.bat`.
  - Realiza health check na porta do jogo (UDP 28960) por até 5 tentativas.
  - Gera logs em C:\hmw_server_startup.log.

  **Ajuste este caminho abaixo conforme sua instalação:**
    $batPath = caminho completo para o arquivo server.bat do HorizonMW
    $gamePort = porta UDP do jogo (por padrão 28960)
#>

# === 1) CONFIGURAÇÕES (AJUSTE CONFORME SUA INSTALAÇÃO) ===
$gamePath  = "C:\Program Files\Call of Duty Modern Warfare Remastered"
$batPath   = Join-Path $gamePath "HorizonMW\server_default.bat"
$gamePort  = 27016

# === 2) DEFINIÇÃO DO LOG ===
$logFile = "C:\hmw_server_startup.log"
"========== Iniciando HMW via server.bat em $(Get-Date -Format 's') ==========" | Out-File $logFile -Encoding utf8 -Append

# === 3) VERIFICA EXISTÊNCIA DO server.bat ===
if (-Not (Test-Path $batPath)) {
    "Erro: server.bat não encontrado em $batPath" | Out-File $logFile -Append
    exit 1
}

# === 4) INICIA O SERVIDOR via server.bat (Minimizado) ===
Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$batPath`"" -WindowStyle Minimized
"Processo server.bat iniciado." | Out-File $logFile -Append

# === 5) AGUARDA 30 SEGUNDOS PARA O SERVIDOR SUBIR ===
Start-Sleep -Seconds 30
"Aguardou 30 segundos antes do health check do jogo" | Out-File $logFile -Append

# === 6) HEALTH CHECK DA PORTA DO JOGO (UDP $gamePort) ===
$maxAttempts = 5
$attempt     = 0
$portaOK     = $false

while ($attempt -lt $maxAttempts -and -Not $portaOK) {
    Start-Sleep -Seconds 5   # Aguarda 5 segundos entre tentativas
    $attempt++
    if (Test-NetConnection -ComputerName "127.0.0.1" -Port $gamePort -InformationLevel Quiet -Udp) {
        $portaOK = $true
        "Health check Jogo OK em porta $gamePort (tentativa $attempt)" | Out-File $logFile -Append
    } else {
        "Health check Jogo falhou em porta $gamePort (tentativa $attempt)" | Out-File $logFile -Append
    }
}

if (-Not $portaOK) {
    "Falha: Servidor Jogo NÃO respondeu em porta $gamePort após $maxAttempts tentativas" | Out-File $logFile -Append
    exit 1
}

"Servidor Jogo ativo em porta $gamePort" | Out-File $logFile -Append

# === 7) FINALIZAÇÃO ===
"Script de inicialização concluído às $(Get-Date -Format 's')" | Out-File $logFile -Append
exit 0