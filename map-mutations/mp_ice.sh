#!/bin/bash

spawn_removals=('{
"classname" "team_CTF_bluespawn"
"spawnflags" "3"
"angle" "225"
"origin" "-7680 2264 376"
}'
'{
"classname" "team_CTF_bluespawn"
"angle" "315"
"spawnflags" "3"
"origin" "-8512 -656 376"
}'
'{
"origin" "-8640 -656 376"
"spawnflags" "3"
"angle" "315"
"classname" "team_CTF_bluespawn"
}'
'{
"origin" "-8304 -664 376"
"spawnflags" "3"
"angle" "270"
"classname" "team_CTF_bluespawn"
}'
'{
"classname" "team_CTF_bluespawn"
"angle" "270"
"spawnflags" "3"
"origin" "-8368 -664 376"
}'
'{
"origin" "-8576 -656 376"
"spawnflags" "3"
"angle" "315"
"classname" "team_CTF_bluespawn"
}'
'{
"classname" "team_CTF_bluespawn"
"angle" "315"
"spawnflags" "3"
"origin" "-8704 -656 376"
}'
)

# TODO: Create a remove_spawnpoint(), these are all vaguely the same changes
source=$1

for spawn_removal in "${spawn_removals[@]}"; do
    spawn_replacement="${spawn_removal/team_CTF_bluespawn/team_XXX_bluespawn}"
    bbe -e \
        "s/${spawn_removal}/${spawn_replacement}/" \
        "${source}" > \
        "${source}.tmp"
    mv "${source}.tmp" "${source}"
done
