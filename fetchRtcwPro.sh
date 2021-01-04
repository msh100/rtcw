#!/bin/bash
set -e

desiredrelease=$1

# Fetch release information
wget -O "/tmp/rtcwpro.releases" "https://api.github.com/repos/rtcw-nihi/ospx/releases/${desiredrelease}"

# Determine file name and source of RtcwPro
asset="$(jq '.assets[] | select(.name | test("^rtcwpro_[0-9]+_server.+zip$"))' "/tmp/rtcwpro.releases")"
filename="$(echo "${asset}" | jq -r '.name')"

# Download and extract asset
datapath=${datapath:-"/home/game/rtcwpro-data"}
mkdir -p "${datapath}"
wget -qO "/tmp/${filename}" "$(echo "${asset}" | jq -r '.browser_download_url')"
unzip "/tmp/${filename}" -d "${datapath}"

# Cleanup unwanted files
rm -rf \
    "/tmp/${filename}" \
    "${datapath}/rtcwpro/qagame_mp_x86.dll" \
    "/tmp/rtcwpro.releases"

chmod +x "${datapath}/wolfded.x86"
mv "${datapath}/wolfded.x86" "${datapath}/rtcwpro/wolfded.x86"
