# Wrapper to build the target_me_harder facilities

# List all target_me_harder facilities, and parse their scripts
CT_TARGET_ME_HARDER_FACILITY_LIST=
for f in "${CT_LIB_DIR}/scripts/build/target_me_harder/"*.sh; do
    _f="$(basename "${f}" .sh)"
    _f="${_f#???-}"
    __f="CT_TARGET_ME_HARDER_${_f}"
    if [ "${!__f}" = "y" ]; then
        CT_DoLog TARGET_ME_HARDER "Enabling target_me_harder '${_f}'"
        . "${f}"
        CT_TARGET_ME_HARDER_FACILITY_LIST="${CT_TARGET_ME_HARDER_FACILITY_LIST} ${_f}"
    else
        CT_DoLog TARGET_ME_HARDER "Disabling target_me_harder '${_f}'"
    fi
done

# Download the target_me_harder facilities
do_target_me_harder_get() {
    for f in ${CT_TARGET_ME_HARDER_FACILITY_LIST}; do
        do_target_me_harder_${f}_get
    done
}

# Extract and patch the target_me_harder facilities
do_target_me_harder_extract() {
    for f in ${CT_TARGET_ME_HARDER_FACILITY_LIST}; do
        do_target_me_harder_${f}_extract
    done
}

# Build the target_me_harder facilities
do_target_me_harder() {
    for f in ${CT_TARGET_ME_HARDER_FACILITY_LIST}; do
        do_target_me_harder_${f}_build
        rm -f "${CT_SYSROOT_DIR}/usr/lib/"*.la
    done
}

