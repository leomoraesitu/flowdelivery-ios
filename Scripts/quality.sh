#!/bin/bash

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚦 FlowDelivery Quality Gate"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

./Scripts/format.sh
./Scripts/lint.sh
./Scripts/build.sh
./Scripts/test.sh

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Quality Gate aprovado"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"