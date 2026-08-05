#!/bin/bash

set -e

echo "🎨 Formatting..."
./Scripts/format.sh

echo "🔍 Linting..."
./Scripts/lint.sh

echo "🏗️ Building..."

xcodebuild \
-scheme FlowDelivery \
-destination 'platform=iOS Simulator,name=iPhone 17'

echo ""
echo "✅ Quality Gate Passed"