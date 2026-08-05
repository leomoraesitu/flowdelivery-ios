#!/bin/bash

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

echo "🏗️ Executando build..."

xcodebuild \
    -project FlowDelivery.xcodeproj \
    -scheme FlowDelivery \
    -configuration Debug \
    -destination "generic/platform=iOS Simulator" \
    CODE_SIGNING_ALLOWED=NO \
    build

echo "✅ Build aprovado."