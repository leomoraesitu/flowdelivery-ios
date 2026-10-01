# FlowDelivery iOS

Native iOS implementation of FlowDelivery built with Swift, SwiftUI, MVVM and Supabase.

## About

This repository contains the native iOS version of FlowDelivery, developed as a portfolio project focused on Apple's development ecosystem and professional software engineering practices.

## Tech Stack

- Swift
- SwiftUI
- Swift Concurrency
- Observation
- MVVM
- Keychain Services
- Supabase
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

UI tests run with an in-memory credential store (launch argument
`-ui-testing-in-memory-session-store`) so they never touch the real Keychain.

## Quality Tools

### Requirements

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
```

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

The low-level scripts remain available for focused maintenance and debugging.

To use `flow` as a shortcut in the current shell while at the repository root:

```bash
alias flow='./Scripts/dev-flow.sh'
```

### Development workflow

To start new work from the latest `main`:

```bash
./Scripts/start-branch.sh feat/short-description
```

Stage only the intended files and create the commit through the helper:

```bash
git add <explicit-file-path>
./Scripts/commit.sh "feat(scope): short description"
```

The command validates the Conventional Commit message, checks the staged
diff and runs the versioned pre-commit hook. It never stages files itself.

To run the complete Quality Gate manually at any time:

```bash
./Scripts/quality.sh
```

After committing the completed work, publish the branch and create a draft Pull Request:

```bash
./Scripts/publish-pr.sh "feat(scope): short description"
```

The command pushes only committed changes, runs the pre-push Quality Gate
and creates or reuses an open Pull Request. Newly created Pull Requests
remain in draft until they are explicitly prepared for review.

If `origin/main` advances while the branch is under development, synchronize
the current branch before publishing:

```bash
./Scripts/sync-branch.sh
```

Unpublished branches are rebased onto `origin/main`. Published branches merge
`origin/main` to preserve their remote history and avoid force-pushes. The
command never pushes changes automatically.

After completing the Pull Request description and validation checklist,
wait for the required checks and move it to Ready for review:

```bash
./Scripts/ready-pr.sh
```

The command confirms that the local branch, remote branch and Pull Request
reference the same commit before marking the Pull Request as ready.
It does not merge the Pull Request.

After the Pull Request has been merged, remain on the completed local branch
and run:

```bash
./Scripts/finish-branch.sh
```

The command verifies that the exact branch HEAD belongs to a merged Pull
Request, confirms that its squash commit is present on `origin/main`,
updates the local `main` with a fast-forward merge and removes the
completed local branch. It does not merge Pull Requests or delete remote
branches.

To list the available simulators:

```bash
xcrun simctl list devices available
```

To use another simulator for unit tests:

```bash
SIMULATOR_NAME="iPhone 17 Pro Max" ./Scripts/test.sh
```

To run the complete quality gate with another simulator:

```bash
SIMULATOR_NAME="iPhone 17 Pro Max" ./Scripts/quality.sh
```

To run the UI tests (not part of any automatic gate, roughly 13 minutes):

```bash
./Scripts/ui-test.sh
SIMULATOR_NAME="iPhone 17 Pro Max" ./Scripts/ui-test.sh
```

If `xcodebuild` reports that multiple devices matched the destination, two
simulators share the same name and OS version. Remove the unused one:

```bash
xcrun simctl list devices available
xcrun simctl delete <UDID>
```

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

---

## Related Project

The original cross-platform Flutter implementation is available at:

[FlowDelivery Flutter](https://github.com/leomoraesitu/flowdelivery-app)

## Requirements

- macOS
- Xcode
- iOS Simulator

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

Project foundation under development.
