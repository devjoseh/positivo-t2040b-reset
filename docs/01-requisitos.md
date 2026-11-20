# Requisitos e conceitos básicos

---

## Ambiente

### Computador

| Item | Mínimo | Recomendado |
|---|---|---|
| Sistema | Windows 10 | Windows 11 |
| Arquitetura | 64 bits | 64 bits |
| Espaço livre | 6 GB | 10 GB |
| Portas | 1 USB | 1 USB 2.0 dedicada |
| Privilégios | administrador | administrador |

O procedimento foi validado em Windows 11 build 26300, com Isolamento do Núcleo ativo. Windows 10 usa o mesmo caminho.

### Cabo

Deve ser cabo de **dados**. Cabos de carga não enumeram o aparelho no PC. Sintoma: o tablet carrega, mas `adb devices` permanece vazio e nenhum dispositivo novo aparece no Gerenciador de Dispositivos.

### Tablet

- Positivo T2040B
- Bateria acima de 40 por cento no início
- Sem necessidade de senha: o reflash remove o bloqueio

---

## Tempo por etapa

| Etapa | Tempo |
|---|---|
| Verificação de ambiente | 2 min |
| Download do instalador | 5 a 20 min |
| Extração | 1 a 3 min |
| Reflash | 10 min |
| Configuração inicial sem internet | 5 min |
| Bloqueio do provisionamento | 2 min |
| Remoção de aplicativos | 3 min |
| Ajustes | 1 min |
| **Total** | **30 a 45 min** |

---

## Conceitos

**Bootloader**: primeiro programa executado no aparelho. Verifica a integridade do sistema e decide o que iniciar. No T2040B está travado, ou seja, recusa gravação e remoção de partições.

**Recovery**: modo de manutenção separado do Android, com menu de reboot, atualização e logs. No T2040B não existe a opção de apagar dados.

**Fastboot**: protocolo de comunicação com o bootloader por USB. Permite gravar partições quando o bootloader está destravado. No T2040B existe, mas o bootloader recusa os comandos.

**Modo download (BROM)**: modo do chip Unisoc que executa antes do bootloader e não obedece ao bloqueio. É o caminho usado pelo reflash.

**BROM**: Boot ROM, memória interna do chip que recebe a imagem no modo download.

**FDL**: programa auxiliar carregado pelo BROM para comunicação com o PC. Vem dentro do `.pac`.

**`.pac`**: pacote da Unisoc com tabela de partições, imagens de sistema, boot, modem e os programas FDL. No T2040B ocupa 3,18 GB.

**ADB**: Android Debug Bridge. Canal de linha de comando para o Android em execução, usado para remover aplicativos e ler configurações.

**Fastboot stub**: quando o fastboot não implementa os comandos. É o caso do T2040B: `getvar` retorna vazio e todo comando `oem` responde `unknown cmd`.

**Android Enterprise**: sistema de gerenciamento corporativo do Android. Quando o aparelho "pertence a uma organização", recebe um aplicativo gerenciador com poderes de dono do dispositivo.

**HVCI / Isolamento do Núcleo**: recurso de segurança do Windows que impede a carga de drivers antigos ou sem assinatura válida. Foi o que bloqueou o driver da Unisoc.

---

## Riscos

1. O processo apaga todos os dados.
2. O aparelho não recebe atualização de segurança desde fevereiro de 2022. Aplicativos de banco não são recomendados.
3. Interromper a gravação pode exigir um segundo reflash. O modo download permanece acessível, então o aparelho raramente fica inutilizável.
4. Não usar ROM de outro modelo.
5. Não fazer reset de fábrica após a configuração. Reverte as remoções e o bloqueio. Detalhes em [05-setup-offline.md](05-setup-offline.md).

---

## Identificação do modelo

No recovery, o cabeçalho mostra a identificação:

```
android recovery
positivo/t2040/t2040b
11/R01005/URBR2022112901
user/release-keys
```

O campo relevante é `positivo/t2040/t2040b`. Valor diferente indica outro modelo.

Com o Android em execução:

```powershell
adb shell getprop ro.build.fingerprint
```

Resultado esperado para a build de fábrica de 2022:

```
positivo/T2040/T2040B:11/R01005/URBB2022033101:user/release-keys
```
