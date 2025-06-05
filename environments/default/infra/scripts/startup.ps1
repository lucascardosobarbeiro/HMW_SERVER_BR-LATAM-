<#
  startup.ps1 (ajustado aos seus caminhos)

  - Roda automaticamente ao iniciar a VM Windows.
  - Inicia o servidor HorizonMW via `server_default.bat`.
  - Aguardar 30 segundos para o servidor principal subir.
  - Inicia o IW4MAdmin via dotnet (aponta para o arquivo IW4MAdmin.dll).
  - Aguardar 30 segundos para o IW4MAdmin subir.
  - Faz health check na porta 20700 do IW4MAdmin.
  - Gera logs em C:\hmw_server_startup.log.

  Ajuste somente se esses caminhos mudarem:
    $batPath = caminho completo para server_default.bat
    $iw4AdminDllPath = caminho completo para IW4MAdmin.dll
#>

# === 1) CONFIGURAÇÕES (AJUSTE SE MUDAR SEU DIRETÓRIO) ===
$gamePath          = "C:\Program Files (x86)\Steam\steamapps\common\Call of Duty Modern Warfare Remastered"
$batPath           = Join-Path $gamePath "server_default.bat"
$iw4AdminDllPath   = "C:\Program Files (x86)\Steam\steamapps\common\Call of Duty Modern Warfare Remastered\IW4MAdmin-2024.11.29.1\IW4MAdmin.dll"
$iw4AdminPort      = 20700

# === 2) DEFINIÇÃO DO LOG ===
$logFile = "C:\hmw_server_startup.log"
"========== Iniciando HMW via server_default.bat em $(Get-Date -Format 's') ==========" | Out-File $logFile -Encoding utf8 -Append

# === 3) VERIFICA EXISTÊNCIA DO server_default.bat E DO IW4MAdmin.dll ===
if (-Not (Test-Path $batPath)) {
    "Erro: server_default.bat não encontrado em $batPath" | Out-File $logFile -Append
    exit 1
}
if (-Not (Test-Path $iw4AdminDllPath)) {
    "Erro: IW4MAdmin.dll não encontrado em $iw4AdminDllPath" | Out-File $logFile -Append
    exit 1
}

# === 4) INICIA O SERVIDOR via server_default.bat (Minimizado) ===
Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$batPath`"" -WindowStyle Minimized
"Processo server_default.bat iniciado." | Out-File $logFile -Append

# === 5) AGUARDA 30 SEGUNDOS PARA O SERVIDOR SUBIR ===
Start-Sleep -Seconds 30
"Aguardou 30 segundos antes de iniciar o IW4MAdmin" | Out-File $logFile -Append

# === 6) INICIA O IW4MAdmin VIA DOTNET ===
# Muda para o diretório onde está o DLL, para dotnet encontrar dependências
$iw4Dir = Split-Path $iw4AdminDllPath
Set-Location $iw4Dir

Start-Process -FilePath "dotnet" -ArgumentList "`"$iw4AdminDllPath`"" -WindowStyle Minimized
"Processo IW4MAdmin iniciado via dotnet." | Out-File $logFile -Append

# === 7) AGUARDA 30 SEGUNDOS PARA O IW4MAdmin SUBIR ===
Start-Sleep -Seconds 30
"Aguardou 30 segundos antes do health check do IW4MAdmin" | Out-File $logFile -Append

# === 8) HEALTH CHECK DO IW4MAdmin (TCP $iw4AdminPort) ===
$maxAttempts = 5
$attempt     = 0
$portaOK     = $false

while ($attempt -lt $maxAttempts -and -Not $portaOK) {
    Start-Sleep -Seconds 10   # Aguarda 10s entre tentativas
    $attempt++
    if (Test-NetConnection -ComputerName "127.0.0.1" -Port $iw4AdminPort -InformationLevel Quiet) {
        $portaOK = $true
        "Health check IW4MAdmin OK na porta $iw4AdminPort (tentativa $attempt)" | Out-File $logFile -Append
    } else {
        "Health check IW4MAdmin falhou na porta $iw4AdminPort (tentativa $attempt)" | Out-File $logFile -Append
    }
}

if (-Not $portaOK) {
    "Falha: IW4MAdmin NÃO respondeu em porta $iw4AdminPort após $maxAttempts tentativas" | Out-File $logFile -Append
    exit 1
}
"IW4MAdmin ativo em porta $iw4AdminPort" | Out-File $logFile -Append

# === 9) FINALIZAÇÃO ===
"Script de inicialização concluído às $(Get-Date -Format 's')" | Out-File $logFile -Append
exit 0
