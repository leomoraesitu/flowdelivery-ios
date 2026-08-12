#!/bin/bash

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

if ! command -v swiftlint >/dev/null 2>&1; then
    echo "❌ SwiftLint não está instalado."
    echo "Execute: brew install swiftlint"
    exit 1
fi

echo "🔍 Executando SwiftLint..."

swiftlint lint \
    --strict \
    --no-cache \
    --config "$ROOT_DIR/.swiftlint.yml"

echo "✅ SwiftLint aprovado."
