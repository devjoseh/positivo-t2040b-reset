# Zero-touch: o aviso que volta depois do reset

Este capitulo cobre a parte mais chata de lidar com tablet de projeto
educacional: o provisionamento Android Enterprise que aparece do lado do
servidor, mesmo depois de voce limpar tudo no aparelho.

Leia isso antes de concluir que o aparelho esta livre para sempre.

---

## O que aconteceu no caso real

Depois do reflash, o tablet foi configurado **sem internet**, e o bloqueio local
foi aplicado (documento 05). Tudo certo por algumas horas.

Quando o Wi-Fi foi ligado, apareceu esta notificacao:

```
Dispositivo gerenciado pelo administrador
A reinicializacao automatica sera feita em breve
```

Ela nao sai arrastando, nao tem botao de dispensar, e voltou depois de reiniciar.

---

## De onde ela vem

O `dumpsys notification` mostra a origem exata:

```
pkg=com.google.android.gms
tag=ZeroTouchForcedFactoryResetNotification
channel=ZeroTouchNotificationChannel
flags=0x2 (evento continuo)
```

Traduzindo: e o **Google Play Services** avisando que o aparelho esta registrado
num portal **zero-touch**, e que ele pretende forcar um reset para que a
inscricao aconteca na proxima configuracao.

Zero-touch e um recurso do Google em que o **numero de serie** do aparelho e
registrado no portal da instituicao, pelo revendedor ou pela secretaria. A
partir dai, toda vez que o aparelho e formatado e conectado a internet durante
a configuracao inicial, ele recebe a ordem de inscricao.

O registro vive **no servidor do Google**, nao no aparelho. Por isso limpar o
aparelho nao resolve.

---

## O que da e o que nao da para fazer

### Nao da: desativar os componentes do zero-touch

Os componentes existem:

```
com.google.android.gms/.enterprise.zerotouch.ui.FactoryResetActivity
com.google.android.gms/.enterprise.zerotouch.businesslogic.ZeroTouchGmsTaskService
com.google.android.gms/.auth.uiflows.factoryreset.PreFactoryResetActivity
```

Mas o comando falha:

```powershell
adb shell pm disable-user --user 0 com.google.android.gms/.enterprise.zerotouch.ui.FactoryResetActivity
```

Resultado:

```
java.lang.SecurityException: Shell cannot change component state for
com.google.android.gms/com.google.android.gms.enterprise.zerotouch.ui.FactoryResetActivity
```

O shell nao tem permissao para mexer em componente do Play Services.

### Nao da: remover o registro pelo aparelho

O registro esta no portal da instituicao. Nenhum comando local apaga.

### Nao da: impedir a notificacao desinstalando o GMS sem perder a Play Store

Ou voce tem Play Services inteiro, ou nao tem.

### Da: silenciar o canal

Esta e a solucao pratica, e foi a que funcionou.

1. Puxe a gaveta de notificacoes
2. Pressione e segure a notificacao
3. Toque na engrenagem do canal **"Notificacoes do registro sem toque"**
4. Desligue o canal

Ou por Ajustes, Apps, Google Play Services, Notificacoes.

O canal fica silenciado de forma permanente, e as outras notificacoes do Play
Services continuam funcionando.

Alternativa por ADB, que silencia todas as notificacoes do GMS:

```powershell
adb shell cmd notification suspend_package com.google.android.gms
```

Reverter:

```powershell
adb shell cmd notification unsuspend_package com.google.android.gms
```

### Da: descobrir se ele realmente pode apagar o aparelho

A pergunta que importa. Testes e respostas do caso real:

| Verificacao | Resultado |
|---|---|
| Permissao `MASTER_CLEAR` concedida ao GMS | ausente |
| Permissao `REBOOT` concedida ao GMS | ausente |
| Device owner ativo | nenhum |
| `FactoryResetActivity` na pilha | nao |
| Alarme de reset agendado | nao |
| Notificacao aparece com Wi-Fi desligado | sim, ou seja, e cache local |

Conclusao: **o GMS nao tem como executar o reset sozinho.** Para apagar ou
reiniciar o aparelho ele precisaria ser device owner ou ter permissao de
sistema, e nao tem nem uma coisa nem outra.

O aviso e uma intimacao, nao uma arma.

### Da: cortar a execucao com o bloqueio do documento 05

Com `com.android.managedprovisioning` desativado, mesmo que a ordem chegue, nao
existe processo capaz de aplicar a inscricao. Foi o que impediu o caso real de
virar gerenciamento de verdade.

---

## Os tres caminhos possiveis

### Caminho 1: conviver

O aparelho continua com conta Google, Play Store e Find My Device. O aviso pode
voltar de vez em quando, e voce ignora. Nunca faca reset de fabrica.

Regras de convivencia:

- Nao toque em nada que peca para reiniciar, apagar ou "concluir gerenciamento"
- Nao faca reset de fabrica
- Se aparecer tela cheia de "dispositivo precisa ser redefinido", chame alguem
  que entenda, nao toque

Indicadores de que a inscricao realmente aconteceu (ai sim e problema):

- Pedido de senha de politica, normalmente `0000`
- Aplicativos bloqueados sem motivo
- Texto fixo "gerenciado pela sua organizacao" nas configuracoes
- Impossibilidade de desinstalar aplicativos
- Impossibilidade de fazer reset

### Caminho 2: abandonar o GMS

```powershell
adb shell pm disable-user --user 0 com.google.android.gms
```

O zero-touch morre na hora, para sempre. O aparelho vira um Android comum.

O que se perde:

- Play Store
- Conta Google e sincronizacao
- Find My Device
- Notificacoes push de aplicativos

O que continua funcionando:

- Navegador (Chrome ainda abre, sem conta)
- VLC, galeria, camera, relogio, calculadora
- Instalacao manual de APK, se `install_non_market_apps` for 1
- Leitura, video local, musica local

Reverter:

```powershell
adb shell pm enable com.google.android.gms
```

### Caminho 3: pedir a remocao do registro

A unica cura definitiva. Quem controla o portal e a instituicao que registrou o
aparelho, normalmente a secretaria de educacao ou a escola.

O que pedir:

> Solicito a remocao do dispositivo de numero de serie XXXX do portal de
> registro sem toque (zero-touch enrollment), pois o aparelho foi desativado ou
> transferido.

Guarde o protocolo. Sem isso, o registro pode ficar ativo por anos no portal.

---

## Como testar depois de silenciar

1. Silencie o canal
2. Ligue o Wi-Fi
3. Aguarde de 5 a 10 minutos
4. Verifique:

```powershell
adb shell dumpsys device_policy | Select-String "Device Owner|admin="
adb shell pm list packages -3
adb shell dumpsys notification --noredact | Select-String "ZeroTouch"
```

O que significa cada resultado:

| Resultado | Interpretacao |
|---|---|
| notificacao silenciada e ausente | convivencia funcionando |
| notificacao de volta no log | canal nao pegou, repetir |
| device owner apareceu | inscricao aconteceu, reflash com offline |
| aplicativo de terceiro instalado sozinho | DPC baixado, reflash com offline |

---

## O que aprendemos com isso

1. Reset local nao remove registro de servidor. Sao camadas diferentes.
2. O aviso do zero-touch assusta mais do que pode. Ele informa, nao executa,
   quando o GMS nao e device owner.
3. O bloqueio que realmente funciona e o `managedprovisioning` desativado, e
   ele precisa ser feito **antes** de conectar rede.
4. Silenciar o canal e cosmeticamente definitivo e nao quebra nada.
5. A unica solucao completa e administrativa, nao tecnica.
