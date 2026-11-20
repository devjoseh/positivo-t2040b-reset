# Desempenho

Ajustes aplicáveis ao T2040B e limites do hardware.

---

## Configuração de referência

| Item | Valor |
|---|---|
| SoC | Unisoc SC9863A, 8 núcleos (4x 1,6 GHz e 4x 1,2 GHz) |
| RAM | 2 GB (1.934.332 kB úteis) |
| Arquitetura | 32 bits, `armeabi-v7a` e `armeabi` |
| Android | 11 |
| Patch | fevereiro de 2022 |
| Armazenamento | 64 GB, cerca de 52 GB livres |

Estado inicial: 73 MB de RAM livre, 257 MB de swap em uso, 268 pacotes instalados.

---

## Ajustes aplicados pelo script

### Animações em 0,5x

```powershell
adb shell settings put global window_animation_scale 0.5
adb shell settings put global transition_animation_scale 0.5
adb shell settings put global animator_duration_scale 0.5
```

As transições passam a durar metade do tempo. Não há custo de memória.

Valores: `1.0` restaura o padrão, `0` remove a animação.

### Varredura de Wi-Fi e Bluetooth

```powershell
adb shell settings put global wifi_scan_always_enabled 0
adb shell settings put global ble_scan_always_enabled 0
```

Interrompe a varredura de redes com o rádio desligado. Reduz consumo em repouso. Efeito colateral: localização por rede fica menos precisa.

### Instalação fora da loja

```powershell
adb shell settings put global install_non_market_apps 0
```

Dificulta a instalação de APK obtido fora da Play Store.

### Tempo de tela

```powershell
adb shell settings put system screen_off_timeout 120000
```

120.000 milissegundos, ou 2 minutos.

---

## Ajustes manuais

| Ajuste | Local | Efeito |
|---|---|---|
| Desativar sincronização de aplicativos sem uso | Ajustes, Contas | menos rede e CPU |
| Desativar atualização automática da Play Store | Play Store, Configurações | evita download em momento inadequado |
| Usar Gallery Go em vez de Fotos | já instalado | aplicativo mais leve |
| Baixar mapa offline | Maps, Mapas off-line | navegação sem internet |
| Manter acima de 15 por cento de armazenamento livre | rotina | evita degradação |

---

## Limites do hardware

### 64 bits

A ABI é `armeabi-v7a`, sem `arm64-v8a`. Aplicativos disponíveis apenas em 64 bits não instalam, e a Play Store não os oferece. Não existe ROM oficial 64 bits para este modelo.

Consequência: parte dos aplicativos atuais, incluindo bancos e versões recentes de aplicativos populares, pode não estar disponível.

### Memória

Não há ganho real em aplicativos de "limpeza de memória" ou "aceleradores". O Android gerencia memória automaticamente, e esses aplicativos consomem RAM para liberar RAM.

### Kernel e overclock

O bootloader está travado, o que impede gravar kernel ou ROM alternativa. Não existe build de terceiro para `t2040b`.

### Launcher

O launcher padrão é o Launcher3 em configuração Go, já leve. Launchers de terceiros com widgets e animações tendem a piorar o desempenho.

---

## Consumo após a limpeza

| Processo | Memória residente |
|---|---|
| `system_server` | 206 a 273 MB |
| `com.google.android.gms` | 112 a 122 MB |
| `com.google.android.gms.persistent` | 119 MB |
| `com.android.systemui` | 117 a 127 MB |
| `com.android.vending` | 108 MB com a loja aberta |
| `com.android.launcher3` | 91 MB |

Os dois processos do Google Play Services somam cerca de 240 MB, valor mínimo em Android com Google. Remover implicaria perder Play Store e conta.

`system_server` é o próprio Android e não pode ser removido.

---

## Desempenho esperado

| Uso | Resultado |
|---|---|
| Navegação em página simples | aceitável |
| YouTube no aplicativo | lento, travamentos eventuais |
| Três abas no Chrome | degradação visível |
| Jogos | inviável |
| PDF, notas, música local | adequado |
| Vídeo local no VLC | adequado |
| Dispositivo de emergência | adequado, pelo uso pontual |

---

## Ajustes adicionais possíveis

| Ajuste | Ganho | Custo |
|---|---|---|
| Substituir Chrome por navegador leve | menos RAM ao navegar | perde sincronização de senhas |
| Remover Drive, Docs, Sheets e Slides | cerca de 120 MB de disco | perde edição de documentos |
| Remover Maps e YouTube | menos serviços em segundo plano | perde navegação e vídeo |
| Remover os 18 overlays `revo` | cerca de 30 MB | sem efeito visível |
| Desativar sincronização de contas | menos rede e CPU | sem backup automático |

Nenhum desses ajustes altera a categoria do aparelho. O limite é o hardware.

---

## Medição

```powershell
adb shell cat /proc/meminfo | Select-Object -First 3
adb shell dumpsys meminfo | Select-Object -First 12
adb shell pm list packages | Measure-Object -Line
adb shell dumpsys batterystats --charged | Select-String "Estimated power use" -Context 0,6
```

Armazenar a saída em `logs/` permite comparação posterior.
