#!/bin/bash
set -e

desiredrelease=$1
datapath=${datapath:-"/home/game"}
mkdir -p "${datapath}"

if [ -f "/rtcwpro/server.zip" ]; then
    filename="server.zip"
    cp "/rtcwpro/server.zip" "/tmp/server.zip"
else
    # Fetch release information
    wget -O "/tmp/rtcwpro.releases" \
        "https://api.github.com/repos/rtcwmp-com/rtcwPro/releases/${desiredrelease}"

    # Determine file name and source of RtcwPro
    asset="$(jq '.assets[] | select(.name | test("^rtcwpro_[0-9]+_server.+zip$"))' "/tmp/rtcwpro.releases")"
    filename="$(echo "${asset}" | jq -r '.name')"

    # Download and extract asset
    wget -qO "/tmp/${filename}" "$(echo "${asset}" | jq -r '.browser_download_url')"
fi

# Unzip the content of the RTCWPro repository
unzip "/tmp/${filename}" -d "${datapath}"

# Cleanup unwanted files
rm -rf \
    "/tmp/${filename}" \
    "${datapath}/rtcwpro/qagame_mp_x86.dll" \
    "${datapath}/libmysql.dll" \
    "${datapath}/wolfDED.exe" \
    "${datapath}/maps" \
    "${datapath}/configs" \
    "${datapath}/rtcwpro/"*.cfg \
    "/tmp/rtcwpro.releases"

chmod +x "${datapath}/wolfded.x86"
