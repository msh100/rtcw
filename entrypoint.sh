#!/bin/bash

# Set config defaults
CONF_REDIR=${REDIRECTURL:-"http://rtcw.life/files/mapdb"}
CONF_PORT=${MAP_PORT:-27960}
CONF_STARTMAP=${STARTMAP:-mp_ice}
CONF_HOSTNAME=${HOSTNAME:-RTCW}
CONF_MAXCLIENTS=${MAXCLIENTS:-32}
CONF_PASSWORD=${PASSWORD:-""}
CONF_RCONPASSWORD=${RCONPASSWORD:-""}
CONF_REFPASSWORD=${REFEREEPASSWORD:-""}
CONF_TIMEOUTLIMIT=${TIMEOUTLIMIT:-1}
CONF_MOD=${MOD:-"osp"}
CONF_PB_DISABLE=${PB_DISABLE:-""}
CONF_SERVERCONF=${SERVERCONF:-"defaultcomp"}

GAME_BASE="/home/game"

source "${GAME_BASE}/tools.sh"

# Iterate over all maps and download them if necessary
export IFS=":"
for map in $MAPS; do
    if [ ! -f "${GAME_BASE}/main/${map}.pk3" ]; then
        echo "Attempting to download ${map}"
        if [ -f "/maps/${map}.pk3" ]; then
            echo "Map ${map} is sourcable locally, copying into place"
            cp "/maps/${map}.pk3" "${GAME_BASE}/main/${map}.pk3.tmp"
        else
            wget -O "${GAME_BASE}/main/${map}.pk3.tmp" "${CONF_REDIR}/$map.pk3"
        fi

        # This is the place we run mutations on the BSPs contained within maps.
        mkdir -p "${GAME_BASE}/tmp/"
        unzip "${GAME_BASE}/main/${map}.pk3.tmp" -d "${GAME_BASE}/tmp/"
        map_mutated=0

        # If an exploding barrel gibs a player, the server will crash.
        # To remedy this we remove all exploding barrels.
        if grep "props_flamebarrel" "${GAME_BASE}/tmp/maps/${map}.bsp"; then
            echo "props_flamebarrel found in ${map} - removing it."
            bbe -e \
                's/props_flamebarrel/props_flamebar111/' \
                "${GAME_BASE}/tmp/maps/${map}.bsp" > \
                "${GAME_BASE}/tmp/maps/${map}.bsp.tmp"
            mv "${GAME_BASE}/tmp/maps/${map}.bsp.tmp" \
                "${GAME_BASE}/tmp/maps/${map}.bsp"
            map_mutated=1
        fi

        # Check if a map mutations script exist for this map and execute it
        if [ -f "${GAME_BASE}/map-mutations/${map}.sh" ]; then
            echo "Running mutations script on ${map}"
            bash "${GAME_BASE}/map-mutations/${map}.sh" \
                "${GAME_BASE}/tmp/maps/${map}.bsp"
            map_mutated=1
        fi

        # If we have made mutations to the map file, then we should move the
        # new BSP into the osp maps directory (This is symlinked in for
        # RtcwPro within the main Dockerfile).
        if [[ "${map_mutated}" == "1" ]]; then
            mv "${GAME_BASE}/tmp/maps/${map}.bsp" \
                "${GAME_BASE}/osp/maps/${map}.bsp"
        fi

        rm -rf "${GAME_BASE}/tmp/"
        mv "${GAME_BASE}/main/${map}.pk3.tmp" "${GAME_BASE}/main/${map}.pk3"
    fi
done

# mp_ice is included as part of RTCW so we always run this mutation
# TODO: We should MD5 this as to not run this on every launch.
# TODO: There should be a list of BSPs included in base PK3s to interate over.
echo "Running mutations on mp_ice"
mkdir -p "${GAME_BASE}/tmp/"
unzip "${GAME_BASE}/main/mp_pakmaps1.pk3" -d "${GAME_BASE}/tmp/"
bash "${GAME_BASE}/map-mutations/mp_ice.sh" "${GAME_BASE}/tmp/maps/mp_ice.bsp"
mv "${GAME_BASE}/tmp/maps/mp_ice.bsp" "${GAME_BASE}/osp/maps/mp_ice.bsp"
rm -rf "${GAME_BASE}/tmp/"

# We need to set g_needpass if a password is set
if [ "${CONF_PASSWORD}" != "" ]; then
    CONF_NEEDPASS='set g_needpass "1"'
fi

# If PB_DISABLE is set, then let's not enable PB
if [ "${CONF_PB_DISABLE}" == "" ]; then
    CONF_PB='pb_sv_enable'
fi

# Iterate over all config variables and write them in place
cp "${GAME_BASE}/main/server.cfg.tpl" "${GAME_BASE}/main/server.cfg"
for var in "${!CONF_@}"; do
    value=$(echo "${!var}" | sed 's/\//\\\//g')
    sed -i "s/%${var}%/${value}/g" "${GAME_BASE}/main/server.cfg"
done
sed -i "s/%CONF_[A-Z]*%//g" "${GAME_BASE}/main/server.cfg"

# Appent extra.cfg if it exists
if [ -f "${GAME_BASE}/extra.cfg" ]; then
    cat "${GAME_BASE}/extra.cfg" >> "${GAME_BASE}/main/server.cfg"
fi

# Preload libnoquery if we want to block status queries
if [ "${NOQUERY}" == "true" ]; then
    export LD_PRELOAD="${GAME_BASE}/libnoquery.so"
fi

# Rtcwpro uses a different binary which is provided in their package
binary="${GAME_BASE}/wolfded.x86"
if [ "${CONF_MOD}" == "rtcwpro" ]; then
    if [ "${AUTO_UPDATE:-"0"}" == "true" ]; then
        # TODO: We need to add logic here to keep the newest version (be that
        # from the image or from a previous autoupdate) in the event that an
        # auto update fails.
        rtcwprobase="${GAME_BASE}/rtcwpro-autoupdate"
        datapath="${rtcwprobase}" bash "${GAME_BASE}/fetchRtcwPro.sh" "latest"
    else
        rtcwprobase="${GAME_BASE}/rtcwpro-data"
    fi

    ln -sf "${rtcwprobase}/rtcwpro/qagame.mp.i386.so" "${GAME_BASE}/rtcwpro/"
    ln -sf "${rtcwprobase}/rtcwpro/rtcwpro_"*.pk3 "${GAME_BASE}/rtcwpro/"
    binary="${rtcwprobase}/rtcwpro/wolfded.x86"
fi

# Exec into the game
exec "${binary}" \
    +set dedicated 2 \
    +set fs_game "${CONF_MOD}" \
    +set com_hunkmegs 512 \
    +set vm_game 0 \
    +set ttycon 0 \
    +set net_ip 0.0.0.0 \
    +set net_port ${CONF_PORT} \
    +set sv_maxclients ${CONF_MAXCLIENTS} \
    +set fs_basepath ${GAME_BASE} \
    +set fs_homepath ${GAME_BASE} \
    +exec server.cfg \
    +map ${CONF_STARTMAP} \
    $@
