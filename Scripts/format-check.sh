#!/bin/bash

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

if ! command -v swiftformat >/dev/null 2>&1; then
    echo "❌ SwiftFormat não está instalado."
    echo "Execute: brew install swiftformat"
    exit 1
fi

echo "🔎 Verificando formatação..."

swiftformat --lint .

echo "✅ Formatação válida."