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

Before pushing or opening a Pull Request:

```bash
./Scripts/quality.sh
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

Before PR:
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

## Status

Project foundation under development.
