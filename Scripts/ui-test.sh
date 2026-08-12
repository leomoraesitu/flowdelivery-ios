#!/bin/bash

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

SIMULATOR_NAME="${SIMULATOR_NAME:-iPhone 17}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-${TMPDIR:-/tmp}/FlowDeliveryDerivedData}"

mkdir -p "$DERIVED_DATA_PATH"

echo "🧪 Executando testes de UI no simulador: $SIMULATOR_NAME..."

xcodebuild \
    -project FlowDelivery.xcodeproj \
    -scheme FlowDelivery \
    -configuration Debug \
    -destination "platform=iOS Simulator,name=${SIMULATOR_NAME},OS=latest" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    -only-testing:FlowDeliveryUITests/FlowDeliveryUITests/testHomeScreenLoadsRestaurants \
    -parallel-testing-enabled NO \
    CODE_SIGNING_ALLOWED=NO \
    test

echo "✅ Testes de UI aprovados."
