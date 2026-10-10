# FlowDelivery iOS

App nativo de delivery, projeto de portfólio. Swift 6, SwiftUI, MVVM, Observation.
Repositórios ainda são fakes — Supabase não está integrado.

## Como trabalhar neste repositório

**Leia `docs/ROTEIRO.md` no início de toda sessão**: ele traz a última aula concluída, a próxima, as pendências e as decisões que não devem ser revertidas. Atualize-o ao fim de cada aula. `./Scripts/lesson-prompt.sh` gera a partir dele o prompt de abertura da próxima aula e o copia para a área de transferência.

O fluxo é conduzido por `./Scripts/dev-flow.sh`, nunca por comandos git soltos:

```
./Scripts/dev-flow.sh start <tipo/nome>     # branch a partir da main
./Scripts/dev-flow.sh sync                  # sincroniza com origin/main
./Scripts/dev-flow.sh check                 # quality gate
./Scripts/dev-flow.sh commit "<mensagem>"   # Conventional Commit
./Scripts/dev-flow.sh publish "<título>"    # push + PR draft
./Scripts/dev-flow.sh ready                 # PR para Ready for review
./Scripts/dev-flow.sh finish                # limpeza pós-merge
```

Regras que não se negociam:

- **`git add` sempre com caminhos explícitos.** Nunca `git add .` — `commit.sh` não faz stage sozinho de propósito.
- **Conventional Commits** em inglês: `feat|fix|refactor|test|chore|docs|ci(escopo): descrição`.
- Descrição de PR em inglês, seguindo `.github/pull_request_template.md`.
- Hooks versionados: `git config core.hooksPath .git-hooks` (pre-commit: format + lint; pre-push: quality gate completo). **Nunca usar `--no-verify`**: se um hook falhar, corrija a causa.
- **Branch primeiro, arquivo depois:** crie a branch com `dev-flow.sh start` antes de criar ou editar qualquer arquivo.
- Não edite um arquivo que esteja aberto no Xcode ao mesmo tempo em que um script ou agente o altera.

## Arquitetura

- **`AppContainer` é o Composition Root** (`@MainActor @Observable`). Toda dependência nasce ali e é injetada explicitamente. Views que precisam criar outra feature recebem o container como parâmetro — a decisão de **não** usar `@Environment(AppContainer.self)` é consciente.
- As decisões de composição ficam em fábricas (`makeCredentialStore`, `makeOrderRepository`), não inline no `init` — ele tem limite de 50 linhas no SwiftLint.
- `AppContainer.init` recebe `credentialStore` por parâmetro (default `Self.makeCredentialStore()`), para que `#Preview` e testes possam injetar `FakeSessionCredentialStore()` explicitamente em vez de tocar no Keychain real. `makeCredentialStore()` e o `enum UITestLaunchArgument` são `nonisolated`: são só leitura de `ProcessInfo` e constantes `Sendable`, sem relação com o `@MainActor` da classe — e um valor-default de parâmetro de `init` roda fora do isolamento do tipo (não pode nem referenciar `Self`, só o nome concreto do tipo).
- Essa regra não é exclusiva de `init`: o módulo tem isolamento padrão de ator `@MainActor` — qualquer declaração sem anotação explícita herda isso, inclusive `struct`. Qualquer tipo usado como valor-default de parâmetro, de `init` ou de função comum, precisa ser `nonisolated` explicitamente para ser chamável ali, mesmo sem nenhuma relação com UI (ex.: `FakeRestaurantRepository`, usado em `makeSut(repository: RestaurantRepository = FakeRestaurantRepository())` de um teste). É seguro porque `nonisolated` só afrouxa a exigência — satisfaz uma conformância de protocolo potencialmente isolada (o inverso não).
- **Autenticação em camadas:** `AuthRepository` é a fronteira do backend (`login`, `logout`, `restoreSession(_:)`); `AuthService` orquestra repositório + credencial persistida + `SessionStore`; os ViewModels falam só com o serviço. `RootViewModel` é `@MainActor` (usa `CartStore` e `SessionStore`). `AuthService.login()` lança `AuthServiceError.loginRejected` quando o repositório não devolve sessão — nunca falha em silêncio. `restoreSession()` persiste a sessão devolvida pelo repositório antes de publicá-la no `SessionStore`, mesma ordem de `login()` ("persistir antes de publicar"): o backend pode renovar o token, e o Keychain não pode ficar atrás do estado em memória.
- **Estado compartilhado:** `CartStore` e `SessionStore`, instância única por sessão do app. Single source of truth; features não duplicam nem sincronizam estado manualmente.
- **Design System:** tokens em `DesignSystem/Tokens` (`AppSpacing`, `AppTypography`, `AppColor`, `AppCornerRadius`, `AppIconSize`, `AppComponentSize`, `AppDuration`). Nenhum magic number em View.
- **Features** em `Features/<Feature>/` com `View`, `ViewModel`, `Models/`, `Components/`. Views propagam intenção; não mutam estado compartilhado diretamente.

## Qualidade

`./Scripts/quality.sh` = format-check + lint + test. Ele **não** chama `build.sh`: `xcodebuild test` já compila o app e os targets de teste.

- SwiftLint roda com `--strict` — warning derruba o gate. `line_length` 120, `function_body_length` 50.
- `.swiftlint.yml` sobrescreve `modifier_order.preferred_modifier_order` para pôr `isolation` (`nonisolated`/`isolated`) depois de `acl`: o default do SwiftLint ordena ao contrário do default do SwiftFormat, e as duas ferramentas rodam no mesmo gate — sem o override, nenhuma ordem de `private nonisolated` satisfaz as duas ao mesmo tempo.
- Simulador padrão dos scripts: `iPhone 18 Pro Max` (Xcode 27, iOS 27) — é o mesmo usado no desenvolvimento. Para outro simulador: `SIMULATOR_NAME="iPhone 17" ./Scripts/...`.
- Se o `xcodebuild` reclamar de "multiple devices matched", há dois simuladores com o mesmo nome e SO: `xcrun simctl list devices available` e `xcrun simctl delete <UDID>` no que não é usado.
- **Nunca reintroduzir `CODE_SIGNING_ALLOWED=NO`** nos scripts de simulador. Sem assinatura o app não recebe o entitlement `application-identifier` e toda operação de Keychain falha com `errSecMissingEntitlement (-34018)`. Builds de simulador usam assinatura ad-hoc e não exigem credenciais no CI.

## CI

- `quality-gate.yml` (PR e push em `main`): só SwiftFormat + SwiftLint, em `macos-26`, ~15s. O job chama-se **`Static Analysis`** — é esse o nome no required status check da `main`.
- SwiftLint **não** vem na imagem arm64. É instalado pela composite action `.github/actions/setup-swiftlint`, com versão fixa e verificação de SHA-256. Não trocar por `latest`.
- `nightly-quality-gate.yml`: `quality.sh` completo, por cron e sob demanda. É a rede de segurança dos testes que saíram do PR.

## Testes

**Unitários** — Swift Testing (`struct`/`@Suite` + `@Test`, `#expect`), com `@testable import FlowDelivery` como primeiro import.

- TDD: teste vermelho primeiro. Valide com **prova de mutação** (quebre o código de produção e confirme que o teste falha).
- Use `#require` para pré-condições, de modo que o teste não passe vazio.
- Test doubles ficam em `FlowDeliveryTests/TestDoubles/` (`FailingDeleteStore`, `FailingSaveStore`, `FailingLoadStore`, `FailFirstSaveStore`, `FakeSessionCredentialStore`).

Testes de Keychain usam `service` único por teste (UUID) e `defer { try? store.delete() }`: a suíte roda em paralelo e o Keychain do simulador sobrevive ao processo.

**UI tests** (XCTest) — rodam por `./Scripts/ui-test.sh` (local ou nightly); `test.sh` os pula com `-skip-testing`.

- Existe **um único `XCUIApplication()`** no target, dentro de `launchApp` (`extension XCTestCase`), que injeta `-ui-testing-in-memory-session-store` e `UITestLaunchArgument.localization` (`-AppleLanguages (pt-BR)` / `-AppleLocale pt_BR`). Confira com `grep -rn "XCUIApplication()" FlowDeliveryUITests/` — mais de um resultado é bug. **Não remover a fixação de locale**: sem ela, moeda e layout de teclado variam com o idioma herdado pelo host no momento em que o simulador é criado (pt-BR num Mac configurado em português, `en-US` no runner do GitHub Actions) — já causou 30 falhas num nightly real antes de ser medido e corrigido.
- Fechar o teclado do endereço de entrega (`CheckoutView`) é `dismissKeyboard(in:)`, que toca no botão "Concluído" da barra de acessório do teclado (`ToolbarItemGroup(placement: .keyboard)`, ligado ao `@FocusState` existente). **Nunca** `typeText("...\n")` nem `app.keyboards.buttons["Return"].tap()`: o `TextField` é multilinha (`axis: .vertical`), então Return insere quebra de linha em vez de dar dismiss, e tocar fora do campo não resigna o foco de forma confiável (medido em runtime de simulador mais antigo: `app.keyboards.count` continuava `1` e o campo seguia "Keyboard Focused" depois do toque).
- `makeHomeApp` é o único helper que faz login. Não repetir o toque em "Entrar" nos helpers que o consomem. `openSignOutConfirmation(in:)` abre o menu "Conta" e o diálogo de saída.
- Esperas por `UITestTimeout.standard` (15s). Timeout curto não acelera nada e gera falso-negativo sob carga.
- Comparações com texto formatado pelo sistema usam `.normalizingSpaces`: moeda pt-BR traz espaço não separável (U+00A0), e chaves localizadas interpoladas trazem isolados bidi (U+2068/U+2069). Vale também dentro do closure de `performAccessibilityAudit`.
- Queries ancoradas no container (`app.navigationBars[...]`, `app.sheets[...]`): labels se repetem entre toolbar e diálogo.
- `confirmationDialog` é apresentado como popover e **o botão `role: .cancel` não é renderizado** — o descarte é `dismissPopoverDialog(in:)`, via `PopoverDismissRegion`.
- Depois de mexer em helpers, rodar a suíte **duas vezes seguidas**: a segunda prova que não vazou estado entre execuções.
- `.accessibilityElement(children: .combine)` funde os labels dos filhos num elemento novo (ex.: `"Pizza Margherita, R$ 49,90"`), mas **não** esconde os filhos originais da árvore que o XCUITest consulta — só o `.ignore` faz isso. Testar "o filho não existe mais" (`XCTAssertFalse(...exists)`) nunca fica verde. Teste o elemento combinado pelo `accessibilityIdentifier` dele (ver `CartItem.TitleAndPrice` em `CartItemRowView`), nunca pela ausência dos labels antigos.

## Segurança

- A sessão inteira (`UserSession`: `userID` + `accessToken`) vive em **um único item** do Keychain (`KeychainSessionStore`), serializada como JSON versionado (`StoredSession`). Nunca separar token e `userID` em armazenamentos diferentes (ex.: `UserDefaults`): eles precisam ser gravados e apagados juntos. A política é `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` **explícita** — a sessão é lida só na inicialização, em foreground, e credencial não deve migrar em restauração de backup.
- **Fail closed:** payload ilegível ou de versão desconhecida é apagado e tratado como "sem sessão". Só a decodificação é protegida: erros reais do Keychain propagam.
- `AuthService.logout()` sempre limpa o estado em memória (`defer`), mesmo se apagar a credencial falhar, e ainda propaga o erro.
- **Sair** é `RootViewModel.signOut()` (menu "Conta" na `HomeView` → `confirmationDialog`). Sempre esvazia o carrinho (também se a remoção da credencial falhar) e, em caso de falha, publica `signOutError`. O `alert` fica no `RootView`, **não** na Home: a Home desaparece na mesma transição que o erro ocorre. Rótulos distintos no menu ("Sair") e na confirmação ("Sair da conta") evitam ambiguidade nas queries de UI.
- Não existe (e não deve existir) método de produção que grave bytes arbitrários no item de sessão; testes de corrupção falam direto com `SecItem*` no target de testes.
- `save` usa `SecItemUpdate` com fallback para `SecItemAdd`: nunca existe instante em que a sessão foi apagada e a nova não foi gravada.
- Existe teste que verifica o atributo de acessibilidade do item. **Não remover** — é o que impede que a política seja enfraquecida em silêncio.
- Nunca logar `accessToken`.

## Dívidas conhecidas

- O `.disabled(.loading)` do botão "Entrar" não tem teste automatizado (nem de UI, nem unitário): `AuthService.login()` é síncrono hoje, então o estado `.loading` nunca chega a ser desenhado antes de virar `.idle`/`.error` — não há janela observável para capturar. A proteção passa a valer de verdade quando `login()` virar `async` contra um backend real; aí sim um UI test faria sentido.
- `AppStartupViewModel.start()` trata qualquer erro de `authService.restoreSession()` como "sem sessão" (cai no login). Hoje isso só pode vir do `KeychainSessionStore` fake, então a leitura "erro real de Keychain" é sempre verdadeira. Quando `AuthRepository.restoreSession` virar uma chamada de rede de verdade, um erro de rede vai cair no mesmo `catch` silencioso, sem distinguir "sem sessão" de "falha ao validar a sessão" — não dá pra tipar esse erro antes do backend existir.
- `nightly-quality-gate.yml` fixa `SIMULATOR_NAME: iPhone 17`, diferente do default local dos scripts (`iPhone 18 Pro Max`). A imagem `macos-26` do GitHub Actions ainda roda Xcode 26.6 (default) e seu catálogo de simuladores pré-instalados vai só até `iPhone 17 Pro Max`/`iPhone 17e` — não tem `iPhone 18 Pro Max`, nem SDK `iphoneos27`. Remedido em 2026-10-09 (`Image Version 20260824.0517.1`, mesma imagem de 2026-10-07 — ainda não houve publicação nova): sem mudança. A própria imagem já anuncia a [issue #14404](https://github.com/actions/runner-images/issues/14404) ("Xcode 27 is now available as a public preview"), aberta, sem Xcode 27 instalado ainda — é o sinal a observar para a próxima reconferência, em vez de remedir no escuro. Reconciliar quando a imagem do runner publicar Xcode 27 com o catálogo de simuladores correspondente.

## Estilo das respostas

Este projeto é conduzido como uma aula. Ao propor mudanças:

- Explique **por que**, não só o que fazer; passo a passo, um conceito por vez.
- Use a documentação oficial da Apple como fonte e cite os links.
- Antes de afirmar a causa de uma falha, **meça** — leia o log, a hierarquia de acessibilidade ou os code points. Hipótese sem evidência custa mais caro do que uma execução a mais.
- Não execute comandos destrutivos sem pedir; por padrão, **entregue os comandos e deixe o usuário executá-los**.
- Responda em português. Commits, PRs e Review em inglês.
- Cada aula segue: pré-voo (git) → conceito e decisões de design → passo a passo com TDD → commits → Definition of Done → o que NÃO fazer → pergunta de fixação.
- Um agente rodando em ambiente remoto (VM Linux) não tem `xcodebuild`, `swiftformat` nem `swiftlint`, e não deve rodar git no repositório local (já deixou `.git/index.lock` órfão): ali, edite arquivos e deixe o gate para a máquina do usuário.
