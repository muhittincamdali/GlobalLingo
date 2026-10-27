#!/bin/sh
# Builds fixtures/uikit-strings for the iOS simulator and takes the screenshots in
# docs/media/simulator/: the app in English and in Turkish, each with the archive alert open, so
# the README can show what the findings look like to a user. Needs a Mac with Xcode 27, an iOS 27
# simulator runtime and XcodeGen.
#
#   scripts/simulator-shots.sh
#
# It creates its own simulator ("GlobalLingo iPhone 17") and deletes it at the end, so other
# simulators are not touched.
set -eu

root="$(cd "$(dirname "$0")/.." && pwd)"
fixture="$root/fixtures/uikit-strings"
out="$root/docs/media/simulator"
work="$(mktemp -d)"
name="GlobalLingo iPhone 17"
bundle="dev.globallingo.fixtures.Inbox"

runtime="$(xcrun simctl list runtimes -j | python3 -c 'import json,sys; r=[x for x in json.load(sys.stdin)["runtimes"] if x["identifier"].startswith("com.apple.CoreSimulator.SimRuntime.iOS-27") and x["isAvailable"]]; print(r[-1]["identifier"] if r else "")')"
if [ -z "$runtime" ]; then
  echo "No iOS 27 simulator runtime; install it in Xcode > Settings > Components." >&2
  exit 1
fi

device="$(xcrun simctl create "$name" com.apple.CoreSimulator.SimDeviceType.iPhone-17 "$runtime")"
cleanup() {
  xcrun simctl shutdown "$device" > /dev/null 2>&1 || true
  xcrun simctl delete "$device" > /dev/null 2>&1 || true
  rm -rf "$work"
}
trap cleanup EXIT

(cd "$fixture" && xcodegen generate --quiet)
xcodebuild -project "$fixture/Inbox.xcodeproj" -scheme Inbox -configuration Debug \
  -destination "id=$device" -derivedDataPath "$work/derived" -quiet build
app="$work/derived/Build/Products/Debug-iphonesimulator/Inbox.app"

xcrun simctl boot "$device"
xcrun simctl bootstatus "$device" > /dev/null
xcrun simctl status_bar "$device" override --time 9:41 --batteryState charged --batteryLevel 100 \
  --cellularBars 4 --wifiBars 3
xcrun simctl install "$device" "$app"
mkdir -p "$out"

shot() {
  language="$1"
  locale="$2"
  xcrun simctl terminate "$device" "$bundle" > /dev/null 2>&1 || true
  xcrun simctl launch "$device" "$bundle" -AppleLanguages "($language)" -AppleLocale "$locale" \
    -ShowArchiveAlert > /dev/null
  sleep 4
  xcrun simctl io "$device" screenshot --type=png "$work/$language.png" > /dev/null 2>&1
  # Half size keeps the README light; the text stays readable.
  sips --resampleWidth 603 "$work/$language.png" --out "$out/inbox-$language.png" > /dev/null
  echo "docs/media/simulator/inbox-$language.png"
}

shot en en_US
shot tr tr_TR
xcodebuild -version | head -1
xcrun simctl list runtimes | grep "iOS 27"
