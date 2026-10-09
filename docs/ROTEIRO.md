# Roteiro do curso FlowDelivery iOS

Leia junto com `CLAUDE.md` (regras de trabalho, arquitetura, dívidas) e `README.md` (visão geral).
Atualize este arquivo ao fim de cada aula, no mesmo PR (ou em PR `docs:` logo depois).

## Estado
- Última aula concluída: 189
- Próxima: a definir (ver dívidas em `CLAUDE.md`) — as três dívidas conhecidas continuam
  bloqueadas: duas por Supabase ainda não integrado, uma pela imagem `macos-26` do GitHub
  Actions sem Xcode 27 (ver issue #14404 na dívida do CLAUDE.md).
- Ambiente: Xcode 27, simulador `iPhone 18 Pro Max` (iOS 27). Gates: `quality.sh` (unitários) e
  `ui-test.sh` (~13 min). Desde a aula 185, `ui-test.sh` também roda automaticamente no
  `nightly-quality-gate.yml` (cron diário + `workflow_dispatch`), contra `iPhone 17`.

## Histórico
- 176: token no Keychain
- 177: sessão completa (UserSession/StoredSession) com userID estável (PR #178)
- 178: sair da conta na Home (RootViewModel.signOut) (PR #179)
- 179: remoção do ramo de logout inalcançável (PR #180)
- 180: robustez do login — AuthService.login() lança AuthServiceError.loginRejected
  em vez de retornar em silêncio; botão "Entrar" desabilitado em .loading (sem teste
  automatizado: login síncrono hoje não desenha a janela de .loading) (PR #182)
- 181: removidas as exceções de `hitRegion` em `testCartPassesAccessibilityAudit`.
  Prova de mutação mostrou que `CartItemRowView` não precisa de
  `.accessibilityElement(children: .combine)` para passar o audit nesta toolchain
  (Xcode 27/iOS 27) — o comportamento de hit-testing de `Text` dentro de `List` mudou
  desde que a exceção foi criada (PR #176, ago/2026). Nenhuma mudança de produção;
  só a remoção da exceção obsoleta, com medição.
- 182: `AppStartupViewModel` passou a depender de `AuthService` diretamente (não
  mais do `AppContainer`), o que destravou testá-lo; erro real de Keychain em
  `restoreSession()` (ex.: aparelho bloqueado) agora cai no login em vez de um
  estado `.failed` sem consumidor na UI — `StartupState` perdeu esse case.
  Prova de mutação feita e revertida. README reconciliado: removida a seção
  "Development workflow", que duplicava o fluxo de `dev-flow.sh` com os scripts
  de baixo nível.
- 183: `RestaurantDetailsView` passou a mostrar o nome do restaurante como título de
  navegação (`navigationTitle` dinâmico, lido de `RestaurantDetailsState.loaded`), em vez
  do rótulo fixo "Restaurante". Fecha a pendência guardada no stash
  "restaurant-details-title" (o resto daquele stash já estava obsoleto, mesclado por
  outro caminho nas aulas 178–180). UI test `testRestaurantDetailsShowsRestaurantNameAsTitle`
  adicionado; prova de mutação feita (título fixo fez o teste falhar, confirmando que ele
  exerce o fix) e revertida.
- 184: `CartItemRowView` agrupa título e preço unitário num único elemento de
  acessibilidade (`.accessibilityElement(children: .combine)` + `accessibilityIdentifier
  ("CartItem.TitleAndPrice")`), fechando a dívida de VoiceOver ouvir duas paradas de swipe
  para uma informação só. Medição no meio do caminho: a hipótese inicial de teste
  (`XCTAssertFalse` na ausência dos labels antigos) nunca ficaria verde — `.combine` funde
  os labels no elemento novo mas não esconde os filhos da árvore que o XCUITest consulta
  (isso é `.ignore`, não `.combine`); a árvore de depuração (`app.debugDescription`) mostrou
  os `Text` originais ainda presentes como descendentes do elemento combinado. Teste corrigido
  para afirmar o elemento combinado pelo `accessibilityIdentifier`. `testCartPassesAccessibilityAudit`
  não precisou de ajuste: a auditoria continua endereçando os `Text` originais, que seguem
  existindo. Prova de mutação feita e revertida.
- 185: `nightly-quality-gate.yml` passou a rodar `./Scripts/ui-test.sh` depois de `quality.sh`
  (mesmo job, `DERIVED_DATA_PATH` reaproveitado; `timeout-minutes` 30 → 45), fechando a dívida
  "suíte de UI sem gate automático" (PR #187). Dois ciclos de medição, o primeiro incompleto:
  (1) Localmente contra `SIMULATOR_NAME="iPhone 17"` (Xcode 27, o mesmo instalado na máquina),
  12 falhas não reproduzidas em `iPhone 18 Pro Max`: 11 eram `app.keyboards.buttons["Return"].tap()`
  falhando a ação de acessibilidade "scroll to visible" (frame da tecla fora da janela visível
  nesse simulador menor) e 1 era Dynamic Type no header "Itens" de `OrderDetailsView` (não
  reflowa em tela mais estreita — adicionado à lista de exceções já usada em
  `testCartPassesAccessibilityAudit`). Troquei o toque na tecla por `typeText("...\n")`.
  (2) O primeiro `push` rodou o nightly de verdade no GitHub Actions (`DEVELOPER_DIR` apontando
  para Xcode 26.5 — mais antigo que o 27 local) e **30 de 39 testes falharam**, expondo duas
  causas que a medição local não cobria: nenhum `.xcscheme` do projeto está versionado, então
  nada fixa idioma/região do simulador — o runner nasce em `en-US` (moeda `"R$99.80"` em vez de
  `"R$ 99,80"`, tecla `"return"` em vez de `"retorno"`); e, mais grave, `typeText("...\n")` não
  resigna o foco do `TextField` multilinha (`axis: .vertical`) de `CheckoutView` no runtime do
  Xcode 26.5 — medido reproduzindo o mesmo runtime localmente via destino `iPhone 17 Pro`
  (`app.keyboards.count` continuava `1` e o `TextField` seguia "Keyboard Focused" no
  `app.debugDescription`, mesmo depois de tocar em outro elemento da tela). Correção: `launchApp`
  passou a fixar `-AppleLanguages (pt-BR)` / `-AppleLocale pt_BR` nos `launchArguments`; e
  `CheckoutView` ganhou um botão "Concluído" (`ToolbarItemGroup(placement: .keyboard)`) ligado ao
  `@FocusState` existente, porque **tocar fora de um `TextField` focado não garante dismiss** —
  é preciso um binding explícito. Suíte completa (39 testes) verde em `iPhone 17` (Xcode 27, duas
  vezes seguidas), `iPhone 17 Pro` (Xcode 26.5, duas vezes seguidas) e `iPhone 18 Pro Max`.
- 186: `AuthService.restoreSession()` passou a chamar `sessionCredentialStore.save(restored)`
  antes de `sessionStore.login(with: restored)`, espelhando a ordem já usada em `login()`
  ("persistir antes de publicar"). Fecha a dívida "sessão renovada pelo backend não era regravada
  no Keychain": antes, se `AuthRepository.restoreSession` devolvesse uma sessão diferente da
  armazenada (ex.: token renovado), o `SessionStore` em memória ficava à frente do Keychain, e um
  cold start seguinte voltaria a carregar a versão antiga. Teste novo
  (`restoreSessionPersistsTheSessionReturnedByTheBackend`) usa um double `RenewingAuthRepository`
  que devolve uma sessão com `accessToken` diferente do armazenado, mantendo o `userID` estável.
  Prova de mutação feita (comentar o `save` fez o teste falhar) e revertida. (PR #189)
- 187: UI test para o alerta de falha de logout (`RootView`). Novo tipo de produção
  `FailingDeleteSessionCredentialStore` (delega `load`/`save` a um
  `FakeSessionCredentialStore` interno; só `delete()` falha), ativado pelo launch
  argument `-ui-testing-failing-delete-session-store` em `AppContainer.makeCredentialStore()`,
  com prioridade sobre `-ui-testing-in-memory-session-store` (presente em todo UI test
  via `launchApp`). Fecha a dívida "alerta de falha de logout sem UI test" — o double
  de testes unitários (`FailingDeleteStore`) não é alcançável pelo binário que o UI
  test lança. Prova de mutação feita (invertendo a prioridade dos `if` em
  `makeCredentialStore()`, o teste falha) e revertida. Suíte completa (40 testes)
  verde em `iPhone 18 Pro Max`, duas vezes seguidas.
- 188: `AppContainer.init` passou a receber `credentialStore: SessionCredentialStore`
  por parâmetro (default `Self.makeCredentialStore()`), fechando a dívida
  "`#Preview` instanciam `AppContainer()` real e tocam o Keychain real". Os três
  `#Preview` de `HomeView` agora passam `FakeSessionCredentialStore()` explicitamente.
  Medição no meio do caminho: o primeiro valor-default proposto (`Self.makeCredentialStore()`)
  não compilou — dois erros reais do compilador: `Self` não pode ser referenciado numa
  expressão de valor-default (só o nome concreto do tipo pode), e o método estático,
  herdando `@MainActor` da classe, não pode ser chamado nesse contexto (que é sempre
  `nonisolated`, por não existir instância ainda). Corrigido com `AppContainer.makeCredentialStore()`
  no default e `nonisolated` no método; isso expôs mais dois erros, porque o
  `enum UITestLaunchArgument` (só constantes `String`) também herdava `@MainActor` por
  inferência de isolamento padrão do módulo — resolvido marcando o `enum` inteiro
  `nonisolated`. Novo teste `AppContainerTests.initUsesTheInjectedCredentialStore()`
  prova que o parâmetro chega até o `AuthService` interno (login grava na store injetada).
  Prova de mutação feita substituindo a store usada internamente por uma segunda instância
  de `FakeSessionCredentialStore` (não pelo Keychain real, para não gravar nada fora do
  processo de teste) e revertida. `./Scripts/dev-flow.sh check` expôs mais uma coisa: o
  default do SwiftLint (`modifier_order`) ordena `isolation` (nonisolated/isolated) antes
  do controle de acesso, e o default do SwiftFormat (`modifierOrder`) ordena o contrário —
  com a config anterior, `private nonisolated`/`nonisolated private` nunca satisfaria as
  duas ferramentas ao mesmo tempo. Nenhuma configuração do projeto cobria isso porque era
  o primeiro uso de `nonisolated` no código. Corrigido adicionando
  `modifier_order.preferred_modifier_order` em `.swiftlint.yml`, movendo `isolation` para
  depois de `acl` — alinhando o SwiftLint à convenção do SwiftFormat em vez do contrário.
  Gate completo (`./Scripts/dev-flow.sh check`) verde: formatação, lint e suíte de testes.
- 189: nenhuma das três dívidas conhecidas estava pronta para virar aula (as duas de
  autenticação dependem de Supabase integrado; a do simulador dependia da imagem do runner
  atualizar). Remedida a dívida do simulador em vez de presumi-la: consultado o README da
  imagem `macos-26` em `actions/runner-images` via `gh api` — `Image Version 20260824.0517.1`,
  a mesma de 2026-10-07, Xcode default ainda `26.6`, sem SDK `iphoneos27`, catálogo de
  simuladores parando em `iPhone 17 Pro Max`/`iPhone 17e`. Sem mudança a reconciliar em
  `nightly-quality-gate.yml`. Encontrada a issue
  [actions/runner-images#14404](https://github.com/actions/runner-images/issues/14404)
  ("Xcode 27 is now available as a public preview"), aberta, 23 comentários, sem Xcode 27
  instalado na imagem ainda — passa a ser o sinal concreto para a próxima reconferência, em
  vez de remedir no escuro a cada aula. Nenhum código de produção ou teste tocado; só
  documentação (`CLAUDE.md`, este arquivo).

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
- `AppStartupViewModel` depende de `AuthService`, nunca do `AppContainer` inteiro —
  ViewModels falam só com o serviço. Erro real de Keychain em `restoreSession()`
  cai no login, não num estado de falha sem consumidor na UI.
- `.accessibilityElement(children: .combine)` não esconde os filhos originais da árvore
  consultada pelo XCUITest — só funde os labels num elemento novo. Testes de elementos
  combinados afirmam o elemento novo pelo `accessibilityIdentifier`, nunca a ausência dos
  labels antigos.
- Exceções de Dynamic Type em testes de auditoria de acessibilidade (`dynamicTypeExceptions`)
  documentam texto/label que não reflowa em telas mais estreitas ou tamanhos maiores — não é
  regressão de produção a corrigir, é característica conhecida do header de Section do SwiftUI.
- UI tests fixam idioma/região do simulador em `launchApp`
  (`UITestLaunchArgument.localization` = `-AppleLanguages (pt-BR)` / `-AppleLocale pt_BR`):
  sem isso, moeda e layout de teclado variam com o locale herdado pelo host no momento em que o
  simulador é criado (pt-BR no Mac local, en-US no runner do GitHub Actions) — nunca depender do
  locale do host.
- Fechar o teclado de um `TextField` multilinha (`axis: .vertical`) usa o botão "Concluído" da
  barra de acessório do teclado (`ToolbarItemGroup(placement: .keyboard)` ligado ao
  `@FocusState`), nunca `typeText("...\n")` nem `app.keyboards.buttons["Return"].tap()`: Return
  insere quebra de linha num campo multilinha, e tocar fora do campo **não garante** resignar o
  foco (medido: `app.keyboards.count` permanecia `1` e o campo continuava "Keyboard Focused" após
  o toque, no runtime do Xcode 26.5). Só um binding explícito de `@FocusState` é confiável
  independente de runtime/tamanho de tela.
- `AuthService.restoreSession()` sempre persiste a sessão devolvida pelo repositório antes de
  publicá-la no `SessionStore`, na mesma ordem de `login()`: o backend pode renovar o token, e o
  Keychain não pode ficar atrás do estado em memória.
- `AppContainer.init` recebe `credentialStore` por parâmetro (nunca construído inline sem
  possibilidade de injeção): `#Preview` e testes usam `FakeSessionCredentialStore()`, nunca o
  Keychain real. Valor-default de parâmetro de `init` não pode referenciar `Self` (só o nome
  concreto do tipo) e roda fora do isolamento de ator do tipo — por isso `makeCredentialStore()`
  e o `enum UITestLaunchArgument` são `nonisolated`, mesmo a classe sendo `@MainActor`.
- `.swiftlint.yml` define `modifier_order.preferred_modifier_order` com `isolation`
  depois de `acl` (nunca o default do SwiftLint): o default do SwiftFormat ordena
  `nonisolated` depois do controle de acesso, e as duas ferramentas rodam no mesmo
  gate — sem esse override, `private nonisolated` nunca passa nas duas ao mesmo tempo.

## Dívidas
Lista completa e atualizada em `CLAUDE.md` (seção "Dívidas conhecidas").

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
