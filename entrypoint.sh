#!/bin/bash

# Set config defaults
CONF_REDIR=${REDIRECTURL:-"http://homie1337.bestmail.ws/rtcw/rtcw%20maps"}
CONF_PORT=${MAP_PORT:-27960}
CONF_STARTMAP=${STARTMAP:-mp_ice}
CONF_HOSTNAME=${HOSTNAME:-RTCW OSP}
CONF_MAXCLIENTS=${MAXCLIENTS:-32}
CONF_PASSWORD=${PASSWORD:-""}
CONF_RCONPASSWORD=${RCONPASSWORD:-""}
CONF_REFPASSWORD=${REFEREEPASSWORD:-""}
CONF_TIMEOUTLIMIT=${TIMEOUTLIMIT:-1}

GAME_BASE="/home/game"

# Iterate over all maps and download them if necessary
export IFS=":"
for map in $MAPS; do
    if [ ! -f "${GAME_BASE}/main/${map}.pk3" ]; then
        echo "Attempting to download ${map}"
        wget -O "${GAME_BASE}/main/${map}.pk3" "${CONF_REDIR}/$map.pk3"
    fi
done

# We need to set g_needpass if a password is set
if [ "${CONF_PASSWORD}" != "" ]; then
    CONF_NEEDPASS='set g_needpass "1"'
fi

# Iterate over all config variables and write them in place
cp "${GAME_BASE}/main/server.cfg.tpl" "${GAME_BASE}/main/server.cfg"
for var in "${!CONF_@}"; do
    sed -i "s/%${var}%/${!var}/g" "${GAME_BASE}/main/server.cfg"
done
sed -i "s/%CONF_[A-Z]*%//g" "${GAME_BASE}/main/server.cfg"

# Preload libnoquery if we want to block status queries
if [ "${NOQUERY}" == "true" ]; then
    export LD_PRELOAD="${GAME_BASE}/libnoquery.so"
fi

# Exec into the game
exec "${GAME_BASE}/wolfded.x86" \
    +set dedicated 2 \
    +set fs_game osp \
    +set com_hunkmegs 512 \
    +set vm_game 0 \
    +set ttycon 0 \
    +set net_ip 0.0.0.0 \
    +set net_port ${CONF_PORT} \
    +set sv_maxclients ${CONF_MAXCLIENTS} \
    +exec server.cfg \
    +map ${CONF_STARTMAP} \
    $@
