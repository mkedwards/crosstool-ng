# Wrapper to build the cross_me_harder facilities

# List all cross_me_harder facilities, and parse their scripts
CT_CROSS_ME_HARDER_FACILITY_LIST=
for f in "${CT_LIB_DIR}/scripts/build/cross_me_harder/"*.sh; do
    _f="$(basename "${f}" .sh)"
    _f="${_f#???-}"
    __f="CT_CROSS_ME_HARDER_${_f}"
    if [ "${!__f}" = "y" ]; then
        CT_DoLog CROSS_ME_HARDER "Enabling cross_me_harder '${_f}'"
        . "${f}"
        CT_CROSS_ME_HARDER_FACILITY_LIST="${CT_CROSS_ME_HARDER_FACILITY_LIST} ${_f}"
    else
        CT_DoLog CROSS_ME_HARDER "Disabling cross_me_harder '${_f}'"
    fi
done

# Download the cross_me_harder facilities
do_cross_me_harder_get() {
    for f in ${CT_CROSS_ME_HARDER_FACILITY_LIST}; do
        do_cross_me_harder_${f}_get
    done
}

# Extract and patch the cross_me_harder facilities
do_cross_me_harder_extract() {
    for f in ${CT_CROSS_ME_HARDER_FACILITY_LIST}; do
        do_cross_me_harder_${f}_extract
    done
}

# Build the cross_me_harder facilities
do_cross_me_harder() {
    for f in ${CT_CROSS_ME_HARDER_FACILITY_LIST}; do
        do_cross_me_harder_${f}_build
        rm -f "${CT_SYSROOT_DIR}/usr/lib/"*.la
    done
}

