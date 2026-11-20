# lib-common.ps1
# Funcoes compartilhadas por todos os scripts do positivo-t2040b-reset.
# Uso: . "$PSScriptRoot\lib-common.ps1"

$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------
# CAMINHOS
# ---------------------------------------------------------------
$script:RepoRoot        = Split-Path -Parent $PSScriptRoot
$script:DirFerramentas  = Join-Path $RepoRoot 'ferramentas'
$script:DirDados        = Join-Path $RepoRoot 'dados'
$script:DirLogs         = Join-Path $RepoRoot 'logs'
$script:DirRescuer      = Join-Path $DirFerramentas 'rescuer'
$script:NomeInstalador  = 'PositivoRescuerInstaller_T2040B_11178165.exe'
$script:ShaInstalador   = '3F6C0A8ABA8CBBF5DB1DCFD1D998FA07EECCA58B01A153CEF93FF41CA105B3A1'
$script:BytesInstalador = 1557124300
$script:UrlInstalador   = 'https://object.spo1.edge.embratel.cloud/v1/KEY_6f4e00d2e02848e7aabd101575f6a5fc/Recovery2022/android/tabletsDC/T2040B/PositivoRescuerInstaller_T2040B_11178165.exe'
$script:UrlPlatformTools = 'https://dl.google.com/android/repository/platform-tools-latest-windows.zip'

foreach ($d in @($DirFerramentas, $DirLogs)) {
    if (-not (Test-Path $d)) { New-Item -ItemType Directory -Force -Path $d | Out-Null }
}

# ---------------------------------------------------------------
# SAIDA NO CONSOLE
# ---------------------------------------------------------------
function Write-Titulo($texto) {
    Write-Host ''
    Write-Host ('=' * 62) -ForegroundColor DarkCyan
    Write-Host ("  " + $texto) -ForegroundColor Cyan
    Write-Host ('=' * 62) -ForegroundColor DarkCyan
}
function Write-Info($texto) { Write-Host ("  " + $texto) -ForegroundColor Gray }
function Write-Ok($texto)   { Write-Host ("  [OK]  " + $texto) -ForegroundColor Green }
function Write-Aviso($texto){ Write-Host ("  [!]   " + $texto) -ForegroundColor Yellow }
function Write-Erro($texto) { Write-Host ("  [X]   " + $texto) -ForegroundColor Red }

# ---------------------------------------------------------------
# LOG
# ---------------------------------------------------------------
$script:CaminhoLog = Join-Path $DirLogs ("execucao-" + (Get-Date -Format 'yyyy-MM-dd-HHmm') + ".log")

function Write-Log($texto) {
    $linha = "[" + (Get-Date -Format 'HH:mm:ss') + "] " + $texto
    Add-Content -Path $CaminhoLog -Value $linha -ErrorAction SilentlyContinue
}
function Get-LogAtual { return $CaminhoLog }

# ---------------------------------------------------------------
# AMBIENTE
# ---------------------------------------------------------------
function Test-Administrador {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $pr = New-Object Security.Principal.WindowsPrincipal($id)
    return $pr.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-SeteZip {
    foreach ($p in @(
        "$env:ProgramFiles\7-Zip\7z.exe",
        "${env:ProgramFiles(x86)}\7-Zip\7z.exe",
        (Join-Path $DirFerramentas '7z.exe')
    )) {
        if ($p -and (Test-Path $p)) { return $p }
    }
    $cmd = Get-Command '7z.exe' -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    return $null
}

function Get-EspacoLivreGB($caminho) {
    try {
        $drv = (Get-Item $caminho).PSDrive
        return [math]::Round($drv.Free / 1GB, 2)
    } catch { return -1 }
}

function Test-Internet {
    try {
        $r = Test-NetConnection -ComputerName 'dl.google.com' -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue
        return [bool]$r
    } catch {
        try {
            $r = Invoke-WebRequest -Uri 'https://www.google.com/generate_204' -UseBasicParsing -TimeoutSec 8
            return ($r.StatusCode -eq 204)
        } catch { return $false }
    }
}

# ---------------------------------------------------------------
# PLATFORM TOOLS (ADB e FASTBOOT)
# ---------------------------------------------------------------
function Get-Adb {
    $candidatos = @(
        (Join-Path $DirFerramentas 'platform-tools\adb.exe'),
        (Join-Path $DirFerramentas 'platform-tools\platform-tools\adb.exe'),
        (Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe')
    )
    foreach ($c in $candidatos) { if (Test-Path $c) { return $c } }
    $cmd = Get-Command 'adb.exe' -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    return $null
}

function Get-Fastboot {
    $adb = Get-Adb
    if (-not $adb) { return $null }
    $fb = Join-Path (Split-Path -Parent $adb) 'fastboot.exe'
    if (Test-Path $fb) { return $fb }
    $cmd = Get-Command 'fastboot.exe' -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    return $null
}

function Install-PlatformTools {
    $destino = Join-Path $DirFerramentas 'platform-tools'
    if (Test-Path (Join-Path $destino 'adb.exe')) { return (Join-Path $destino 'adb.exe') }
    $zip = Join-Path $DirFerramentas 'platform-tools.zip'
    Write-Info "Baixando platform-tools de dl.google.com"
    Invoke-WebRequest -Uri $UrlPlatformTools -OutFile $zip -UseBasicParsing
    Write-Info "Extraindo"
    Expand-Archive -Path $zip -DestinationPath $destino -Force
    Remove-Item $zip -Force -ErrorAction SilentlyContinue
    $achado = Get-ChildItem $destino -Recurse -Filter 'adb.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($achado) { return $achado.FullName }
    return $null
}

# ---------------------------------------------------------------
# ADB
# ---------------------------------------------------------------
function Invoke-Adb {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Comando)
    $adb = Get-Adb
    if (-not $adb) { throw "adb.exe nao encontrado. Rode o script 00-verificar-ambiente.ps1" }
    $saida = & $adb @Comando 2>&1
    return ($saida -join "`n")
}

function Get-EstadoDispositivo {
    $adb = Get-Adb
    if (-not $adb) { return 'sem-adb' }
    $linhas = & $adb devices 2>&1
    $linha = $linhas | Where-Object { $_ -match '^\S+\s+(device|unauthorized|offline|sideload)$' } | Select-Object -First 1
    if (-not $linha) { return 'ausente' }
    if ($linha -match 'unauthorized') { return 'unauthorized' }
    if ($linha -match 'offline') { return 'offline' }
    if ($linha -match 'sideload') { return 'sideload' }
    return 'device'
}

function Wait-Dispositivo {
    param([int]$Segundos = 60)
    Write-Info "Aguardando o tablet aparecer autorizado (ate $Segundos segundos)"
    for ($i = 0; $i -lt $Segundos; $i++) {
        $estado = Get-EstadoDispositivo
        if ($estado -eq 'device') { Write-Ok "Tablet conectado e autorizado"; return $true }
        if ($estado -eq 'unauthorized' -and $i % 5 -eq 0) {
            Write-Aviso "Desbloqueie o tablet e aceite o aviso 'Permitir depuracao USB'"
        }
        Start-Sleep -Seconds 1
        Write-Host '.' -NoNewline -ForegroundColor DarkGray
    }
    Write-Host ''
    Write-Erro "Tablet nao apareceu como autorizado"
    return $false
}

# ---------------------------------------------------------------
# DOWNLOAD COM VERIFICACAO
# ---------------------------------------------------------------
function Get-Sha256($caminho) {
    return (Get-FileHash -Path $caminho -Algorithm SHA256).Hash
}

function Save-ArquivoComHash {
    param(
        [string]$Url,
        [string]$Destino,
        [string]$ShaEsperado,
        [int64]$BytesEsperados = 0
    )
    Write-Info "Baixando: $Url"
    $tmp = "$Destino.parcial"
    if (Test-Path $tmp) { Remove-Item $tmp -Force }

    # progresso manual, porque Invoke-WebRequest e lento em arquivos grandes
    $req = [System.Net.HttpWebRequest]::Create($Url)
    $req.Timeout = 30000
    $resp = $req.GetResponse()
    $total = $resp.ContentLength
    $entrada = $resp.GetResponseStream()
    $saida = [System.IO.File]::Create($tmp)
    $buffer = New-Object byte[] 1048576
    $lido = 0
    $ultimoPct = -1
    try {
        while (($n = $entrada.Read($buffer, 0, $buffer.Length)) -gt 0) {
            $saida.Write($buffer, 0, $n)
            $lido += $n
            if ($total -gt 0) {
                $pct = [int](($lido / $total) * 100)
                if ($pct -ne $ultimoPct -and $pct % 5 -eq 0) {
                    Write-Host ("`r    " + $pct + "%  (" + [math]::Round($lido / 1MB, 1) + " de " + [math]::Round($total / 1MB, 1) + " MB)") -NoNewline
                    $ultimoPct = $pct
                }
            }
        }
    } finally {
        $saida.Close()
        $entrada.Close()
        $resp.Close()
    }
    Write-Host ''

    if ($BytesEsperados -gt 0) {
        $tam = (Get-Item $tmp).Length
        if ($tam -ne $BytesEsperados) {
            Write-Erro "Tamanho diferente do esperado: $tam bytes, esperado $BytesEsperados"
            return $false
        }
        Write-Ok "Tamanho confere: $tam bytes"
    }

    if ($ShaEsperado) {
        Write-Info "Conferindo SHA-256"
        $sha = Get-Sha256 $tmp
        if ($sha -ne $ShaEsperado) {
            Write-Erro "SHA-256 nao confere"
            Write-Erro "  esperado: $ShaEsperado"
            Write-Erro "  obtido  : $sha"
            return $false
        }
        Write-Ok "SHA-256 confere"
    }

    Move-Item -Path $tmp -Destination $Destino -Force
    Write-Ok "Salvo em $Destino"
    return $true
}
