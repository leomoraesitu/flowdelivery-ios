#!/bin/bash

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

SIMULATOR_NAME="${SIMULATOR_NAME:-iPhone 17}"

echo "🧪 Executando testes no simulador: $SIMULATOR_NAME..."

xcodebuild \
    -project FlowDelivery.xcodeproj \
    -scheme FlowDelivery \
    -configuration Debug \
    -destination "platform=iOS Simulator,name=${SIMULATOR_NAME},OS=latest" \
    CODE_SIGNING_ALLOWED=NO \
    test

echo "✅ Testes aprovados."