# Build script for the gdb debug facility

do_debug_gdb_parts() {
    do_gdb=

    if [ "${CT_GDB_CROSS}" = y ]; then
        do_gdb=y
    fi

    if [ "${CT_GDB_GDBSERVER}" = "y" ]; then
        do_gdb=y
    fi

    if [ "${CT_GDB_NATIVE}" = "y" ]; then
        do_gdb=y
    fi
}

do_debug_gdb_get() {
    local linaro_version
    local linaro_series
    local linaro_base_url="http://launchpad.net/gdb-linaro"

    # Account for the Linaro versioning
    linaro_version="$( echo "${CT_GDB_VERSION}"      \
                       |sed -r -e 's/^linaro-//;'   \
                     )"
    linaro_series="$( echo "${linaro_version}"      \
                      |sed -r -e 's/-.*//;'         \
                    )"

    do_debug_gdb_parts

    if [ "${do_gdb}" = "y" ]; then
        CT_GetFile "gdb-${CT_GDB_VERSION}"                          \
                   {ftp,http}://ftp.gnu.org/pub/gnu/gdb             \
                   ftp://sources.redhat.com/pub/gdb/{,old-}releases \
                   "${linaro_base_url}/${linaro_series}/${linaro_version}/+download"
    fi
}

do_debug_gdb_extract() {
    do_debug_gdb_parts

    if [ "${do_gdb}" = "y" ]; then
        CT_Extract "gdb-${CT_GDB_VERSION}"
        CT_Patch "gdb" "${CT_GDB_VERSION}"
    fi
}

do_debug_gdb_build() {
    local -a extra_config

    do_debug_gdb_parts

    gdb_src_dir="${CT_SRC_DIR}/gdb-${CT_GDB_VERSION}"

    # Version 6.3 and below behave badly with gdbmi
    case "${CT_GDB_VERSION}" in
        6.2*|6.3)   extra_config+=("--disable-gdbmi");;
    esac

    if [ "${CT_GDB_CROSS}" = "y" ]; then
        local -a cross_extra_config

        CT_DoStep INFO "Installing cross-gdb"
        CT_DoLog EXTRA "Configuring cross-gdb"

        mkdir -p "${CT_BUILD_DIR}/build-gdb-cross"
        cd "${CT_BUILD_DIR}/build-gdb-cross"

        cross_extra_config=("${extra_config[@]}")
        case "${CT_THREADS}" in
            none)   cross_extra_config+=("--disable-threads");;
            *)      cross_extra_config+=("--enable-threads");;
        esac

        CC_for_gdb=
        LD_for_gdb=
        if [ "${CT_GDB_CROSS_STATIC}" = "y" ]; then
            CC_for_gdb="gcc -static"
            LD_for_gdb="ld -static"
        fi

        gdb_cross_configure="${gdb_src_dir}/configure"

        CT_DoLog DEBUG "Extra config passed: '${cross_extra_config[*]}'"

        CT_DoExecLog CFG                                \
        CC="${CC_for_gdb}"                              \
        LD="${LD_for_gdb}"                              \
        "${gdb_cross_configure}"                        \
            --build=${CT_BUILD}                         \
            --host=${CT_HOST}                           \
            --target=${CT_TARGET}                       \
            --prefix="${CT_PREFIX_DIR}"                 \
            --with-build-sysroot="${CT_SYSROOT_DIR}"    \
            --disable-werror                            \
            "${cross_extra_config[@]}"

        CT_DoLog EXTRA "Building cross-gdb"
        CT_DoExecLog ALL make ${JOBSFLAGS}

        CT_DoLog EXTRA "Installing cross-gdb"
        CT_DoExecLog ALL make install

        CT_EndStep
    fi

    if [ "${CT_GDB_NATIVE}" = "y" ]; then
        local -a native_extra_config
        local -a gdb_native_CFLAGS

        CT_DoStep INFO "Installing native gdb"

        native_extra_config=("${extra_config[@]}")

        native_extra_config+=("--with-curses")
        native_extra_config+=("--with-expat")

        CT_DoLog EXTRA "Configuring native gdb"

        mkdir -p "${CT_BUILD_DIR}/build-gdb-native"
        cd "${CT_BUILD_DIR}/build-gdb-native"

        case "${CT_THREADS}" in
            none)   native_extra_config+=("--disable-threads");;
            *)      native_extra_config+=("--enable-threads");;
        esac

        if [ "${CT_GDB_NATIVE_STATIC}" = "y" ]; then
            CC_for_gdb="${CT_TARGET}-gcc -static"
            LD_for_gdb="${CT_TARGET}-ld -static"
        else
            CC_for_gdb="${CT_TARGET}-gcc"
            LD_for_gdb="${CT_TARGET}-ld"
        fi

        CT_DoLog DEBUG "Extra config passed: '${native_extra_config[*]}'"

        cp ../../config.cache .
        CT_DoExecLog CFG                                \
        CC="${CC_for_gdb}"                              \
        LD="${LD_for_gdb}"                              \
        CFLAGS="${gdb_native_CFLAGS[*]}"                \
        "${gdb_src_dir}/configure"                      \
            --build=${CT_BUILD}                         \
            --host=${CT_TARGET}                         \
            --target=${CT_TARGET}                       \
            --cache-file="$(pwd)/config.cache"          \
            --prefix=/usr                               \
            --with-build-sysroot="${CT_SYSROOT_DIR}"    \
            --without-uiout                             \
            --disable-tui                               \
            --disable-gdbtk                             \
            --without-x                                 \
            --disable-sim                               \
            --disable-werror                            \
            --without-included-gettext                  \
            --without-develop                           \
            "${native_extra_config[@]}"

        CT_DoLog EXTRA "Building native gdb"
        CT_DoExecLog ALL make ${JOBSFLAGS} CC=${CT_TARGET}-${CT_CC}

        CT_DoLog EXTRA "Installing native gdb"
        CT_DoExecLog ALL make DESTDIR="${CT_DEBUGROOT_DIR}" install

        # Building a native gdb also builds a gdbserver
        find "${CT_DEBUGROOT_DIR}" -type f -name gdbserver -exec rm -fv {} \; 2>&1 |CT_DoLog ALL

        CT_EndStep # native gdb build
    fi

    if [ "${CT_GDB_GDBSERVER}" = "y" ]; then
        local -a gdbserver_extra_config

        CT_DoStep INFO "Installing gdbserver"
        CT_DoLog EXTRA "Configuring gdbserver"

        mkdir -p "${CT_BUILD_DIR}/build-gdb-gdbserver"
        cd "${CT_BUILD_DIR}/build-gdb-gdbserver"

        # Workaround for bad versions, where the configure
        # script for gdbserver is not executable...
        # Bah, GNU folks strike again... :-(
        chmod +x "${gdb_src_dir}/gdb/gdbserver/configure"

        gdbserver_LDFLAGS=
        if [ "${CT_GDB_GDBSERVER_STATIC}" = "y" ]; then
            gdbserver_LDFLAGS=-static
        fi

        gdbserver_extra_config=("${extra_config[@]}")

        cp ../../config.cache .
        CT_DoExecLog CFG                                \
        LDFLAGS="${gdbserver_LDFLAGS}"                  \
        "${gdb_src_dir}/gdb/gdbserver/configure"        \
            --build=${CT_BUILD}                         \
            --host=${CT_TARGET}                         \
            --target=${CT_TARGET}                       \
            --cache-file="$(pwd)/config.cache"          \
            --prefix=/usr                               \
            --sysconfdir=/etc                           \
            --localstatedir=/var                        \
            --includedir="${CT_HEADERS_DIR}"            \
            --with-build-sysroot="${CT_SYSROOT_DIR}"    \
            --program-prefix=                           \
            --without-uiout                             \
            --disable-tui                               \
            --disable-gdbtk                             \
            --without-x                                 \
            --without-included-gettext                  \
            --without-develop                           \
            --disable-werror                            \
            "${gdbserver_extra_config[@]}"

        CT_DoLog EXTRA "Building gdbserver"
        CT_DoExecLog ALL make ${JOBSFLAGS} CC=${CT_TARGET}-${CT_CC}

        CT_DoLog EXTRA "Installing gdbserver"
        CT_DoExecLog ALL make DESTDIR="${CT_DEBUGROOT_DIR}" install

        CT_EndStep
    fi
}
