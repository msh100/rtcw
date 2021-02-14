RTCW Match Server
=================

This Docker image will download the required RTCW maps as specified in the
`MAPS` environment variable (from `REDIRECTURL`) and then spawn an OSP or
RtcwPro server with configuration as defined in the environment variables or
their defaults (refer below).

If you want to avoid downloading maps over HTTP(s), you can mount a volume of
maps to `/maps/`.
The container will first try to copy from pk3s from this directory before
attempting an HTTP(s) download.

All logs are written to STDOUT so can be viewed from `docker logs` or run
without the `-d` Docker run switch.

A server with this image will run v1.41b.

Example
-------

```
docker run -d \
  -p "10.0.0.1:27960:27960/udp" \
  -e "MAPS=adlernest_b3:te_escape2:te_frostbite" \
  -e "PASSWORD=war" \
  -e "REFEREEPASSWORD=pass123" \
  msh100/rtcw
```

Configuration Options
---------------------

Environment Variable | Description                    | Defaults
-------------------- | ------------------------------ | ------------------------
MAPS                 | List of maps seperated by ':'. | Default 6 maps
PASSWORD             | Server password.               | No password.
RCONPASSWORD         | RCON password.                 | No password (disabled).
REFEREEPASSWORD      | Referee password.              | No password (disabled).
HOSTNAME             | Server hostname.               | RTCW
STARTMAP             | Map server starts on.          | "mp_ice".
REDIRECTURL          | URL of HTTP downloads          | http://homie1337.bestmail.ws/rtcw/rtcw%20maps
MAP_PORT             | Container port (internal)      | 27960
NOQUERY              | Disable status queries         | Disabled, set to `true` to enable.
MAXCLIENTS           | Maximum number of players      | 32
CONF_MOTDA, CONF_MOTDB, CONF_MOTDC | MOTD lines on connect | Empty.
TIMEOUTLIMIT         | Maximum number of pauses per map side | 1
MOD                  | The mod to run, either `osp` or `rtcwpro`. | `osp`
PB_DISABLE           | Disable PB, set to any non-empty string to disable | Empty (PB enabled).
AUTO_UPDATE          | Download the `latest` RtcwPro release from Github on startup? | Disabled, set to `true` to enable.
SERVERCONF           | The value for RtcwPro's `g_customconfig` | `defaultcomp`.

Extra configuration can be prepended to the `server.cfg` by mounting a
configuration at `/home/game/extra.cfg`.
This is generally not recommended, try to use the variables above where
possible.


Todo
----

 - `main/qagamei386.so` and `wolfded.x86` come from my webserver. Is there a better source for these?
