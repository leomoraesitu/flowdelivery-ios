#!/bin/bash

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

echo "🏗️ Executando build..."

DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-${TMPDIR:-/tmp}/FlowDeliveryDerivedData}"
mkdir -p "$DERIVED_DATA_PATH"

xcodebuild \
    -project FlowDelivery.xcodeproj \
    -scheme FlowDelivery \
    -configuration Debug \
    -destination "generic/platform=iOS Simulator" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    CODE_SIGNING_ALLOWED=NO \
    build

echo "✅ Build aprovado."
