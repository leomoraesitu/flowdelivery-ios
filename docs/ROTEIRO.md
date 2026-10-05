# Roteiro do curso FlowDelivery iOS

Leia junto com `CLAUDE.md` (regras de trabalho, arquitetura, dívidas) e `README.md` (visão geral).
Atualize este arquivo ao fim de cada aula, no mesmo PR (ou em PR `docs:` logo depois).

## Estado
- Última aula concluída: 180
- Próxima: 181 — acessibilidade do CartItemRowView (remover exceções de hitRegion do
  audit do carrinho), ou outra dívida da lista (AppStartupViewModel colapsa erros do
  Keychain; UI suite sem gate automático)
- Ambiente: Xcode 27, simulador `iPhone 18 Pro Max` (iOS 27). Gates: `quality.sh` (unitários) e
  `ui-test.sh` (~13 min, manual).
- Pendente: PR fix/restaurant-details-title (correção guardada no stash
  "restaurant-details-title"; falta o UI test do título)

## Histórico
- 176: token no Keychain
- 177: sessão completa (UserSession/StoredSession) com userID estável (PR #178)
- 178: sair da conta na Home (RootViewModel.signOut) (PR #179)
- 179: remoção do ramo de logout inalcançável (PR #180)
- 180: robustez do login — AuthService.login() lança AuthServiceError.loginRejected
  em vez de retornar em silêncio; botão "Entrar" desabilitado em .loading (sem teste
  automatizado: login síncrono hoje não desenha a janela de .loading) (PR #182)

## Decisões que NÃO devem ser revertidas
- Sessão = um único item de Keychain (JSON versionado); nunca separar token e userID.
- Fail closed na leitura; só a decodificação é protegida, erros de Keychain propagam.
- Logout sempre limpa o estado em memória e o carrinho, mesmo se apagar a credencial falhar.
- O alerta de falha de logout fica no RootView (a Home some na transição).
- Rótulos distintos no menu ("Sair") e na confirmação ("Sair da conta").
- Diálogos aparecem como popover: nos UI tests usar dismissPopoverDialog.
- Testes devem ter pré-condições (#require) para não passar vazios; validar com mutação.
- `AuthService.login()` sempre lança quando o repositório não devolve sessão — nunca
  retornar em silêncio.

## Dívidas
Lista completa e atualizada em `CLAUDE.md` (seção "Dívidas conhecidas"). Candidatas às próximas
aulas: acessibilidade do carrinho (remover hitRegion do audit), `AppStartupViewModel` que
colapsa erros do Keychain, UI suite sem gate automático.

## Regras de execução
- O professor não executa nada sem o aluno pedir; entrega comandos e explica.
- Fonte: documentação oficial da Apple, com link.
- Commits, PR e Review em inglês; aulas em português.
- Meça antes de afirmar a causa de uma falha.

## Formato de cada aula
Pré-voo (git) → conceito e decisões de design → passo a passo com TDD →
commits em inglês → Definition of Done → o que NÃO fazer → pergunta de fixação.

## Ao concluir uma aula
1. `dev-flow.sh finish` após o merge.
2. Atualizar "Estado" e "Histórico" aqui.
3. Registrar novas decisões irreversíveis e novas dívidas (aqui e no `CLAUDE.md`).
