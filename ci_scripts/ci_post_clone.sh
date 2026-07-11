#!/bin/sh
# Xcode Cloud post-clone hook: this repo holds no Xcode project — it downloads the
# Unity-generated export pinned by build.env and unpacks it at the repo root, where
# the workflow expects Unity-iPhone.xcodeproj. (Unity runs on the Linux box; Xcode
# Cloud only compiles/signs. Git LFS isn't supported by Xcode Cloud and the export's
# 217 MB libiPhone-lib.a exceeds GitHub's plain-file limit, hence download-at-build.)
set -e
cd "$CI_PRIMARY_REPOSITORY_PATH"

RELEASE_TAG=$(sed -n 's/^RELEASE_TAG=//p' build.env)
[ -n "$RELEASE_TAG" ] || { echo "build.env has no RELEASE_TAG"; exit 1; }

echo "Fetching export $RELEASE_TAG…"
curl -fsSL -o /tmp/export.zip \
  "https://github.com/01010110k/NotWordle-releases/releases/download/${RELEASE_TAG}/Word99-Xcode.zip"
unzip -q /tmp/export.zip -d /tmp/export
rsync -a /tmp/export/Word99-Xcode/ ./
rm -rf /tmp/export /tmp/export.zip

# TestFlight requires a strictly increasing CFBundleVersion; Xcode Cloud's build
# number already is one, so stamp it over whatever the export shipped with.
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $CI_BUILD_NUMBER" Info.plist

# Export-compliance: standard HTTPS/TLS only = exempt. The Unity export already sets
# this (IosBuildPostProcess.cs); stamping it here too protects against export-side
# regressions. If the app ever adds custom crypto, flip to true + file compliance docs.
/usr/libexec/PlistBuddy -c "Set :ITSAppUsesNonExemptEncryption false" Info.plist 2>/dev/null \
  || /usr/libexec/PlistBuddy -c "Add :ITSAppUsesNonExemptEncryption bool false" Info.plist
echo "Ready: $(ls Unity-iPhone.xcodeproj >/dev/null && echo project ok), CFBundleVersion=$CI_BUILD_NUMBER"
