#!/bin/bash

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

SIMULATOR_NAME="${SIMULATOR_NAME:-iPhone 17}"

if ! command -v xcrun >/dev/null 2>&1; then
    echo "❌ Dependência não encontrada: xcrun"
    exit 1
fi

if ! AVAILABLE_SIMULATORS="$(xcrun simctl list devices available)"; then
    echo "❌ Não foi possível consultar os simuladores disponíveis."
    exit 1
fi

if [[ "$AVAILABLE_SIMULATORS" != *"    ${SIMULATOR_NAME} ("* ]]; then
    echo "❌ Simulador não encontrado: $SIMULATOR_NAME"
    echo "ℹ️ Consulte os destinos disponíveis com:"
    echo "xcrun simctl list devices available"
    echo "ℹ️ Selecione outro destino com:"
    echo "SIMULATOR_NAME=\"Nome do simulador\" ./Scripts/test.sh"
    exit 1
fi

echo "🧪 Executando testes no simulador: $SIMULATOR_NAME..."
echo "ℹ️ Testes de UI são executados separadamente; esta etapa valida a suíte unitária."

DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-${TMPDIR:-/tmp}/FlowDeliveryDerivedData}"
mkdir -p "$DERIVED_DATA_PATH"

xcodebuild \
    -project FlowDelivery.xcodeproj \
    -scheme FlowDelivery \
    -configuration Debug \
    -destination "platform=iOS Simulator,name=${SIMULATOR_NAME},OS=latest" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    -skip-testing:FlowDeliveryUITests \
    test

echo "✅ Testes aprovados."
