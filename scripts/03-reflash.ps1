# 03-reflash.ps1
# Dispara o gravador Unisoc com o .pac oficial e acompanha a gravacao.

param(
    [int]$Porta = 4,
    [int]$MinutosEspera = 45
)

. "$PSScriptRoot\lib-common.ps1"

Write-Titulo "reset-t2040 - reflash da ROM oficial"

$pac     = Join-Path $DirRescuer 'AndroidRescuer\ROM_Android\11178165\Positivo_T2040B_V001_03312022.pac'
$toolDir = Join-Path $DirRescuer 'AndroidRescuer\Gravador_Imagens\Tools\UPGRADEDOWNLOAD_R20.0.0001_+'
$cmd     = Join-Path $toolDir 'CmdDloader.exe'
$imgDir  = Join-Path $toolDir 'ImageFiles'
$result  = Join-Path $toolDir 'download_result.txt'

# ---------------------------------------------------------------
# 1. Pre-requisitos
# ---------------------------------------------------------------
if (-not (Test-Path $pac)) {
    Write-Erro "PAC nao encontrado"
    Write-Info "Rode 3-extrair.bat primeiro"
    return
}
if (-not (Test-Path $cmd)) {
    Write-Erro "CmdDloader.exe nao encontrado"
    Write-Info "Rode 3-extrair.bat primeiro"
    return
}
if (-not (Test-Administrador)) {
    Write-Aviso "Sem privilegios de administrador"
    Write-Info "Se o driver nao estiver carregado, a deteccao vai falhar"
}

Write-Info ("ROM    : " + [math]::Round((Get-Item $pac).Length / 1MB, 1) + " MB")
Write-Info ("Porta  : COM" + $Porta)
Write-Host ''

$estado = Get-EstadoDispositivo
Write-Info ("ADB detecta: " + $estado)
Write-Info "O tablet deve estar DESLIGADO e o cabo DESCONECTADO agora"
Write-Host ''

# ---------------------------------------------------------------
# 2. Limpeza de tentativas anteriores
# ---------------------------------------------------------------
Write-Info "Limpando restos de tentativas anteriores"
Get-Process | Where-Object { $_.ProcessName -match 'CmdDloader|UpgradeDownload' } | ForEach-Object {
    try { $_.Kill(); Write-Info ("  encerrado: " + $_.ProcessName) } catch { }
}
Start-Sleep -Seconds 2
foreach ($f in @('download_result.txt', 'result.txt')) {
    $caminho = Join-Path $toolDir $f
    if (Test-Path $caminho) { Remove-Item $caminho -Force; Write-Info ("  removido: " + $f) }
}

# ---------------------------------------------------------------
# 3. Disparo
# ---------------------------------------------------------------
Write-Host ''
Write-Info "Iniciando o gravador"
$argumentos = @('-pac', "`"$pac`"", '-port', "$Porta")
Write-Info ("CmdDloader.exe " + ($argumentos -join ' '))
$proc = Start-Process -FilePath $cmd -ArgumentList $argumentos -WorkingDirectory $toolDir -PassThru -WindowStyle Normal
Start-Sleep -Seconds 2
if ($proc.HasExited) {
    Write-Erro ("O gravador encerrou imediatamente, codigo " + $proc.ExitCode)
    return
}
Write-Ok ("Gravador iniciado, PID " + $proc.Id)
Write-Log ("reflash iniciado, pid=" + $proc.Id + " porta=" + $Porta)

# ---------------------------------------------------------------
# 4. Espera da descompactacao e aviso para conectar
# ---------------------------------------------------------------
$inicio = Get-Date
$pronto = $false
$avisouPorta = $false

Write-Host ''
Write-Info "Descompactando a ROM. Isso leva cerca de 40 segundos."
Write-Info "AGUARDE o aviso antes de conectar o tablet."

while (((Get-Date) - $inicio).TotalMinutes -lt $MinutosEspera) {

    if ($proc.HasExited) {
        Write-Erro "O gravador encerrou antes da hora"
        break
    }

    $tamanhoMB = 0
    if (Test-Path $imgDir) {
        $soma = (Get-ChildItem $imgDir -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
        if ($soma) { $tamanhoMB = [math]::Round($soma / 1MB, 1) }
    }

    if (-not $pronto -and $tamanhoMB -gt 3100) {
        $pronto = $true
        Write-Host ''
        Write-Host ('=' * 62) -ForegroundColor Green
        Write-Host "  PRONTO PARA CONECTAR" -ForegroundColor Green
        Write-Host ('=' * 62) -ForegroundColor Green
        Write-Host ''
        Write-Host "  1. Tablet DESLIGADO (segure POWER por 15 segundos)" -ForegroundColor White
        Write-Host "  2. Segure VOLUME +" -ForegroundColor White
        Write-Host "  3. Encaixe o cabo USB, mantendo o VOLUME + pressionado" -ForegroundColor White
        Write-Host "  4. Conte ate 15 e solte" -ForegroundColor White
        Write-Host ''
        Write-Host "  A tela do tablet deve ficar PRETA. Se aparecer logo," -ForegroundColor Yellow
        Write-Host "  desconecte, desligue de novo e repita." -ForegroundColor Yellow
        Write-Host ''
        Write-Info "Aguardando o tablet aparecer na COM$Porta"
        Write-Log "payload pronto, aguardando dispositivo"
    }

    # se aparecer outra porta e nao a esperada, avisa
    if (-not $avisouPorta) {
        try {
            $portas = @([System.IO.Ports.SerialPort]::GetPortNames())
            if ($portas.Count -gt 0 -and ($portas -notcontains ("COM" + $Porta))) {
                Write-Aviso ("Porta encontrada: " + ($portas -join ', ') + ", mas o gravador espera COM" + $Porta)
                Write-Aviso ("Reinicie com: .\scripts\03-reflash.ps1 -Porta " + ($portas[0] -replace 'COM', ''))
                $avisouPorta = $true
            }
        } catch { }
    }

    if (Test-Path $result) {
        $conteudo = Get-Content $result -Raw -ErrorAction SilentlyContinue
        if ($conteudo -and $conteudo.Trim().Length -gt 0) { break }
    }

    Start-Sleep -Seconds 3
}

# ---------------------------------------------------------------
# 5. Resultado
# ---------------------------------------------------------------
Write-Host ''
$passou = $false
$textoResultado = ""
if (Test-Path $result) {
    $textoResultado = ((Get-Content $result -Raw) -replace "`r?`n", ' ').Trim()
}
if (-not $textoResultado) {
    $rt = Join-Path $toolDir 'result.txt'
    if (Test-Path $rt) { $textoResultado = ((Get-Content $rt -Raw) -replace "`r?`n", ' ').Trim() }
}
if ($textoResultado -match 'PASS|success') { $passou = $true }

Write-Host ('-' * 62) -ForegroundColor DarkGray
if ($passou) {
    Write-Ok "REFLASH CONCLUIDO COM SUCESSO"
    Write-Info ("Resultado: " + $textoResultado)
    Write-Host ''
    Write-Info "O tablet vai reiniciar sozinho."
    Write-Info "IMPORTANTE: no primeiro boot, NAO conecte o Wi-Fi."
    Write-Info "Siga o documento 05-setup-offline.md"
} else {
    Write-Erro "REFLASH NAO CONCLUIDO"
    if ($textoResultado) { Write-Info ("Resultado: " + $textoResultado) }
    Write-Host ''
    Write-Info "Consulte docs/09-troubleshooting.md"
    Write-Info "Os erros mais comuns:"
    Write-Info "  Check Baudrate Fail   = tablet nao estava em modo download"
    Write-Info "  Uart send error       = cabo removido ou mau contato"
    Write-Info "  timeout               = driver nao carregou (docs/03)"
}
Write-Host ('-' * 62) -ForegroundColor DarkGray
Write-Info ("Log desta execucao: " + (Get-LogAtual))
Write-Log ("reflash finalizado, passou=" + $passou + " resultado=" + $textoResultado)

# ---------------------------------------------------------------
# 6. Encerra o gravador se ainda estiver aberto
# ---------------------------------------------------------------
if (-not $proc.HasExited) {
    Write-Info "Encerrando o gravador"
    try { $proc.Kill() } catch { }
}
