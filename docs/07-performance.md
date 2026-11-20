# Desempenho

O que da para melhorar num T2040B, o que nao da, e por que.

---

## O ponto de partida real

| Item | Valor |
|---|---|
| SoC | Unisoc SC9863A, 8 nucleos (4x 1,6 GHz e 4x 1,2 GHz) |
| RAM | 2 GB (1.934.332 kB uteis) |
| Arquitetura | 32 bits, `armeabi-v7a` e `armeabi` |
| Android | 11 |
| Patch | fevereiro de 2022 |
| Armazenamento | 64 GB, cerca de 52 GB livres |

Contexto antes dos ajustes: 73 MB de RAM livre, 257 MB de swap em uso, 268
pacotes instalados.

---

## Ajustes aplicados pelo script

### Animacoes em 0,5x

```powershell
adb shell settings put global window_animation_scale 0.5
adb shell settings put global transition_animation_scale 0.5
adb shell settings put global animator_duration_scale 0.5
```

Efeito: a interface **parece** duas vezes mais rapida, porque as transicoes
duram metade do tempo. Custo de memoria: zero. E o melhor ajuste por esforco
neste aparelho.

Para voltar ao normal, use `1.0` nos tres. Para deixar instantaneo, use `0`.

### Varredura de Wi-Fi e Bluetooth em segundo plano

```powershell
adb shell settings put global wifi_scan_always_enabled 0
adb shell settings put global ble_scan_always_enabled 0
```

Efeito: para de varrer redes mesmo com o Wi-Fi desligado. Economia real de
bateria em aparelho parado. Custo: localizacao por rede fica menos precisa,
e aplicativos que dependem de varredura em background podem reclamar.

### Fontes desconhecidas bloqueadas

```powershell
adb shell settings put global install_non_market_apps 0
```

Efeito: dificulta instalacao de APK fora da loja. Bom para um aparelho que
guarda sua conta.

### Tempo de tela

```powershell
adb shell settings put system screen_off_timeout 120000
```

120.000 milissegundos, ou 2 minutos. Aparelho de gaveta com tela de 30 minutos
chega na tomada com bateria zerada.

---

## Ajustes manuais que valem a pena

Nao estao no script porque dependem de gosto:

| Ajuste | Onde | Efeito |
|---|---|---|
| Desligar sincronizacao automatica de apps que nao importam | Ajustes, Contas | menos rede e menos CPU |
| Desativar atualizacao automatica da Play Store | Play Store, Configuracoes | evita downloads em hora ruim |
| Usar Gallery Go em vez de Fotos | ja instalado | app leve |
| Baixar mapa offline no Maps | Maps, Mapas off-line | navega sem internet |
| Manter acima de 15 por cento de armazenamento livre | costume | evita degradacao |

---

## O que NAO funciona neste aparelho

### 64 bits

A ABI e `armeabi-v7a`, sem `arm64-v8a`. Significa que **aplicativos que so
existem em 64 bits nao instalam**. A Play Store simplesmente nao os oferece.
Nao ha como resolver sem trocar a ROM, e nao existe ROM 64 bits oficial para
este modelo.

Efeito pratico: alguns aplicativos modernos, inclusive bancos e versoes
recentes de apps populares, podem nao aparecer na loja.

### Mais RAM via software

Nao existe. Ajuste de "acelerador", "limpador de memoria" e "booster" faz o
contrario: gastam RAM para liberar RAM. O Android gerencia memoria sozinho.

### Overclock ou kernel customizado

Sem bootloader destravado, nao ha como gravar kernel diferente. E o bootloader
deste modelo nao destrava.

### Trocar o launcher por um pesado

O launcher padrao e o Launcher3 em configuracao Go, que e leve. Um launcher de
terceiro com muitos recursos (widgets, animacoes, integracao) tende a piorar.

---

## Onde o consumo realmente esta

Depois da limpeza, os maiores consumidores eram:

| Processo | Memoria residente |
|---|---|
| `system_server` | 206 a 273 MB |
| `com.google.android.gms` | 112 a 122 MB |
| `com.google.android.gms.persistent` | 119 MB |
| `com.android.systemui` | 117 a 127 MB |
| `com.android.vending` (Play Store) | 108 MB quando aberto |
| `com.android.launcher3` | 91 MB |

Os dois processos do Google Play Services somam cerca de 240 MB. Isso e o piso
de qualquer Android com Google. Nao da para remover sem perder a Play Store e a
conta Google.

`system_server` e o proprio Android. Tambem nao sai.

---

## Expectativa honesta

Depois de tudo:

| Cenario | Como fica |
|---|---|
| Navegar em pagina simples | aceitavel |
| YouTube no aplicativo | pesado, travar e normal |
| Duas ou tres abas no Chrome | sofre, principalmente no Chrome |
| Jogos | nao |
| Leitor de PDF, notas, musica local | tranquilo |
| Video local no VLC | tranquilo |
| Como aparelho de emergencia | excelente, porque o uso e pontual |

---

## Se quiser apertar mais

Ideias que ficam para quem quiser continuar, com o custo de cada uma:

| Ideia | Ganho | Custo |
|---|---|---|
| Trocar Chrome por navegador leve | menos RAM ao navegar | perde sincronizacao de senhas |
| Remover Drive, Docs, Sheets, Slides | cerca de 120 MB de disco | perde edicao de documentos |
| Remover Maps e YouTube | menos servicos em segundo plano | perde navegacao e video |
| Remover os 18 overlays `revo` | cerca de 30 MB | cosmetico, sem efeito na gaveta |
| Desativar contas de sincronizacao | menos rede e CPU | sem backup automatico |

Nenhuma delas muda o patamar do aparelho. Ele e um tablet de entrada de 2022 com
2 GB de RAM. O ajuste fino serve para deixar o uso basico confortavel, nao para
transformar em outro aparelho.

---

## Como medir o antes e o depois

```powershell
adb shell cat /proc/meminfo | Select-Object -First 3
adb shell dumpsys meminfo | Select-Object -First 12
adb shell pm list packages | Measure-Object -Line
adb shell dumpsys batterystats --charged | Select-String "Estimated power use" -Context 0,6
```

Guarde a saida em `logs/` para comparar depois de qualquer mudanca.
