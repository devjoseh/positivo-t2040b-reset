# Uso como dispositivo reserva

Procedimento para manter o T2040B funcional como segundo aparelho, com acesso à conta Google, autenticador e dados básicos.

---

## Dependência crítica

Se o celular principal for perdido e o tablet for o único segundo fator, o login na conta Google exigirá um código que está no aparelho perdido.

Para evitar o bloqueio, os códigos de backup precisam existir em meio físico, gerados antes de qualquer login no tablet.

---

## Passo 0: códigos de backup

1. Acessar `https://myaccount.google.com/security`
2. Entrar em **Verificação em duas etapas**
3. Abrir **Códigos de backup**
4. Gerar ou consultar os 10 códigos
5. Imprimir ou registrar em papel
6. Guardar fora do tablet e fora da carteira

Repetir para os serviços críticos:

| Serviço | Local |
|---|---|
| Google | myaccount.google.com, Segurança, Códigos de backup |
| Banco | seção de segurança do internet banking |
| Redes sociais | configuração de segurança de cada serviço |
| E-mail secundário | configuração de segurança |

---

## Passo 1: conta Google

Ajustes, Contas, Adicionar conta, Google.

A autenticação usará o celular principal ou um código de backup.

Após entrar, conferir em `https://myaccount.google.com/device-activity` se o aparelho aparece na lista. Esse é o ponto de remoção remota em caso de perda.

### Conta principal ou secundária

| Estratégia | Vantagem | Desvantagem |
|---|---|---|
| Conta principal | um login, dados sincronizados | acesso mais amplo em caso de roubo |
| Conta secundária | isolamento | dados não aparecem no aparelho novo |

---

## Passo 2: autenticador

| Opção | Vantagem | Desvantagem |
|---|---|---|
| Google Authenticator | sincronização em nuvem, recuperação em outro aparelho | depende da conta Google |
| Microsoft Authenticator | integração com contas Microsoft | mais pesado |
| Aegis Authenticator | código aberto, exportação criptografada | backup manual |

Recomendação: Google Authenticator com sincronização ativa, mais códigos de backup impressos.

Procedimento:

1. Instalar e abrir o aplicativo
2. Migrar ou cadastrar as contas
3. Ativar sincronização em nuvem, se disponível
4. No Aegis, exportar o arquivo criptografado e guardar separado
5. Confirmar que cada serviço crítico possui código de backup ou registro no autenticador

---

## Passo 3: Find My Device

Ajustes, Segurança, Find My Device, ativar.

Recursos disponíveis a partir de outro aparelho (`https://www.google.com/android/find`):

- Localizar
- Fazer tocar
- Bloquear a tela
- Apagar os dados

---

## Passo 4: aplicativos

Instalados de fábrica:

| Aplicativo | Uso |
|---|---|
| Gmail | e-mail |
| Keep | notas sincronizadas |
| Contatos | agenda |
| Agenda | compromissos |
| Files | arquivos |
| Gallery Go | fotos |
| VLC | mídia local |
| Maps | navegação, com mapa offline |
| Mensagens | SMS, se houver chip |

Configuração necessária:

- **Mapas offline**: Maps, foto de perfil, Mapas off-line, selecionar cidade
- **Informações de emergência**: Ajustes, Sobre o telefone, Informações de emergência

---

## Passo 5: validação

1. Desligar o celular principal
2. No tablet, verificar:
   - Abertura do Gmail
   - Geração de código de dois fatores
   - Login em um serviço usando código de backup impresso
   - Navegação com mapa offline
3. Registrar falhas

---

## Passo 6: manutenção

| Frequência | Ação |
|---|---|
| A cada 3 ou 4 semanas | ligar, carregar até 80 por cento, atualizar aplicativos na Play Store |
| A cada 6 meses | conferir a existência dos códigos de backup |
| Anualmente | revisar a necessidade de manter o aparelho |

Bateria: armazenar entre 40 e 80 por cento. Carga completa prolongada degrada a célula, e carga zero por período longo pode impedir o funcionamento.

Rede: manter o Wi-Fi ligado consome pouco em repouso e preserva o Find My Device. Desligar exige lembrar de religar na manutenção mensal.

---

## Passo 7: configuração de segurança

1. **PIN de tela**: Ajustes, Segurança, Bloqueio de tela
2. **Desativar depuração USB**: Ajustes, Sistema, Opções do desenvolvedor
3. Não instalar aplicativos de banco, por ausência de patch de segurança
4. Não armazenar documentos sensíveis sem criptografia
5. Registrar número de série e IMEI em local separado

---

## Risco de aparelho sem atualização

| Uso | Risco |
|---|---|
| Conta Google, e-mail, notas, autenticador | baixo a moderado, aplicativos recebem atualização própria |
| Navegação em sites conhecidos | moderado |
| Aplicativo de banco | não recomendado |
| Compras com cartão salvo | não recomendado |

Critério: o que atualiza por conta própria é razoavelmente seguro; o que depende do sistema operacional, não.

---

## Verificação final

- [ ] Códigos de backup do Google impressos e guardados fora do tablet
- [ ] Conta Google configurada
- [ ] Aparelho listado em myaccount.google.com/device-activity
- [ ] Autenticador instalado e com contas cadastradas
- [ ] Find My Device ativado
- [ ] Mapa offline baixado
- [ ] Informações de emergência preenchidas
- [ ] PIN de tela definido
- [ ] Depuração USB desativada
- [ ] Validação do passo 5 concluída
- [ ] Rotina de recarga definida
