# Changelog

Todas as mudancas relevantes deste projeto ficam registradas aqui.
Formato baseado em Keep a Changelog, versionamento semantico.

## [1.0.0] - 2026-11-20

Primeira versao publica, construida a partir de um caso real de recuperacao
de um T2040B de rede publica de ensino.

### Adicionado

- Documentacao completa em 11 arquivos, do diagnostico ao pos-uso.
- Scripts PowerShell para cada etapa, com deteccao de ambiente, download
  verificado por SHA-256, extracao do payload e disparo do gravador.
- Atalhos `.bat` de duplo clique para uso sem conhecimento tecnico.
- Lista dos 49 pacotes removidos, com categoria e motivo de cada um.
- Lista dos pacotes que nunca devem ser removidos.
- Script de restauracao de qualquer pacote removido.
- Exemplos reais de logs de sucesso e de falha, para comparacao.

### Descobertas tecnicas documentadas

- O recovery do T2040B nao possui "Wipe data/factory reset" por decisao de
  fabrica, ligada a politica do fabricante para esse modelo. Nao e defeito.
- O `fastboot` do aparelho e um stub: `getvar` retorna vazio, `erase userdata`
  responde `Flashing Lock Flag is locked` e todos os comandos `oem` retornam
  `unknown cmd`.
- O driver `sprdvcom.sys` de 2015 nao carrega no Windows 11 com Isolamento do
  Nucleo ativo. Sintomas: codigo de problema 52, status `0xC0000428`, evento
  CodeIntegrity 3004.
- O assistente grafico da Positivo dispara ferramentas de MediaTek e falha com
  `E_MTK_DETECT_DEVICE_TIMEOUT` mesmo com o tablet corretamente em modo
  download.
- O provisionamento Android Enterprise do aparelho vem do pacote
  `android.autoinstalls.config.positivo.T2040B`, e pode ser bloqueado
  desativando `com.android.managedprovisioning` e `com.google.android.partnersetup`.

### Limitacoes conhecidas

- O firmware `.pac` nao e distribuido neste repositorio, por tamanho e por nao
  ser redistribuivel. O script baixa do servidor oficial.
- O link direto do instalador contem token temporario. Se expirar, use a pagina
  de Recuperacao Eletronica da Positivo com o numero de serie.
- Apos um reset de fabrica, todas as remocoes voltam. O documento 05 explica.
