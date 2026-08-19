#!/bin/bash

set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

require_command() {
    local command_name="$1"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "❌ Dependência não encontrada: $command_name"
        exit 1
    fi
}

require_command git

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

require_command xcodebuild
require_command xcrun
require_command swiftformat
require_command swiftlint

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚦 FlowDelivery Quality Gate"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "🧰 Ambiente"
git --version
xcodebuild -version
echo "SwiftFormat $(swiftformat --version)"
echo "SwiftLint $(swiftlint version)"

echo ""
./Scripts/format-check.sh
./Scripts/lint.sh
./Scripts/build.sh
./Scripts/test.sh

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Quality Gate aprovado"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
