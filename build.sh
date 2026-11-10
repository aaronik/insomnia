#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
app="$(pwd)/build/Insomnia.app"
mkdir -p "$app/Contents/MacOS"
cp Insomnia/Info.plist "$app/Contents/Info.plist"
swiftc -parse-as-library -swift-version 6 -O -target "$(uname -m)-apple-macosx13.0" \
  Insomnia/AppDelegate.swift \
  -o "$app/Contents/MacOS/Insomnia"
codesign --force --sign - "$app"
printf 'Built %s\n' "$app"
