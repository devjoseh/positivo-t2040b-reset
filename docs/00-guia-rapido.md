# Guia rápido

Sequência completa de execução. Tempo estimado: 40 a 60 minutos, sendo 15 de download.

---

## Verificação inicial

| Item | Requisito |
|---|---|
| Tablet | T2040B, bateria acima de 40 por cento |
| PC | Windows 10 ou 11, 6 GB livres em disco |
| Cabo | USB de dados |
| Rede | Necessária para baixar 1,5 GB |

---

## Etapa 1: ambiente

Execute `scripts-bat/1-verificar-ambiente.bat`.

O script verifica:

- PowerShell 5.1 ou superior
- 7-Zip instalado
- `adb.exe` e `fastboot.exe` disponíveis
- Espaço em disco
- Conexão com a internet

Cada item reprovado é listado com a instrução de correção.

---

## Etapa 2: download

Execute `scripts-bat/2-baixar-instalador.bat`.

- Baixa `PositivoRescuerInstaller_T2040B_11178165.exe` (1,49 GB)
- Confere o SHA-256
- Salva em `ferramentas/`

Se o servidor recusar, o script apresenta o caminho alternativo pela página do fabricante, mediante número de série.

---

## Etapa 3: extração

Execute `scripts-bat/3-extrair.bat`.

Conteúdo extraído:

| Item | Função |
|---|---|
| `Positivo_T2040B_V001_03312022.pac` | ROM oficial, 3,18 GB |
| `CmdDloader.exe` | gravador por linha de comando |
| `UpgradeDownload.exe` | gravador com interface, alternativa |
| `Drivers_S545` | driver de comunicação com o Boot ROM |

O script aplica dois ajustes nos arquivos `.ini` do gravador. O motivo de cada um está em [04-reflash.md](04-reflash.md).

---

## Etapa 4: reflash

Execute `scripts-bat/4-reflashar.bat` e responda às perguntas.

Sequência executada:

1. O gravador inicia e descompacta a ROM (cerca de 40 segundos).
2. Quando a tela exibir **PRONTO PARA CONECTAR**:
   - Desligue o tablet, segurando POWER por 15 segundos
   - Segure **VOLUME +**
   - Conecte o cabo USB mantendo a tecla pressionada
   - Conte 15 segundos e solte
3. A gravação inicia automaticamente e dura cerca de 9 minutos.
4. O cabo e o aparelho não devem ser tocados durante a gravação.
5. O resultado aparece como `PASS`.

O tablet reinicia e apresenta a tela de boas-vindas do Android.

Em caso de erro, consultar [09-troubleshooting.md](09-troubleshooting.md).

---

## Etapa 5: configuração sem internet

Esta etapa é obrigatória. A ordem dos passos define se o provisionamento será aplicado.

1. Ligue o tablet e não conecte o Wi-Fi.
2. Na tela de rede, use **Pular** ou **Configurar depois**.
3. Pule conta Google, cópia de dados e etapas que exigem rede.
4. Defina um PIN.
5. Chegue até a área de trabalho.
6. Ative as opções de desenvolvedor: Ajustes, Sobre o tablet, sete toques em **Número da versão**.
7. Em Sistema, Opções do desenvolvedor, ative **Depuração USB**.
8. Conecte o cabo e autorize o computador no tablet.

Execute `scripts-bat/5-pos-setup.bat`. O script bloqueia o provisionamento nas três frentes necessárias e confirma o resultado.

Somente após a confirmação, conecte o Wi-Fi.

Justificativa técnica em [05-setup-offline.md](05-setup-offline.md).

---

## Etapa 6: limpeza do sistema

Com o tablet conectado e autorizado:

1. `scripts-bat/6-remover-apps.bat`
   Remove 49 pacotes: aplicativos do programa educacional, ferramentas de fábrica e excesso de software pré-instalado. Gera relatório e script de restauração.

2. `scripts-bat/7-ajustes.bat`
   Animações em 0,5x, varredura de Wi-Fi e Bluetooth desativada, fontes desconhecidas bloqueadas, tela apagando em 2 minutos.

3. `scripts-bat/8-diagnostico.bat`
   Gera um retrato do aparelho em `logs/`, para comparação futura.

---

## Etapa 7: uso como dispositivo reserva

Procedimento em [08-kit-emergencia.md](08-kit-emergencia.md). Resumo:

1. Gerar e imprimir os códigos de backup da conta Google antes de qualquer login.
2. Entrar com a conta no tablet.
3. Instalar o autenticador e validar a recuperação.
4. Ativar o Find My Device.
5. Desativar a depuração USB.
6. Estabelecer rotina de recarga a cada 3 ou 4 semanas.

---

## Modos do aparelho

| Modo | Tela | Como entrar | Função |
|---|---|---|---|
| Android | sistema em execução | POWER | uso normal |
| Recovery | menu de texto | POWER + VOLUME + | manutenção |
| Fastboot | logo com "FASTBOOT MODE" | Recovery, opção Reboot to bootloader | comandos fastboot |
| Modo download | **tela apagada** | desligado, VOLUME +, conectar cabo | gravação da ROM |

Critério do modo download: tela apagada com o cabo conectado. Se aparecer logo do fabricante ou ícone de bateria, o modo não foi acionado.
