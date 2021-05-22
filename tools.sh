#!/bin/bash

# Remove a spawnpoing from a BSP when given classname, angle, and origin
remove_spawnpoint() {
    file_name="$1"; shift
    classname="$1"; shift
    class="\"classname\" \"${classname}\""
    angle="\"angle\" \"$1\""; shift
    origin="\"origin\" \"$1\""; shift

    echo "Removing spawnpoint ${class} ${angle} ${origin}"

    # We want to fetch the whole spawnpoint block (content wrapped in {}). Data
    # in this block can come in any order. This regex will match for any
    # content within "{}" and then filter by class, angle, and spawnpoint in
    # any order. Only if all three match, a result will be returned. There
    # should only be one of zero blocks returned.
    no_close='[^}]+'
    match_start='({[^}]+'
    match_end="${no_close}})"
    inner_match="(${class}|${angle}|${origin})"
    inner_match="${inner_match}${no_close}${inner_match}${no_close}${inner_match}"
    match="${match_start}${inner_match}${match_end}"

    # Old versions of Grep need to treat binary files as text in order to
    # output data. We do this by using -a on grep. The output must also trim
    # null bytes.
    source="$(grep -Pzoa "${match}" "${file_name}" | tr -d '\000')"
    if [[ ! -z "${source}" ]]; then
        # TODO: We match and replace "CTF" for "XXX" in the classname. I do not
        # know if any other strings other than "CTF" appear in other maps.
        new_classname="${classname//[(CTF)]/X}"
        replacement="${source/$classname/$new_classname}"

        bbe -e \
            "s/${source}/${replacement}/" \
            "${file_name}" > \
            "${file_name}.tmp"
        mv "${file_name}.tmp" "${file_name}"
    fi
}

# We want to use this function within the mutation files, so export it.
export -f remove_spawnpoint
