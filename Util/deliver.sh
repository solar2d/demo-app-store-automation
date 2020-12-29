#!/usr/bin/env bash
(
set -e

echo "Uploading the app"
if [ -z "${APPLE_TEAM_ID}" ]
then
    xcrun altool --upload-app --type=ios -f Util/*.ipa -u "${APPLE_USERNAME}" -p "${APPLE_PASSWORD}" -asc_provider "${APPLE_TEAM_ID}"
else
    xcrun altool --upload-app --type=ios -f Util/*.ipa -u "${APPLE_USERNAME}" -p "${APPLE_PASSWORD}"
fi
)
