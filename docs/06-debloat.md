# Remocao de aplicativos (debloat)

Objetivo: tirar do aparelho os aplicativos da escola, as ferramentas de fabrica
que ninguem usa e o excesso da Google, sem risco de brick e com reversao
garantida.

Resultado no caso real: **268 pacotes viraram 219**, com zero falhas.

---

## Como funciona a remocao

O comando usado e:

```powershell
adb shell pm uninstall --user 0 <pacote>
```

Pontos importantes:

- Isso remove o pacote **para o usuario atual**, nao apaga o arquivo da
  particao de sistema. O aparelho continua integro.
- E reversivel a qualquer momento com
  `adb shell cmd package install-existing <pacote>`.
- Nao precisa de root.
- Nao quebra o boot, desde que nao se mexa nos pacotes proibidos.
- Uma atualizacao de fabrica ou reset restaura tudo. Por isso o documento 05
  avisa para nao resetar.

Se um pacote recusar a remocao, o script tenta desativar:

```powershell
adb shell pm disable-user --user 0 <pacote>
```

---

## Categorias removidas

### 1. Escola e secretaria de educacao (4)

| Pacote | O que era |
|---|---|
| `br.gov.sp.educacao.minhaescola` | portal Minha Escola |
| `br.gov.sp.educacao.sed.mobile` | aplicativo da SED |
| `corretoraap.sed.educacao.sp.gov.br.corretordeprova` | corretor de provas |
| `tv.ip.edusp` | TV educativa |

Nenhum tem funcao fora da rede escolar. Apos a remocao, a busca por
`educa|seduc|escola` na lista de pacotes retorna vazio.

### 2. Fabricante e ferramentas de fabrica (15)

| Pacote | O que era | Por que sair |
|---|---|---|
| `com.positivo.fota` | atualizador da Positivo | atualizacao de fabrica, que pode trazer restricoes de volta |
| `com.sprd.systemupdate` | atualizador da Unisoc | duplicado, sem utilidade |
| `com.sprd.engineermode` | menu de engenharia | acesso a configuracao de fabrica |
| `com.sprd.validationtools` | teste de fabrica | sem uso |
| `com.sprd.validationtools.revo.overlay` | overlay do teste | sem uso |
| `com.sprd.autoslt` | teste automatico de linha | sem uso |
| `com.sprd.cameracalibration` | calibracao de camera | so em fabrica |
| `com.sprd.logmanager` | coleta de logs | sem uso |
| `com.sprd.maintain` | manutencao | sem uso |
| `com.sprd.uasetting` | configuracao de agente de usuario | sem uso |
| `com.sprd.omacp` | provisionamento de operadora | sem uso |
| `com.sprd.quickcamera` | atalho de camera | sem uso |
| `com.sprd.powersavemodelauncher` | launcher de economia extrema | nao usado |
| `com.revo.partener.config` | customizacao de parceiro | sem uso |
| `com.unisoc.storageclearmanager` | limpador de armazenamento | redundante |

### 3. Radio e temas (3)

| Pacote | O que era |
|---|---|
| `com.android.fmradio` | radio FM, sem hardware no aparelho |
| `com.android.fmradio.revo.overlay` | overlay da radio |
| `com.android.overlay.fmradio` | outro overlay |

### 4. Aplicativos aprovados pelo dono (3)

Estes dependem de gosto. Foram removidos a pedido do dono:

| Pacote | O que era |
|---|---|
| `com.google.android.apps.assistant` | Assistente Google, versao leve |
| `com.google.android.apps.wellbeing` | Bem-estar digital |
| `com.microsoft.teams` | Microsoft Teams |

### 5. Excesso da Google (10)

| Pacote | O que era |
|---|---|
| `com.google.android.apps.youtube.music` | YouTube Music |
| `com.google.android.videos` | Play Filmes |
| `com.google.android.apps.tachyon` | Duo, hoje Meet |
| `com.google.android.marvin.talkback` | leitor de tela, so util se necessario |
| `com.google.android.printservice.recommendation` | recomendacao de impressora |
| `com.android.printspooler` | servico de impressao |
| `com.android.bips` | impressao embutida |
| `com.android.egg` | easter egg do Android |
| `com.android.traceur` | gravador de trace do sistema |
| `com.google.android.feedback` | envio de feedback |

### 6. Restos de configuracao (10)

| Pacote | O que era |
|---|---|
| `android.autoinstalls.config.positivo.T2040B` | config de provisionamento |
| `com.google.android.onetimeinitializer` | inicializacao unica de configuracao |
| `com.google.android.apps.restore` | restauracao de backup no setup |
| `com.google.android.gms.location.history` | historico de localizacao |
| `com.android.dreams.basic` | protetor de tela |
| `com.android.dreams.overlay.basic` | overlay do protetor |
| `com.android.dreams.overlay.phototable` | protetor de fotos |
| `com.android.providers.partnerbookmarks` | favoritos de operadora |
| `com.android.providers.partnerbookmarks.revo.overlay` | overlay dos favoritos |
| `com.android.bookmarkprovider` | fornecedor de favoritos |

### 7. Diversos (4)

| Pacote | O que era |
|---|---|
| `com.android.bluetoothmidiservice` | MIDI por Bluetooth |
| `com.spreadtrum.proxy.nfwlocation` | proxy de localizacao NFC, sem NFC no aparelho |
| `com.sprd.cameraipcontrol` | controle de camera IP, ferramenta de fabrica |
| `com.android.dynsystem` | atualizacao dinamica de sistema, nao usada |

Total da lista: 4 mais 15 mais 3 mais 3 mais 10 mais 10 mais 4, igual a **49 pacotes**.

---

## Os tres pacotes que ficam desativados

Nao foram removidos porque sao de sistema e a remocao pode ter efeito colateral:

```powershell
adb shell pm disable-user --user 0 com.android.nfc
adb shell pm disable-user --user 0 com.google.android.partnersetup
adb shell pm disable-user --user 0 com.android.managedprovisioning
```

| Pacote | Motivo de estar desativado |
|---|---|
| `com.android.nfc` | o aparelho nao tem hardware NFC |
| `com.google.android.partnersetup` | processa a lista de auto-instalacao |
| `com.android.managedprovisioning` | aplica o device owner corporativo |

---

## O que nunca deve sair

A lista completa esta em `dados/pacotes-nunca-remover.txt`. Resumo:

- `com.google.android.gms` e `com.android.vending`: sem isso, nao ha Play Store
  nem conta Google
- `com.google.android.setupwizard`: necessario se um dia o aparelho for resetado
- `com.android.systemui`, `com.android.settings`, `com.android.launcher3`
- `com.android.phone`, `com.android.server.telecom`, `com.unisoc.phone`,
  `com.spreadtrum.ims`, `com.spreadtrum.vowifi`: o aparelho tem modem LTE, e
  esses pacotes controlam telefonia e dados moveis
- `com.android.camera2`, `com.android.gallery3d`, `com.android.deskclock`,
  `com.android.calculator2`, `org.videolan.vlc`
- `com.android.providers.*` em geral: sao provedores de dados do sistema

---

## Rodar o script

```powershell
.\scripts\05-remover-apps.ps1
```

Ou duplo clique em `scripts-bat/6-remover-apps.bat`.

O script:

1. Le a lista de `dados/pacotes-remover.txt`
2. Para cada pacote, tenta remover e, se falhar, tenta desativar
3. Grava um relatorio em `logs/debloat-AAAA-MM-DD-HHMM.txt`
4. Gera `logs/restaurar-AAAA-MM-DD-HHMM.ps1` com os comandos de volta
5. Mostra a contagem antes e depois

---

## Restaurar um pacote

```powershell
adb shell cmd package install-existing br.gov.sp.educacao.minhaescola
```

Ou rode o script de restauracao gerado:

```powershell
.\logs\restaurar-2026-11-20-1730.ps1
```

Nao e preciso reiniciar. O efeito e imediato.

---

## Como conferir o resultado

```powershell
adb shell pm list packages | Measure-Object -Line
adb shell pm list packages -3
adb shell pm list packages -d
adb shell pm list packages | Select-String "educa|seduc|escola"
```

Esperado depois da limpeza:

| Consulta | Resultado |
|---|---|
| Total de pacotes | 219 (era 268) |
| Aplicativos de terceiros | 0 |
| Desativados | 3 |
| Rastros de escola | nenhum |

---

## Efeito real no desempenho

Sendo honesto: a remocao de bloat ajuda, mas nao transforma o aparelho. O ganho
principal vem de:

- Menos servicos em segundo plano competindo por RAM
- Menos notificacoes e sincronizacoes
- Menos atualizacoes automaticas
- Menos espaco usado

O limite continua sendo o hardware: 2 GB de RAM e CPU de 32 bits. O documento
[07-performance.md](07-performance.md) e realista sobre isso.
