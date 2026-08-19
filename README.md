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
- Supabase
- Swift Testing
- XCTest

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
./Scripts/quality.sh
./Scripts/start-branch.sh feat/example-branch
./Scripts/publish-pr.sh "feat(scope): short description"
```

### Development workflow

To start new work from the latest `main`:

```bash
./Scripts/start-branch.sh feat/short-description
```

Before committing:

```bash
./Scripts/format.sh
./Scripts/lint.sh
```

To run the complete Quality Gate manually at any time:

```bash
./Scripts/quality.sh
```

After committing the completed work, publish the branch and create a draft Pull Request:

```bash
./Scripts/publish-pr.sh "feat(scope): short description"
```

The command pushes only committed changes, runs the pre-push Quality Gate and creates a draft Pull Request.

If `origin/main` advanced while the branch was under development, update the branch before publishing:

```bash
git fetch origin
git rebase origin/main
```

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

```text
Pre-commit:
- format check
- lint

Pre-push:
- format check
- lint
- build
- unit tests

GitHub Actions:
- pull requests targeting main
- pushes to main
- format check
- lint
- build
- unit tests
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

By default, the publishing script expects the `leomoraesitu` account. To use another account, provide it explicitly:

```bash
EXPECTED_GITHUB_LOGIN="another-account" \
    ./Scripts/publish-pr.sh "feat(scope): short description"
```

## Status

Project foundation under development.
