#!/bin/zsh
# 多语言截图：利用 DEBUG 启动参数直接打开指定语言、Tab 和功能页，无需 UI 交互。
#
# 用法：
#   Scripts/screenshots.sh <模拟器名称或 UDID> [输出目录] [语言...]
# 示例：
#   Scripts/screenshots.sh "iPhone 17 Pro" build/screenshots ar ja
#
# 页面列表见下方 PAGES，格式为 “tab:feature”，feature 为 Feature 的 rawValue。
set -euo pipefail

DEVICE=${1:?请指定模拟器名称或 UDID}
OUTPUT=${2:-build/screenshots}
shift $(( $# > 2 ? 2 : $# ))
LANGUAGES=(${@:-zh-Hans en ar de ja ru})
PAGES=(swiftui:basicText uikit:plurals swiftui:formatting uikit:bidiText uikit:rtlLayout swiftui:longText uikit:typography)
BUNDLE_ID=com.wenbo.WBLocalization
DERIVED=build/DerivedData

cd "$(dirname "$0")/.."
xcrun simctl boot "$DEVICE" 2>/dev/null || true
xcrun simctl bootstatus "$DEVICE" -b >/dev/null

echo "▸ 构建 App"
xcodebuild build -quiet -project WBLocalization.xcodeproj -scheme WBLocalization \
    -destination "platform=iOS Simulator,name=$DEVICE" -derivedDataPath "$DERIVED" 2>/dev/null \
  || xcodebuild build -quiet -project WBLocalization.xcodeproj -scheme WBLocalization \
    -destination "id=$DEVICE" -derivedDataPath "$DERIVED"
xcrun simctl install "$DEVICE" "$DERIVED/Build/Products/Debug-iphonesimulator/WBLocalization.app"

mkdir -p "$OUTPUT"
for language in $LANGUAGES; do
  for page in $PAGES; do
    tab=${page%%:*}; feature=${page##*:}
    xcrun simctl terminate "$DEVICE" "$BUNDLE_ID" 2>/dev/null || true
    # -AppleLanguages 仅对本次启动生效，不会改动 App 内保存的语言选择
    xcrun simctl launch "$DEVICE" "$BUNDLE_ID" -AppleLanguages "($language)" -WBDemoTab "$tab" -WBDemoFeature "$feature" >/dev/null
    sleep 3
    xcrun simctl io "$DEVICE" screenshot "$OUTPUT/${language}_${tab}_${feature}.png" >/dev/null 2>&1
    echo "✔ $language $tab $feature"
  done
done
