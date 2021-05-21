#!/bin/bash

spawn_removals=('{
"origin" "-5984 1880 224"
"angle" "360"
"classname" "team_CTF_redplayer"
}'
'{
"origin" "-5792 2016 224"
"angle" "270"
"classname" "team_CTF_redplayer"
}'
'{
"classname" "team_CTF_redplayer"
"angle" "360"
"origin" "-5920 1880 224"
}'
'{
"classname" "team_CTF_redplayer"
"angle" "270"
"origin" "-5792 1944 224"
}'
'{
"classname" "team_CTF_redplayer"
"angle" "360"
"origin" "-5920 1808 224"
}'
'{
"classname" "team_CTF_redplayer"
"angle" "90"
"origin" "-5848 1656 224"
}'
'{
"origin" "-5888 2016 224"
"angle" "270"
"classname" "team_CTF_redplayer"
}'
'{
"origin" "-5784 1656 224"
"angle" "90"
"classname" "team_CTF_redplayer"
}'
'{
"classname" "team_CTF_redplayer"
"angle" "90"
"origin" "-5912 1656 224"
}'
'{
"origin" "-5984 1656 224"
"angle" "60"
"classname" "team_CTF_redplayer"
}'
'{
"classname" "team_CTF_redplayer"
"angle" "35"
"origin" "-5912 1736 224"
}'
'{
"origin" "-5992 1760 224"
"angle" "25"
"classname" "team_CTF_redplayer"
}'
)

# TODO: Create a remove_spawnpoint(), these are all vaguely the same changes
source=$1

for spawn_removal in "${spawn_removals[@]}"; do
    spawn_replacement="${spawn_removal/team_CTF_redplayer/team_XXX_redplayer}"
    bbe -e \
        "s/${spawn_removal}/${spawn_replacement}/" \
        "${source}" > \
        "${source}.tmp"
    mv "${source}.tmp" "${source}"
done
