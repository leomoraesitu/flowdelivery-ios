# FlowDelivery iOS

App nativo de delivery, projeto de portfólio. Swift 6, SwiftUI, MVVM, Observation.
Repositórios ainda são fakes — Supabase não está integrado.

## Como trabalhar neste repositório

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
- Hooks versionados: `git config core.hooksPath .git-hooks` (pre-commit: format + lint; pre-push: quality gate completo).

## Arquitetura

- **`AppContainer` é o Composition Root** (`@MainActor @Observable`). Toda dependência nasce ali e é injetada explicitamente. Views que precisam criar outra feature recebem o container como parâmetro — a decisão de **não** usar `@Environment(AppContainer.self)` é consciente.
- As decisões de composição ficam em fábricas (`makeCredentialStore`, `makeOrderRepository`), não inline no `init` — ele tem limite de 50 linhas no SwiftLint.
- **Estado compartilhado:** `CartStore` e `SessionStore`, instância única por sessão do app. Single source of truth; features não duplicam nem sincronizam estado manualmente.
- **Design System:** tokens em `DesignSystem/Tokens` (`AppSpacing`, `AppTypography`, `AppColor`, `AppCornerRadius`, `AppIconSize`, `AppComponentSize`, `AppDuration`). Nenhum magic number em View.
- **Features** em `Features/<Feature>/` com `View`, `ViewModel`, `Models/`, `Components/`. Views propagam intenção; não mutam estado compartilhado diretamente.

## Qualidade

`./Scripts/quality.sh` = format-check + lint + test. Ele **não** chama `build.sh`: `xcodebuild test` já compila o app e os targets de teste.

- SwiftLint roda com `--strict` — warning derruba o gate. `line_length` 120, `function_body_length` 50.
- Simulador padrão `iPhone 17`; troque com `SIMULATOR_NAME="iPhone 17 Pro Max" ./Scripts/...`.
- **Nunca reintroduzir `CODE_SIGNING_ALLOWED=NO`** nos scripts de simulador. Sem assinatura o app não recebe o entitlement `application-identifier` e toda operação de Keychain falha com `errSecMissingEntitlement (-34018)`. Builds de simulador usam assinatura ad-hoc e não exigem credenciais no CI.

## CI

- `quality-gate.yml` (PR e push em `main`): só SwiftFormat + SwiftLint, em `macos-26`, ~15s. O job chama-se **`Static Analysis`** — é esse o nome no required status check da `main`.
- SwiftLint **não** vem na imagem arm64. É instalado pela composite action `.github/actions/setup-swiftlint`, com versão fixa e verificação de SHA-256. Não trocar por `latest`.
- `nightly-quality-gate.yml`: `quality.sh` completo, por cron e sob demanda. É a rede de segurança dos testes que saíram do PR.

## Testes

**Unitários** — Swift Testing (`struct` + `@Test`), com `@testable import FlowDelivery` como primeiro import.

Testes de Keychain usam `service` único por teste (UUID) e `defer { try? store.delete() }`: a suíte roda em paralelo e o Keychain do simulador sobrevive ao processo.

**UI tests** (XCTest) — rodam **apenas** por `./Scripts/ui-test.sh`; `test.sh` os pula com `-skip-testing`.

- Existe **um único `XCUIApplication()`** no target, dentro de `launchApp` (`extension XCTestCase`), que injeta `-ui-testing-in-memory-session-store`. Confira com `grep -rn "XCUIApplication()" FlowDeliveryUITests/` — mais de um resultado é bug.
- `makeHomeApp` é o único helper que faz login. Não repetir o toque em "Entrar" nos helpers que o consomem.
- Esperas por `UITestTimeout.standard` (15s). Timeout curto não acelera nada e gera falso-negativo sob carga.
- Comparações com texto formatado pelo sistema usam `.normalizingSpaces`: moeda pt-BR traz espaço não separável (U+00A0), e chaves localizadas interpoladas trazem isolados bidi (U+2068/U+2069). Vale também dentro do closure de `performAccessibilityAudit`.
- Queries ancoradas no container (`app.navigationBars[...]`, `app.sheets[...]`): labels se repetem entre toolbar e diálogo.
- `confirmationDialog` é apresentado como popover e **o botão `role: .cancel` não é renderizado** — o descarte é `dismissPopoverDialog(in:)`, via `PopoverDismissRegion`.
- Depois de mexer em helpers, rodar a suíte **duas vezes seguidas**: a segunda prova que não vazou estado entre execuções.

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

- `AuthService.login()` retorna sem lançar quando `repository.login()` devolve `nil`, e `AuthenticationViewModel` volta a `.idle` sem nenhum feedback de erro. Hoje o fake nunca devolve `nil`, mas um backend real devolverá nesse caso: deveria lançar um erro de credencial inválida.
- O botão "Entrar" não fica desabilitado durante `.loading`: um toque duplo dispara duas chamadas a `login()`.
- O alerta de falha de logout (`RootView`) não tem UI test: exigiria um argumento de launch com store que falha ao apagar. Hoje é coberto só por testes unitários do `RootViewModel`.
- `AppStartupViewModel` converte qualquer erro de `restoreSession()` em `.failed`; um erro real do Keychain (ex.: aparelho bloqueado) deveria cair no login.
- Se o backend devolver sessão renovada em `restoreSession`, ela ainda não é regravada no Keychain (o fake devolve a mesma).
- `CartItemRowView` deveria virar um elemento acessível combinado; enquanto isso há filtro de `.hitRegion` no audit do carrinho, com o motivo comentado no teste.
- Os `#Preview` instanciam `AppContainer()` real, portanto constroem um `KeychainSessionStore` real (hoje inofensivo, pois nenhum preview autentica).
- A suíte de UI (~13 min) não roda em nenhum gate automático.

## Estilo das respostas

Este projeto é conduzido como uma aula. Ao propor mudanças:

- Explique **por que**, não só o que fazer; passo a passo, um conceito por vez.
- Use a documentação oficial da Apple como fonte e cite os links.
- Antes de afirmar a causa de uma falha, **meça** — leia o log, a hierarquia de acessibilidade ou os code points. Hipótese sem evidência custa mais caro do que uma execução a mais.
- Não execute comandos destrutivos sem pedir.
