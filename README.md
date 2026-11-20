# positivo-t2040b-reset

Recuperação completa do tablet **Positivo T2040B** (linha educacional SEDUC-SP): do PIN esquecido, passando pelo reflash da ROM oficial, até a remoção dos apps da escola, do provisionamento Android Enterprise e dos ajustes de desempenho.

O objetivo é simples: qualquer pessoa, inclusive quem nunca usou ADB na vida, consegue restaurar um T2040B seguindo os arquivos daqui.

---

## O que este repositório resolve

| Problema | Solução aqui documentada |
|---|---|
| PIN esquecido, sem conta Google, sem nota fiscal | Reflash da ROM oficial com o `.pac` do próprio fabricante |
| Recovery sem a opção "Wipe data/factory reset" | Explicação do motivo e caminho alternativo |
| `fastboot -w` não funciona e ninguém sabe por quê | Diagnóstico completo do bootloader Unisoc travado |
| Ferramenta oficial da Positivo falha com `E_MTK_DETECT_DEVICE_TIMEOUT` | Causa raiz: driver de 2015 bloqueado pelo Windows 11 |
| Depois do reset aparece "Este dispositivo pertence à sua organização" | Identificação e bloqueio do provisionamento Android Enterprise |
| Tablet lento com 2 GB de RAM cheio de apps de escola | Lista de 49 pacotes removidos, com script e reversão |
| Vai usar como aparelho reserva ou de emergência | Guia de kit de emergência com Google, autenticador e backup |

---

## Compatibilidade

Testado e validado neste modelo:

| Item | Valor |
|---|---|
| Marca e modelo | Positivo T2040B (nome comercial T2040) |
| Codinome interno | `t2040b` |
| Build de fábrica | `positivo/T2040/T2040B:11/R01005/URBB2022033101:user/release-keys` |
| Android | 11 |
| SoC | Unisoc (Spreadtrum) SC9863A |
| RAM | 2 GB |
| Armazenamento | 64 GB |
| Arquitetura | 32 bits (`armeabi-v7a`) |
| Patch de segurança | 2022-02-05 |
| Número de peça | 01300-22-03589 |

> **Não use este guia em outro modelo.** O T2040C, o Q10 e o Pro X parecem iguais por fora, mas o próprio CIEQ/SEDUC avisa: "a ROM apenas funcionará em seu respectivo modelo". Flash de ROM trocada pode inutilizar o aparelho.

---

## Aviso importante

1. O processo **apaga todos os dados** do tablet. Isso é intencional.
2. Você precisa ser o dono do aparelho. Este material não serve para burlar bloqueio de terceiros.
3. O reflash usa a ROM oficial do fabricante obtida pelo próprio instalador da Positivo. Nada de ROM de terceiro.
4. A responsabilidade pelo uso é sua. Leia os documentos na ordem.

---

## Comece aqui (se você não é desenvolvedor)

Você não precisa entender nada de Android. Precisa de:

- Um PC com **Windows 10 ou 11**
- Um cabo USB de dados
- Cerca de **30 minutos**
- Espaço em disco: 3 GB livres para o instalador mais 4 GB para a extração

### Passo a passo resumido

1. **Baixe este repositório** (botão verde `Code`, depois `Download ZIP`), extraia em uma pasta curta, por exemplo `C:\positivo-t2040b-reset`.
2. Abra a pasta `scripts-bat` e execute **`1-verificar-ambiente.bat`** com duplo clique. Ele confere o que falta.
3. Execute **`2-baixar-instalador.bat`**. São 1,5 GB de download. Ele confere o SHA-256 no final.
4. Execute **`3-extrair.bat`**. Extrai o `.pac` de 3,2 GB e as ferramentas.
5. Execute **`4-reflashar.bat`** e siga o que aparecer na tela. O tablet precisa estar **desligado** e você segura **Volume +** enquanto conecta o cabo.
6. Depois do primeiro boot, **não conecte o Wi-Fi ainda**. Execute **`5-pos-setup.bat`**, que bloqueia o provisionamento.
7. Com o tablet já configurado e com a depuração USB ligada, execute **`6-remover-apps.bat`** e **`7-ajustes.bat`**.

Se algo der errado em qualquer passo, o arquivo [docs/09-troubleshooting.md](docs/09-troubleshooting.md) tem a mensagem de erro exata com a solução.

Leitura recomendada antes de começar: [docs/00-guia-rapido.md](docs/00-guia-rapido.md).

---

## Estrutura do repositório

```
positivo-t2040b-reset/
├── README.md                     este arquivo
├── CHANGELOG.md                  histórico de versões
├── COMO-PUBLICAR.md              como subir para o GitHub
├── LICENSE                       MIT
├── docs/                         documentação completa
│   ├── 00-guia-rapido.md         o caminho feliz, sem enrolação
│   ├── 01-requisitos.md          o que você precisa ter e saber
│   ├── 02-diagnostico.md         como identificar o aparelho e o estado dele
│   ├── 03-driver-windows.md      o problema do driver no Windows 11
│   ├── 04-reflash.md             o reflash em detalhe
│   ├── 05-setup-offline.md       configuração sem internet e bloqueio do provisionamento
│   ├── 06-debloat.md             remoção dos apps de escola e de fábrica
│   ├── 07-performance.md         ajustes de desempenho
│   ├── 08-kit-emergencia.md      usando como aparelho reserva
│   ├── 09-troubleshooting.md     erros e soluções
│   ├── 10-anatomia-e-faq.md      hardware, partições, perguntas frequentes
│   ├── 11-zero-touch.md          o aviso de organização que volta sozinho
│   └── imagens/                  capturas de tela reais do processo
├── scripts/                      PowerShell, um por etapa
│   ├── lib-common.ps1            funções compartilhadas
│   ├── 00-verificar-ambiente.ps1
│   ├── 01-baixar-instalador.ps1
│   ├── 02-extrair-payload.ps1
│   ├── 03-reflash.ps1
│   ├── 04-bloquear-provisionamento.ps1
│   ├── 05-remover-apps.ps1
│   ├── 06-ajustes-performance.ps1
│   ├── 07-diagnostico.ps1
│   └── 99-restaurar-apps.ps1
├── scripts-bat/                  atalhos de duplo clique para quem não é dev
│   ├── 1-verificar-ambiente.bat
│   ├── 2-baixar-instalador.bat
│   ├── 3-extrair.bat
│   ├── 4-reflashar.bat
│   ├── 5-pos-setup.bat
│   ├── 6-remover-apps.bat
│   ├── 7-ajustes.bat
│   └── 9-restaurar-apps.bat
├── dados/                        listas e parâmetros usados pelos scripts
│   ├── pacotes-remover.txt       os 49 pacotes, com categoria e motivo
│   ├── pacotes-desativar.txt     os 3 que ficam desativados
│   ├── pacotes-nunca-remover.txt o que jamais pode sair
│   ├── ajustes-settings.txt      ajustes de sistema aplicados
│   └── dispositivo.md            ficha técnica e partições
├── ferramentas/                  onde colocar os binários grandes
│   └── LEIA-ME.md
└── logs/                         exemplos reais de saída, para comparação
    └── exemplos-de-logs.md
```

---

## O que não está no repositório (e por quê)

Binários grandes ficam de fora por tamanho e por não serem redistribuíveis:

| Arquivo | Tamanho | Como obter |
|---|---|---|
| `PositivoRescuerInstaller_T2040B_11178165.exe` | 1,49 GB | Script `01-baixar-instalador.ps1`, link oficial no documento [04-reflash.md](docs/04-reflash.md) |
| `Positivo_T2040B_V001_03312022.pac` | 3,18 GB | Extraído do instalador no script `02-extrair-payload.ps1` |
| `platform-tools` (ADB) | 10 MB | Script `00-verificar-ambiente.ps1` ou site oficial do Android |
| `7-Zip` | 2 MB | Script `00-verificar-ambiente.ps1` ou 7-zip.org |

O SHA-256 do instalador está registrado em [dados/dispositivo.md](dados/dispositivo.md) e é conferido automaticamente no download.

---

## Como o reflash funciona, em três frases

O instalador da Positivo é um envelope 7-Zip que carrega a ROM `.pac`, o gravador Unisoc `CmdDloader.exe` e o driver de comunicação. O gravador conversa com o Boot ROM do SC9863A pelo modo download, que roda antes do bootloader e por isso não obedece ao bloqueio dele. Em vez de usar o assistente gráfico da Positivo, que falha por um bug de detecção, chamamos o `CmdDloader.exe` direto com o `.pac` e a porta serial correta.

Detalhes completos em [docs/04-reflash.md](docs/04-reflash.md).

---

## Resultados esperados

Depois de rodar tudo, o aparelho fica assim:

| Antes | Depois |
|---|---|
| Travado no PIN, sem recuperação possível | Tela de boas-vindas do Android, sem bloqueio |
| 268 pacotes instalados | 219 pacotes |
| 12 apps de escola e de fábrica rodando | 0 apps de escola |
| Provisionamento Android Enterprise ativo | Bloqueado em três frentes |
| Animações em 1,0x | Animações em 0,5x |
| Varredura de Wi-Fi e Bluetooth em segundo plano | Desativada |
| 73 MB de RAM livre | Cerca de 1,2 GB disponível (cache do sistema incluído) |

---

## Licença

MIT. Use, copie, melhore, distribua. Só não venda como se tivesse escrito.

As marcas Positivo, Android, Unisoc e Google pertencem aos seus donos. Este é um trabalho independente, sem vínculo com a Positivo Tecnologia.
