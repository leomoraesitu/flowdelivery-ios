# FlowDelivery iOS

Native iOS implementation of FlowDelivery built with Swift, SwiftUI, MVVM and the Observation framework.

## About

This repository contains the native iOS version of FlowDelivery, developed as a portfolio project focused on Apple's development ecosystem and professional software engineering practices.

## Tech Stack

- Swift
- SwiftUI
- Swift Concurrency
- Observation
- MVVM
- Keychain Services
- Supabase (planned; repositories are currently fakes)
- Swift Testing
- XCTest

## Authentication and Session Security

The authenticated session is persisted so the user stays signed in across
launches:

- The whole `UserSession` (`userID` and access token) is stored in a **single**
  Keychain item as versioned JSON, so identity and credential cannot drift apart.
- Accessibility is `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`: the credential
  is readable only while the device is unlocked and is not migrated through
  backups. A test guards this attribute.
- Loading **fails closed**: an unreadable or unknown-version payload is deleted
  and treated as "no session". Real Keychain errors are propagated, never swallowed.
- Signing out always clears the in-memory state, even if removing the stored
  credential fails; the error is still surfaced to the caller.
- Keychain access requires the app to be code signed (simulator builds use
  ad-hoc signing). Do not disable signing in build scripts, for example with
  `CODE_SIGNING_ALLOWED=NO`: every Keychain call would fail with
  `errSecMissingEntitlement (-34018)`.

Signing out is available from the **Account** menu on the Home screen, behind a
confirmation dialog. It always empties the cart; if removing the stored
credential fails, an alert is shown from the root view (the Home screen is
gone by then).

UI tests run with an in-memory credential store (launch argument
`-ui-testing-in-memory-session-store`) so they never touch the real Keychain.

## Quality Tools

### Install the tools

```bash
brew install swiftformat
brew install swiftlint
brew install gh
```

### Enable versioned Git hooks

After cloning the repository, run:

```bash
git config core.hooksPath .git-hooks
chmod +x .git-hooks/*
chmod +x Scripts/*.sh
```

### Available commands

```bash
./Scripts/format.sh
./Scripts/format-check.sh
./Scripts/lint.sh
./Scripts/build.sh
./Scripts/test.sh
./Scripts/ui-test.sh
./Scripts/quality.sh
./Scripts/dev-flow.sh help
./Scripts/start-branch.sh feat/example-branch
./Scripts/sync-branch.sh
./Scripts/commit.sh "feat(scope): short description"
./Scripts/publish-pr.sh "feat(scope): short description"
./Scripts/ready-pr.sh
./Scripts/finish-branch.sh
./Scripts/lesson-prompt.sh
```

`lesson-prompt.sh` builds the opening prompt for the next course lesson from
`docs/ROTEIRO.md` and copies it to the clipboard (macOS `pbcopy`; use `--print`
to only display it).

### Recommended GitFlow

Use `dev-flow.sh` as the recommended entry point for the development flow:

```bash
./Scripts/dev-flow.sh start feat/short-description

git add <explicit-file-path>
./Scripts/dev-flow.sh commit "feat(scope): short description"

./Scripts/dev-flow.sh sync
./Scripts/dev-flow.sh check
./Scripts/dev-flow.sh publish "feat(scope): short description"
./Scripts/dev-flow.sh ready
./Scripts/dev-flow.sh finish
```

Use `--dry-run` to inspect the delegated command without executing it:

```bash
./Scripts/dev-flow.sh --dry-run start feat/short-description
```

Notes on what each delegated command does:

- `commit` validates the Conventional Commit message and the staged diff,
  then runs the versioned pre-commit hook. It never stages files itself.
- `publish` pushes only committed changes, runs the pre-push Quality Gate
  and creates or reuses an open Pull Request; new Pull Requests stay in
  draft until `ready`.
- `sync` rebases unpublished branches onto `origin/main`; published
  branches merge `origin/main` instead, to preserve remote history and
  avoid force-pushes. It never pushes automatically.
- `ready` confirms that the local branch, remote branch and Pull Request
  reference the same commit before marking it ready for review. It does
  not merge the Pull Request.
- `finish` verifies that the branch HEAD belongs to a merged Pull Request
  and that its squash commit is present on `origin/main`, then
  fast-forwards `main` and removes the local branch. It does not merge
  Pull Requests or delete remote branches.

The low-level scripts (`start-branch.sh`, `commit.sh`, `sync-branch.sh`,
`publish-pr.sh`, `ready-pr.sh`, `finish-branch.sh`) remain available for
focused maintenance and debugging — `dev-flow.sh` only delegates to them.

To use `flow` as a shortcut in the current shell while at the repository root:

```bash
alias flow='./Scripts/dev-flow.sh'
```

### Simulators

To list the available simulators:

```bash
xcrun simctl list devices available
```

To use another simulator for unit tests:

```bash
SIMULATOR_NAME="iPhone 17" ./Scripts/test.sh
```

To run the complete quality gate with another simulator:

```bash
SIMULATOR_NAME="iPhone 17" ./Scripts/quality.sh
```

To run the UI tests (not part of any automatic gate, roughly 13 minutes):

```bash
./Scripts/ui-test.sh
SIMULATOR_NAME="iPhone 17" ./Scripts/ui-test.sh
```

If `xcodebuild` reports that multiple devices matched the destination, two
simulators share the same name and OS version. Remove the unused one:

```bash
xcrun simctl list devices available
xcrun simctl delete <UDID>
```

### CI coverage

```text
Pre-commit:
- format check
- lint

Pre-push:
- format check
- lint
- unit tests (xcodebuild test also compiles the app)

GitHub Actions (Quality Gate - pull requests and pushes to main):
- format check
- lint

GitHub Actions (Nightly Quality Gate - scheduled and manual):
- format check
- lint
- unit tests

Not automated:
- UI tests (run manually with ./Scripts/ui-test.sh)
```

## Related Project

The original cross-platform Flutter implementation is available at:

[FlowDelivery Flutter](https://github.com/leomoraesitu/flowdelivery-app)

## Requirements

- macOS
- Xcode 27 or later (the project is developed with Xcode 27 and the iOS 27 SDK)
- iOS Simulator (the scripts default to `iPhone 18 Pro Max`; use `SIMULATOR_NAME` to choose another)
- SwiftFormat, SwiftLint and GitHub CLI (see [Quality Tools](#quality-tools))

### Authenticate GitHub CLI

Authenticate once after installing GitHub CLI:

```bash
gh auth login \
    --hostname github.com \
    --git-protocol https \
    --web
```

Confirm the active account:

```bash
gh auth status \
    --active \
    --hostname github.com

gh api user --jq '.login'
```

By default, the GitFlow automation scripts that access GitHub expect the
`leomoraesitu` account. To use another account throughout the workflow,
export it for the current terminal session:

```bash
export EXPECTED_GITHUB_LOGIN="another-account"
```

The exported account is reused by `publish-pr.sh`, `ready-pr.sh` and
`finish-branch.sh` in the same terminal session.

## Status

Under active development, built lesson by lesson. Implemented so far: authentication
with a persisted Keychain session, sign out, restaurant browsing, cart and checkout
flows, all on fake repositories. Supabase integration is still to come.

The lesson roadmap, current state and design decisions live in
[`docs/ROTEIRO.md`](docs/ROTEIRO.md); conventions for contributors and AI agents are in
[`CLAUDE.md`](CLAUDE.md).
