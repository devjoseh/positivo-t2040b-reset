# Kit de emergencia

Como transformar o T2040B em um aparelho reserva util, do tipo que salva o dia
quando o celular principal e roubado, perdido ou quebra.

---

## O erro classico que anula o kit

Imagine: o celular e roubado. Voce pega o tablet reserva para entrar na sua
conta Google. O Google pede o codigo de dois fatores. O codigo chega no
aplicativo autenticador, que esta no celular roubado.

Pronto. O kit nao serve para nada.

A saida existe, e precisa ser preparada **antes**.

---

## Passo 0: codigos de backup, antes de qualquer login

1. Acesse `https://myaccount.google.com/security`
2. Entre em **Verificacao em duas etapas**
3. Clique em **Codigos de backup**
4. Gere ou visualize os 10 codigos
5. **Imprima ou escreva no papel**
6. Guarde **fora do tablet** e fora da carteira

Faca o mesmo para os servicos criticos:

| Servico | Onde ficam os codigos |
|---|---|
| Google | myaccount.google.com, Seguranca, Codigos de backup |
| Banco | secao de seguranca do internet banking |
| Redes sociais | configuracao de seguranca de cada uma |
| E-mail secundario | idem |

Sem isso, o resto do documento nao resolve o problema real.

---

## Passo 1: conta Google no tablet

Ajustes, Contas, Adicionar conta, Google.

Vai pedir aprovacao em dois fatores. Use o celular, ou um codigo de backup se
quiser testar o pior cenario de verdade.

Depois de entrar, confira em `https://myaccount.google.com/device-activity` se o
T2040B aparece na lista. E por ali que voce desconecta o aparelho remotamente se
ele for roubado.

### Vale a pena criar uma conta separada

Duas estrategias:

| Estrategia | Vantagem | Desvantagem |
|---|---|---|
| Usar a conta principal | um login so, tudo sincronizado | se o tablet for roubado, o ladrao tem acesso a mais coisas |
| Criar uma conta secundaria | isolamento | dados nao aparecem automaticamente no celular novo |

Para uso como reserva pessoal, a conta principal com PIN forte costuma ser mais
util. Para emprestar o aparelho, a conta secundaria e melhor.

---

## Passo 2: aplicativo autenticador

| Opcao | Vantagem | Desvantagem |
|---|---|---|
| Google Authenticator | sincroniza na nuvem, recupera em outro aparelho | depende da conta Google |
| Microsoft Authenticator | integra com contas Microsoft | mais pesado |
| Aegis Authenticator | open source, exportacao criptografada | backup manual |

Recomendacao para quem quer simplicidade com redundancia: **Google
Authenticator mais codigos de backup impressos**.

Depois de instalar:

1. Abra o aplicativo e migre ou cadastre as contas.
2. Se ele oferecer sincronizacao na nuvem, ative.
3. Se usar Aegis, exporte o arquivo criptografado e guarde em lugar separado.
4. Confira que cada servico critico tem **ou** codigo de backup **ou** o codigo
   no autenticador, de preferencia os dois.

---

## Passo 3: Find My Device

Ajustes, Seguranca, Find My Device, ativar.

Com isso voce pode, de outro aparelho:

- Localizar o tablet
- Fazer ele tocar
- Bloquear a tela
- Apagar todos os dados remotamente

Guarde o link: `https://www.google.com/android/find`

---

## Passo 4: aplicativos uteis de reserva

Ja vem instalados e servem bem:

| Aplicativo | Uso no kit |
|---|---|
| Gmail | ler e enviar e-mail |
| Keep | notas sincronizadas |
| Contatos | agenda de emergencia |
| Agenda | compromissos |
| Files | acessar arquivos |
| Gallery Go | fotos |
| VLC | midia local |
| Maps | navegacao, com mapa offline baixado |
| Mensagens | SMS, se um dia houver chip |

Falta configurar:

- **Mapas offline**: Maps, foto de perfil, Mapas off-line, escolher cidade.
  Baixe a sua e a de algum lugar que voce frequenta.
- **Contatos de emergencia**: Ajustes, Sobre o telefone, Informacoes de
  emergencia. Preencha para que apareçam na tela de bloqueio.

---

## Passo 5: teste de verdade

Nao pule. E o unico jeito de saber que funciona.

1. Desligue o celular principal.
2. No tablet, tente:
   - Abrir o Gmail e ler a caixa de entrada
   - Gerar um codigo de dois fatores de um servico qualquer
   - Entrar em uma conta usando um **codigo de backup** impresso
   - Abrir o Maps e navegar com o mapa offline
3. Anote o que falhou.

Se os quatro funcionarem, o kit esta pronto.

---

## Passo 6: rotina de manutencao

Aparelho esquecido na gaveta tem dois inimigos: bateria morta e software
desatualizado.

| Frequencia | O que fazer |
|---|---|
| A cada 3 ou 4 semanas | ligar, carregar ate cerca de 80 por cento, abrir a Play Store e atualizar os aplicativos |
| A cada 6 meses | conferir se os codigos de backup ainda existem, refazer se necessario |
| Uma vez por ano | revisar se ainda faz sentido manter o aparelho no kit |

Sobre a bateria: o ideal e guardar entre 40 e 80 por cento. Bateria em 100 por
cento parada por meses degrada. Bateria em 0 por cento por meses pode nao
acordar mais.

Sobre a rede: deixar o Wi-Fi ligado consome pouco em repouso e mantem o Find My
Device funcional. Se preferir economizar, desligue e lembre de religar na
manutencao mensal.

---

## Passo 7: fechar as portas

Coisas a fazer depois que tudo estiver configurado:

1. **Definir PIN de tela**: obrigatorio. Ajustes, Seguranca, Bloqueio de tela.
2. **Desligar a depuracao USB**: Ajustes, Sistema, Opcoes do desenvolvedor.
   Foi o canal usado durante todo o processo. Deixar ligado e conveniente para
   nos e para quem quiser invadir.
3. **Nao instalar aplicativo de banco**: o aparelho esta sem patch de seguranca
   desde fevereiro de 2022.
4. **Nao guardar documentos sensiveis** sem criptografia.
5. **Anotar o IMEI e o numero de serie** em local separado, para registro em
   caso de roubo.

---

## Sobre o risco de usar um aparelho sem patch

Seja realista:

| Uso | Risco |
|---|---|
| Conta Google, e-mail, notas, autenticador | baixo a moderado, sao aplicativos que se atualizam sozinhos |
| Navegacao em sites conhecidos | moderado, o navegador se atualiza |
| Aplicativo de banco | **nao recomendado**, depende de patch do sistema |
| Compras com cartao salvo | **nao recomendado** |

A regra pratica: o que atualiza sozinho e razoavelmente seguro. O que depende do
sistema operacional, nao.

---

## Checklist final

- [ ] Codigos de backup do Google impressos e guardados fora do tablet
- [ ] Conta Google logada no tablet
- [ ] Tablet aparece em myaccount.google.com/device-activity
- [ ] Autenticador instalado e com contas cadastradas
- [ ] Find My Device ativado
- [ ] Mapa offline baixado
- [ ] Contatos de emergencia preenchidos
- [ ] PIN de tela definido
- [ ] Depuracao USB desligada
- [ ] Teste dos quatro itens da secao 5 aprovado
- [ ] Rotina de recarga agendada
