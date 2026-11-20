# 02-extrair-payload.ps1
# Extrai o .pac e as ferramentas do instalador e corrige os .ini.

param(
    [switch]$Forcar
)

. "$PSScriptRoot\lib-common.ps1"

Write-Titulo "reset-t2040 - extracao do payload"

$exe = Join-Path $DirFerramentas $NomeInstalador
$pac = Join-Path $DirRescuer 'AndroidRescuer\ROM_Android\11178165\Positivo_T2040B_V001_03312022.pac'
$toolDir = Join-Path $DirRescuer 'AndroidRescuer\Gravador_Imagens\Tools\UPGRADEDOWNLOAD_R20.0.0001_+'
$cmdDloader = Join-Path $toolDir 'CmdDloader.exe'

# ---------------------------------------------------------------
# 1. Pre-requisitos
# ---------------------------------------------------------------
if (-not (Test-Path $exe)) {
    Write-Erro "Instalador nao encontrado"
    Write-Info ("Esperado em: " + $exe)
    Write-Info "Rode 2-baixar-instalador.bat primeiro"
    return
}
$sz = Get-SeteZip
if (-not $sz) {
    Write-Erro "7-Zip nao encontrado"
    Write-Info "Instale com:  winget install 7zip.7zip"
    return
}
$livre = Get-EspacoLivreGB $DirFerramentas
if ($livre -ge 0 -and $livre -lt 4) {
    Write-Erro ("Espaco insuficiente: " + $livre + " GB livres. Precisa de 3,6 GB")
    return
}

if ((Test-Path $pac) -and (Test-Path $cmdDloader) -and -not $Forcar) {
    Write-Ok "Payload ja extraido anteriormente"
    Write-Info ("PAC : " + [math]::Round((Get-Item $pac).Length / 1MB, 1) + " MB")
    Write-Info "Nada a fazer. Proximo passo: 4-reflashar.bat"
    return
}

# ---------------------------------------------------------------
# 2. Extracao
# ---------------------------------------------------------------
Write-Info "Extraindo. Sao 3,6 GB, pode levar de 1 a 3 minutos."
Write-Info "Nao feche esta janela."
Write-Host ''

if (Test-Path $DirRescuer) {
    Write-Info "Pasta de destino ja existe, extraindo por cima"
}

$argumentos = @('x', '-y', ("-o" + $DirRescuer), $exe, '-bsp1')
$proc = Start-Process -FilePath $sz -ArgumentList $argumentos -NoNewWindow -PassThru -Wait
if ($proc.ExitCode -ne 0) {
    Write-Erro ("7-Zip retornou codigo " + $proc.ExitCode)
    return
}

# ---------------------------------------------------------------
# 3. Conferencia
# ---------------------------------------------------------------
Write-Host ''
$falhou = $false
if (Test-Path $pac) {
    Write-Ok ("PAC extraido: " + [math]::Round((Get-Item $pac).Length / 1MB, 1) + " MB")
} else {
    Write-Erro "PAC nao encontrado apos a extracao"
    $falhou = $true
}
if (Test-Path $cmdDloader) {
    Write-Ok "CmdDloader.exe presente"
} else {
    Write-Erro "CmdDloader.exe nao encontrado"
    $falhou = $true
}
if ($falhou) {
    Write-Info "Verifique espaco em disco e bloqueio do antivirus"
    return
}

# ---------------------------------------------------------------
# 4. Correcao dos .ini (codificacao antiga, tratar byte a byte)
# ---------------------------------------------------------------
$enc = [System.Text.Encoding]::GetEncoding(28591)

function Edit-Ini {
    param([string]$Caminho, [string]$De, [string]$Para, [string]$Rotulo)
    if (-not (Test-Path $Caminho)) { Write-Aviso ("Nao encontrado: " + $Rotulo); return }
    if (-not (Test-Path ($Caminho + '.bak'))) { Copy-Item $Caminho ($Caminho + '.bak') -Force }
    $texto = $enc.GetString([System.IO.File]::ReadAllBytes($Caminho))
    $novo = $texto -replace $De, $Para
    [System.IO.File]::WriteAllBytes($Caminho, $enc.GetBytes($novo))
    if ($novo -eq $texto) { Write-Info ("$Rotulo : ja estava ajustado") }
    else { Write-Ok ("$Rotulo : ajustado") }
}

Write-Host ''
Write-Info "Ajustando configuracao do gravador"

# o gravador precisa esperar o usuario conectar, em vez de desistir na hora
Edit-Ini -Caminho (Join-Path $toolDir 'CmdDloader.ini') -De 'WaitDUTTimeout\s*=\s*\d+' -Para 'WaitDUTTimeout = 900000' -Rotulo 'CmdDloader.ini WaitDUTTimeout'

# o gravador precisa aceitar qualquer porta COM, nao so COM1 e COM2
Edit-Ini -Caminho (Join-Path $toolDir 'UpgradeDownload.ini') -De 'EnableFilter\s*=\s*1' -Para 'EnableFilter = 0' -Rotulo 'UpgradeDownload.ini EnableFilter'

# relatorio de resultado, usado pelo script 03 para saber se deu PASS
Edit-Ini -Caminho (Join-Path $toolDir 'UpgradeDownload.ini') -De 'enable=\s*0' -Para 'enable= 1' -Rotulo 'UpgradeDownload.ini report'

# ---------------------------------------------------------------
# 5. Conferencia final
# ---------------------------------------------------------------
Write-Host ''
Write-Info "Estado final da configuracao:"
foreach ($arq in @('CmdDloader.ini', 'UpgradeDownload.ini')) {
    $caminho = Join-Path $toolDir $arq
    if (Test-Path $caminho) {
        $t = $enc.GetString([System.IO.File]::ReadAllBytes($caminho))
        ($t -split "`r?`n") | Where-Object { $_ -match 'WaitDUTTimeout|EnableFilter|Repartition|EraseAll|^Reset=|^enable=' } | ForEach-Object {
            Write-Info ("  " + $_.Trim())
        }
    }
}

Write-Host ''
Write-Ok "Extracao concluida"
Write-Info "Proximo passo: 4-reflashar.bat"
Write-Log "payload extraido e ini ajustados"
