# 00-verificar-ambiente.ps1
# Confere tudo que e necessario antes de comecar.
# Nao altera nada no tablet.

. "$PSScriptRoot\lib-common.ps1"

Write-Titulo "reset-t2040 - verificacao de ambiente"

$problemas = 0
$avisos = 0

# ---------------------------------------------------------------
# 1. PowerShell
# ---------------------------------------------------------------
Write-Info "Verificando PowerShell"
if ($PSVersionTable.PSVersion.Major -ge 5) {
    Write-Ok ("PowerShell " + $PSVersionTable.PSVersion.ToString())
} else {
    Write-Erro ("PowerShell muito antigo: " + $PSVersionTable.PSVersion.ToString())
    Write-Info "Atualize para o PowerShell 5.1 ou superior"
    $problemas++
}

# ---------------------------------------------------------------
# 2. Privilegios
# ---------------------------------------------------------------
Write-Info "Verificando privilegios"
if (Test-Administrador) {
    Write-Ok "Executando como administrador"
} else {
    Write-Aviso "Nao esta como administrador"
    Write-Info "O reflash e o driver precisam de admin. Abra o PowerShell com botao direito, Executar como administrador."
    $avisos++
}

# ---------------------------------------------------------------
# 3. 7-Zip
# ---------------------------------------------------------------
Write-Info "Verificando 7-Zip"
$sz = Get-SeteZip
if ($sz) {
    Write-Ok ("7-Zip encontrado: " + $sz)
} else {
    Write-Erro "7-Zip nao encontrado"
    Write-Info "Instale com:  winget install 7zip.7zip"
    Write-Info "Ou baixe em:  https://www.7-zip.org/"
    $problemas++
}

# ---------------------------------------------------------------
# 4. ADB e Fastboot
# ---------------------------------------------------------------
Write-Info "Verificando ADB"
$adb = Get-Adb
if ($adb) {
    Write-Ok ("adb encontrado: " + $adb)
    $fb = Get-Fastboot
    if ($fb) { Write-Ok ("fastboot encontrado: " + $fb) }
    else { Write-Aviso "fastboot nao encontrado (nao e obrigatorio neste modelo)" }
} else {
    Write-Aviso "adb nao encontrado"
    $resposta = Read-Host "  Baixar platform-tools agora? (S/n)"
    if ($resposta -eq '' -or $resposta -match '^[SsYy]') {
        try {
            $novo = Install-PlatformTools
            if ($novo) { Write-Ok ("adb instalado em " + $novo) }
            else { Write-Erro "Falha ao instalar platform-tools"; $problemas++ }
        } catch {
            Write-Erro ("Falha no download: " + $_.Exception.Message)
            $problemas++
        }
    } else {
        Write-Info "Sem ADB, as etapas 5, 6 e 7 nao vao funcionar"
        $problemas++
    }
}

# ---------------------------------------------------------------
# 5. Espaco em disco
# ---------------------------------------------------------------
Write-Info "Verificando espaco em disco"
$livre = Get-EspacoLivreGB (Split-Path -Parent $PSScriptRoot)
if ($livre -lt 0) {
    Write-Aviso "Nao foi possivel medir o espaco livre"
} elseif ($livre -lt 6) {
    Write-Erro ("Espaco livre: " + $livre + " GB. Precisa de pelo menos 6 GB")
    $problemas++
} else {
    Write-Ok ("Espaco livre: " + $livre + " GB")
}

# ---------------------------------------------------------------
# 6. Internet
# ---------------------------------------------------------------
Write-Info "Verificando internet"
if (Test-Internet) {
    Write-Ok "Internet disponivel"
} else {
    Write-Aviso "Sem internet. O download do instalador vai falhar."
    $avisos++
}

# ---------------------------------------------------------------
# 7. Arquivos ja baixados
# ---------------------------------------------------------------
Write-Info "Verificando arquivos do projeto"
$exe = Join-Path $DirFerramentas $NomeInstalador
$pac = Join-Path $DirRescuer 'AndroidRescuer\ROM_Android\11178165\Positivo_T2040B_V001_03312022.pac'
if (Test-Path $exe) { Write-Ok ("Instalador presente (" + [math]::Round((Get-Item $exe).Length / 1MB, 1) + " MB)") }
else { Write-Info "Instalador ainda nao baixado (etapa 2)" }
if (Test-Path $pac) { Write-Ok ("PAC extraido (" + [math]::Round((Get-Item $pac).Length / 1MB, 1) + " MB)") }
else { Write-Info "PAC ainda nao extraido (etapa 3)" }

# ---------------------------------------------------------------
# RESUMO
# ---------------------------------------------------------------
Write-Host ''
Write-Host ('-' * 62) -ForegroundColor DarkGray
if ($problemas -eq 0) {
    Write-Ok "Ambiente pronto para comecar"
    Write-Info "Proximo passo: 2-baixar-instalador.bat"
} else {
    Write-Erro ("$problemas problema(s) encontrado(s)")
    Write-Info "Resolva os itens marcados com [X] e rode de novo"
}
if ($avisos -gt 0) { Write-Aviso ("$avisos aviso(s), nao bloqueiam") }
Write-Host ('-' * 62) -ForegroundColor DarkGray
Write-Info ("Log: " + (Get-LogAtual))
Write-Log "verificacao concluida: problemas=$problemas avisos=$avisos"
