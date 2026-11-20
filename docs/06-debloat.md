# Remoção de aplicativos

Objetivo: retirar do aparelho os aplicativos do programa educacional, as ferramentas de fábrica sem uso e o excesso de software pré-instalado, com reversão garantida.

Resultado no caso real: 268 pacotes para 219, sem falhas.

---

## Método

Comando utilizado:

```powershell
adb shell pm uninstall --user 0 <pacote>
```

Propriedades:

- Remove o pacote para o usuário atual. O arquivo permanece na partição de sistema, que não é alterada.
- Reversível com `adb shell cmd package install-existing <pacote>`.
- Não exige root.
- Não afeta o boot, desde que a lista de exclusão seja respeitada.
- Reset de fábrica restaura tudo. Ver [05-setup-offline.md](05-setup-offline.md).

Quando o pacote recusa remoção, o script aplica desativação:

```powershell
adb shell pm disable-user --user 0 <pacote>
```

---

## Categorias removidas

### 1. Programa educacional (4)

Quatro pacotes de aplicativos do programa educacional estão na lista. Os identificadores exatos ficam em `dados/pacotes-remover.txt`.

Nenhum deles tem função fora do contexto do programa. Após a remoção, a busca por resíduos na lista de pacotes retorna vazio.

### 2. Fabricante e ferramentas de fábrica (15)

| Pacote | Função | Motivo da remoção |
|---|---|---|
| `com.positivo.fota` | atualizador do fabricante | pode reaplicar configuração de fábrica |
| `com.sprd.systemupdate` | atualizador da Unisoc | duplicado |
| `com.sprd.engineermode` | menu de engenharia | acesso a configuração de fábrica |
| `com.sprd.validationtools` | teste de fábrica | sem uso |
| `com.sprd.validationtools.revo.overlay` | overlay do teste | sem uso |
| `com.sprd.autoslt` | teste automático de linha | sem uso |
| `com.sprd.cameracalibration` | calibração de câmera | uso exclusivo de fábrica |
| `com.sprd.logmanager` | coleta de logs | sem uso |
| `com.sprd.maintain` | manutenção | sem uso |
| `com.sprd.uasetting` | configuração de agente | sem uso |
| `com.sprd.omacp` | provisionamento de operadora | sem uso |
| `com.sprd.quickcamera` | atalho de câmera | sem uso |
| `com.sprd.powersavemodelauncher` | launcher de economia extrema | não utilizado |
| `com.revo.partener.config` | customização de parceiro | sem uso |
| `com.unisoc.storageclearmanager` | limpador de armazenamento | redundante |

### 3. Rádio e temas (3)

| Pacote | Função |
|---|---|
| `com.android.fmradio` | rádio FM, sem hardware no aparelho |
| `com.android.fmradio.revo.overlay` | overlay da rádio |
| `com.android.overlay.fmradio` | overlay da rádio |

### 4. Aplicativos de escolha do usuário (3)

| Pacote | Função |
|---|---|
| `com.google.android.apps.assistant` | Assistente Google, versão leve |
| `com.google.android.apps.wellbeing` | Bem-estar digital |
| `com.microsoft.teams` | Microsoft Teams |

### 5. Excesso de software pré-instalado (10)

| Pacote | Função |
|---|---|
| `com.google.android.apps.youtube.music` | YouTube Music |
| `com.google.android.videos` | Play Filmes |
| `com.google.android.apps.tachyon` | Duo, atualmente Meet |
| `com.google.android.marvin.talkback` | leitor de tela |
| `com.google.android.printservice.recommendation` | recomendação de impressora |
| `com.android.printspooler` | serviço de impressão |
| `com.android.bips` | impressão embutida |
| `com.android.egg` | easter egg |
| `com.android.traceur` | gravação de trace |
| `com.google.android.feedback` | envio de feedback |

### 6. Restos de configuração (10)

| Pacote | Função |
|---|---|
| `android.autoinstalls.config.positivo.T2040B` | configuração de provisionamento |
| `com.google.android.onetimeinitializer` | inicialização única |
| `com.google.android.apps.restore` | restauração de backup |
| `com.google.android.gms.location.history` | histórico de localização |
| `com.android.dreams.basic` | protetor de tela |
| `com.android.dreams.overlay.basic` | overlay do protetor |
| `com.android.dreams.overlay.phototable` | protetor de fotos |
| `com.android.providers.partnerbookmarks` | favoritos de operadora |
| `com.android.providers.partnerbookmarks.revo.overlay` | overlay dos favoritos |
| `com.android.bookmarkprovider` | fornecedor de favoritos |

### 7. Diversos (4)

| Pacote | Função |
|---|---|
| `com.android.bluetoothmidiservice` | MIDI por Bluetooth |
| `com.spreadtrum.proxy.nfwlocation` | proxy de localização NFC, sem NFC no aparelho |
| `com.sprd.cameraipcontrol` | controle de câmera, ferramenta de fábrica |
| `com.android.dynsystem` | atualização dinâmica de sistema |

Total: 4 mais 15 mais 3 mais 3 mais 10 mais 10 mais 4, igual a 49 pacotes.

---

## Pacotes desativados

Três pacotes de sistema permanecem instalados, porém desativados:

```powershell
adb shell pm disable-user --user 0 com.android.nfc
adb shell pm disable-user --user 0 com.google.android.partnersetup
adb shell pm disable-user --user 0 com.android.managedprovisioning
```

| Pacote | Motivo |
|---|---|
| `com.android.nfc` | aparelho sem hardware NFC |
| `com.google.android.partnersetup` | processa lista de auto-instalação |
| `com.android.managedprovisioning` | aplica device owner corporativo |

---

## Pacotes que não podem ser removidos

Lista completa em `dados/pacotes-nunca-remover.txt`. Resumo:

- `com.google.android.gms` e `com.android.vending`: sem eles não há Play Store nem conta Google
- `com.google.android.setupwizard`: necessário em caso de reset
- `com.android.systemui`, `com.android.settings`, `com.android.launcher3`
- `com.android.phone`, `com.android.server.telecom`, `com.unisoc.phone`, `com.spreadtrum.ims`, `com.spreadtrum.vowifi`: o aparelho possui modem LTE
- `com.android.camera2`, `com.android.gallery3d`, `com.android.deskclock`, `com.android.calculator2`, `org.videolan.vlc`
- provedores `com.android.providers.*` em geral

---

## Execução

```powershell
.\scripts\05-remover-apps.ps1
```

Ou `scripts-bat/6-remover-apps.bat`.

O script:

1. Lê a lista de `dados/pacotes-remover.txt`
2. Tenta remover e, em caso de falha, desativa
3. Grava relatório em `logs/debloat-AAAA-MM-DD-HHMM.txt`
4. Gera `logs/restaurar-AAAA-MM-DD-HHMM.ps1` com os comandos de reversão
5. Exibe a contagem antes e depois

---

## Restauração

```powershell
adb shell cmd package install-existing com.google.android.apps.wellbeing
```

Ou o script gerado:

```powershell
.\logs\restaurar-2026-11-20-1730.ps1
```

O efeito é imediato, sem reinício.

---

## Verificação

```powershell
adb shell pm list packages | Measure-Object -Line
adb shell pm list packages -3
adb shell pm list packages -d
adb shell pm list packages | Select-String "educa|autoinstall"
```

Valores esperados após a limpeza:

| Consulta | Resultado |
|---|---|
| Total de pacotes | 219 (antes 268) |
| Aplicativos de terceiros | 0 |
| Desativados | 3 |
| Resíduos do programa educacional | nenhum |

---

## Efeito no desempenho

A remoção reduz a competição por RAM em segundo plano, diminui notificações e sincronizações e libera espaço. Não altera o limite de hardware: 2 GB de RAM e CPU de 32 bits.

Análise em [07-performance.md](07-performance.md).
