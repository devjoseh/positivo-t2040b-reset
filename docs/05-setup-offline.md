# Configuracao sem internet e bloqueio do provisionamento

Esta etapa e a diferenca entre um tablet livre e um tablet que volta a
"pertencer a uma organizacao" no primeiro acesso a rede.

Leia inteiro antes de ligar o aparelho.

---

## O que e esse aviso

Na tela de configuracao inicial, depois de conectar o Wi-Fi, pode aparecer:

```
Este dispositivo pertence a sua organizacao
```

Isso e **Android Enterprise**, o sistema de gerenciamento corporativo do
Android. Quando aparece, significa que o aparelho vai receber um aplicativo
gerenciador com poderes de dono do dispositivo. Uma vez aceito, o aparelho
passa a obedecer politicas remotas.

Existem duas origens possiveis:

| Origem | Como funciona | Reset resolve |
|---|---|---|
| Zero-touch do servidor Google | serial e IMEI registrados no portal da instituicao. A cada formatacao, com internet, o Google manda a ordem | nao, so a instituicao removendo o serial |
| Config local na ROM | um pacote de configuracao pre-instalado declara o dono | sim, se o pacote for neutralizado |

No T2040B educacional, a origem e **local**. Confirmado pela lista de pacotes:

```
package:android.autoinstalls.config.positivo.T2040B
```

Caminho: `/system/app/PlayAutoInstallConfig-br`.

---

## Como isso e disparado

O Android, na configuracao inicial, faz três verificacoes de provisionamento:
por NFC, por QR code e por pacotes de configuracao pre-instalados. A terceira
e a que interessa.

O pacote `android.autoinstalls.config.*` e lido pelo Google Play Services. O
executor da inscricao e o `com.android.managedprovisioning`. Sem rede, o Play
Services nao consegue consultar o servidor e a verificacao falha silenciosamente.

Por isso a regra: **configure sem internet primeiro, neutralize depois.**

---

## Procedimento

### Fase 1: configurar offline

1. Ligue o tablet e siga a configuracao inicial.
2. Na tela de rede, procure **Pular**, **Configurar depois** ou
   **Continuar sem rede**. Nao conecte Wi-Fi.
3. Pule conta Google. Escolha **Pular** ou **Agora nao**.
4. Em copiar dados do aparelho antigo, escolha **Nao, obrigado**.
5. Aceite os termos do Google normalmente.
6. Defina um PIN que voce lembre.
7. Chegue ate a area de trabalho.

**Se o aviso de organizacao aparecer mesmo offline**, pare. Significa que a
verificacao nao depende de rede, e nesse caso o tratamento e o mesmo da fase 2,
mas feito antes de qualquer conexao. Nesse caso o aparelho pode ficar em loop
na tela de inscricao, e a saida e reflashar e tentar de novo.

### Fase 2: neutralizar as tres frentes

Com o tablet na area de trabalho:

1. Ative as opcoes de desenvolvedor:
   Ajustes, Sobre o tablet, toque 7 vezes em **Numero da versao**.
2. Ative a depuracao USB:
   Ajustes, Sistema, Opcoes do desenvolvedor, **Depuracao USB**.
3. Conecte o cabo e aceite o aviso no tablet, marcando **Sempre permitir**.
4. Rode `scripts-bat/5-pos-setup.bat` ou os comandos abaixo.

```powershell
adb shell pm uninstall --user 0 android.autoinstalls.config.positivo.T2040B
adb shell pm disable-user --user 0 com.google.android.partnersetup
adb shell pm disable-user --user 0 com.android.managedprovisioning
```

### O que cada comando faz

| Pacote | Papel | Acao |
|---|---|---|
| `android.autoinstalls.config.positivo.T2040B` | declara o dono e a lista de apps de configuracao | removido para o usuario |
| `com.google.android.partnersetup` | motor que processa a lista de auto-instalacao | desativado |
| `com.android.managedprovisioning` | executor que efetivamente aplica o device owner | desativado |

O terceiro e o mais importante. Com ele desativado, **nenhuma** inscricao
corporativa pode ser aplicada, nem por ordem remota, porque nao existe processo
capaz de executar.

### Fase 3: verificar

```powershell
# nao deve haver dono nem administrador
adb shell dumpsys device_policy | Select-String "Device Owner|admin=|provisioningState"

# os tres devem aparecer como desativados ou ausentes
adb shell pm list packages -d

# o pacote de configuracao nao deve existir mais
adb shell pm list packages | Select-String "autoinstall"
```

Esperado:

```
provisioningState: 0
mPasswordOwner=-1

package:com.android.nfc
package:com.google.android.partnersetup
package:com.android.managedprovisioning
```

### Fase 4: conectar a internet e confirmar

1. Conecte o Wi-Fi.
2. Espera de 3 a 5 minutos.
3. Recheque:

```powershell
adb shell dumpsys device_policy | Select-String "Device Owner|admin="
adb shell pm list packages -3
```

Se continuar sem dono e sem aplicativos de terceiros instalados, o aparelho
esta livre.

---

## Se o aparelho exigir internet obrigatoriamente

Algumas builds nao deixam pular a rede. Solucao: oferecer uma rede **sem
internet de verdade**.

1. No celular, desligue os dados moveis.
2. Ative o roteamento Wi-Fi (hotspot).
3. Conecte o tablet nesse hotspot.
4. O Android tenta falar com o Google, falha, e libera a opcao de continuar
   mesmo assim.
5. Termine a configuracao e siga para a fase 2.

Sem internet real, o Play Services nao consegue consultar o servidor de
provisionamento.

---

## Aviso sobre reset de fabrica

Depois de tudo pronto, **nao faca reset de fabrica**. Isso:

- Reinstala os aplicativos da escola
- Reativa o `managedprovisioning` e o `partnersetup`
- Traz o pacote de configuracao de volta
- Reverte todas as remocoes de apps
- Reverte os ajustes de desempenho

Se um dia precisar formatar de novo, o caminho e o mesmo deste repositorio:
reflash, configuracao offline, bloqueio, limpeza. Nao existe atalho.

---

## Restaurar o provisionamento, se um dia precisar

Caso o aparelho volte para uma instituicao, os comandos sao reversiveis:

```powershell
adb shell cmd package install-existing android.autoinstalls.config.positivo.T2040B
adb shell pm enable com.google.android.partnersetup
adb shell pm enable com.android.managedprovisioning
```

Faz sentido apenas se voce estiver devolvendo o aparelho a quem e de direito.
