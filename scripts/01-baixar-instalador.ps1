# 01-baixar-instalador.ps1
# Baixa o instalador oficial da Positivo e confere o SHA-256.

. "$PSScriptRoot\lib-common.ps1"

Write-Titulo "positivo-t2040b-reset - download do instalador oficial"

$destino = Join-Path $DirFerramentas $NomeInstalador

Write-Info "Arquivo alvo : $NomeInstalador"
Write-Info "Tamanho      : 1,49 GB (1.557.124.300 bytes)"
Write-Info "SHA-256      : $ShaInstalador"
Write-Host ''

# ---------------------------------------------------------------
# 1. Ja existe e esta integro?
# ---------------------------------------------------------------
if (Test-Path $destino) {
    $tam = (Get-Item $destino).Length
    Write-Info ("Arquivo ja existe com " + $tam + " bytes. Conferindo hash, pode levar um minuto.")
    $sha = Get-Sha256 $destino
    if ($sha -eq $ShaInstalador) {
        Write-Ok "Arquivo existente ja esta integro. Nada a fazer."
        Write-Info "Proximo passo: 3-extrair.bat"
        return
    }
    Write-Aviso "Arquivo existente nao confere. Vai ser baixado de novo."
    Remove-Item $destino -Force
}

# ---------------------------------------------------------------
# 2. Espaco em disco
# ---------------------------------------------------------------
$livre = Get-EspacoLivreGB $DirFerramentas
if ($livre -ge 0 -and $livre -lt 2) {
    Write-Erro ("Espaco insuficiente: " + $livre + " GB livres")
    return
}

# ---------------------------------------------------------------
# 3. Download
# ---------------------------------------------------------------
Write-Info "Iniciando download. Pode demorar de 5 a 20 minutos."
Write-Info "Nao feche esta janela."
Write-Host ''

$ok = $false
try {
    $ok = Save-ArquivoComHash -Url $UrlInstalador -Destino $destino -ShaEsperado $ShaInstalador -BytesEsperados $BytesInstalador
} catch {
    Write-Erro ("Falha no download: " + $_.Exception.Message)
}

if (-not $ok) {
    Write-Host ''
    Write-Erro "Nao foi possivel baixar pelo link direto."
    Write-Host ''
    Write-Info "O link direto do manual do CIEQ contem um token que expira."
    Write-Info "Alternativas, em ordem de preferencia:"
    Write-Host ''
    Write-Info "1. Pagina oficial da Positivo, com o numero de serie:"
    Write-Info "   https://www.meupositivo.com.br/para-voce/suporte-tecnico/recuperacao-android"
    Write-Host ''
    Write-Info "2. Manual do CIEQ, que lista os links por modelo:"
    Write-Info "   https://drive.google.com/file/d/1vnIjEM87SUkgpjeM6r7VkTdgCBqRESTd/view"
    Write-Host ''
    Write-Info "Baixe manualmente e salve com este nome exato:"
    Write-Info ("   " + $destino)
    Write-Info "Depois rode este script de novo, ele confere o hash."
    Write-Log "download falhou"
    return
}

# ---------------------------------------------------------------
# 4. Resumo
# ---------------------------------------------------------------
Write-Host ''
Write-Ok "Download concluido e verificado"
Write-Info ("Local: " + $destino)
Write-Info "Proximo passo: 3-extrair.bat"
Write-Log "instalador baixado e verificado"
