#!/usr/bin/env bash
(
set -e
cd "$(dirname "$0")/.."
WORKSPACE=${GITHUB_WORKSPACE:="$(pwd)"}
export WORKSPACE

function err {
    echo "$1" 1>&2
    return 1
}

echo "Verifying input parameters"

S2D_BUILD_NUMBER="$(echo "$S2D_BUILD_NAME." | cut -d. -f2 )"
[ "${APP_VERSION}" ] || err "AppVersion, required Action parameter is not set"
[ "${S2D_BUILD_NAME}" ] || err "Solar2DBuild, required action parameter is not set"
[ "${S2D_BUILD_NUMBER}" ] || err "Solar2DBuild, required action parameter has invalid format (i.e. 2020.3635)"
[ "${CERT_PASSWORD}" ] || err "CertPassword secret is required"
[ "${APPLE_USERNAME}" ] || err "AppleUser secret is required"
[ "${APPLE_PASSWORD}" ] || err "ApplePassword secret is required"
[ "${APPLE_TEAM_ID}" ] || echo "Warning AppleTeamId secret is not set. It is optional but may cause errors. To get your team ID run List Apple Teams workflow"

# Setting op code signing only on CI not to screw with local Keychain if run on own machine
if [ "$CI" ]
then
    echo "Seting up code signing"

    security delete-keychain build.keychain || true
    security create-keychain -p 'Password123' build.keychain
    security default-keychain -s build.keychain
    security import "Util/distribution.p12" -A -P "$CERT_PASSWORD"
    security unlock-keychain -p 'Password123' build.keychain
    security set-keychain-settings build.keychain
    security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k 'Password123' build.keychain > /dev/null
fi

S2D_DMG="Util/S2D-${S2D_BUILD_NUMBER}.dmg"
if [ ! -f "${S2D_DMG}" ]
then
    echo "Downloading Solar2D"
    curl -L "https://github.com/coronalabs/corona/releases/download/${S2D_BUILD_NUMBER}/Solar2D-macOS-${S2D_BUILD_NAME}.dmg" -o "${S2D_DMG}"
fi

hdiutil attach "${S2D_DMG}" -noautoopen -mount required -mountpoint Util/S2D

echo "Building the app"
BUILDER="Util/S2D/Corona-${S2D_BUILD_NUMBER}/Native/Corona/mac/bin/CoronaBuilder.app/Contents/MacOS/CoronaBuilder"
"$BUILDER" build --lua "Util/recipe.lua"

hdiutil detach Util/S2D
)