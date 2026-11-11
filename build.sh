#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
app="$(pwd)/build/Insomnia.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
cp Insomnia/Info.plist "$app/Contents/Info.plist"
cp Resources/Insomnia.icns "$app/Contents/Resources/Insomnia.icns"
swiftc -parse-as-library -swift-version 6 -O -target "$(uname -m)-apple-macosx13.0" \
  Insomnia/AppDelegate.swift \
  -o "$app/Contents/MacOS/Insomnia"
codesign --force --sign - "$app"
printf 'Built %s\n' "$app"
