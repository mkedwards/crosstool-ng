# Build script for sqlite

do_sqlite_get() { :; }
do_sqlite_extract() { :; }
do_sqlite() { :; }
do_sqlite_target() { :; }

if [ "${CT_SQLITE}" = "y" -o "${CT_SQLITE_TARGET}" = "y" ]; then

do_sqlite_get() {
    CT_GetFile "sqlite-autoconf-${CT_SQLITE_VERSION}" .tar.gz    \
               http://www.sqlite.org
}

do_sqlite_extract() {
    CT_Extract "sqlite-autoconf-${CT_SQLITE_VERSION}"
    CT_Pushd "${CT_SRC_DIR}"
    CT_DoExecLog ALL mv "sqlite-autoconf-${CT_SQLITE_VERSION}" "sqlite-${CT_SQLITE_VERSION}"
    CT_Popd
    CT_Patch "sqlite" "${CT_SQLITE_VERSION}"
}

if [ "${CT_SQLITE}" = "y" ]; then

do_sqlite() {
    CT_DoStep INFO "Installing sqlite"
    mkdir -p "${CT_BUILD_DIR}/build-sqlite"
    CT_Pushd "${CT_BUILD_DIR}/build-sqlite"

    CT_DoLog EXTRA "Configuring sqlite"

    CT_DoExecLog CFG                                            \
    CC="${CT_HOST}-gcc"                                         \
    CFLAGS="-g -Os -fPIC -DPIC -DSQLITE_SECURE_DELETE -DSQLITE_ENABLE_FTS3 -DSQLITE_ENABLE_UNLOCK_NOTIFY" \
    "${CT_SRC_DIR}/sqlite-${CT_SQLITE_VERSION}/configure"       \
        --build=${CT_BUILD}                                     \
        --host=${CT_HOST}                                       \
        --target=${CT_TARGET}                                   \
        --prefix="${CT_PREFIX_DIR}"                             \
        --enable-threadsafe                                     \
        --enable-shared                                         \
        --enable-static
    # --enable-shared because nspr builds a shared library linked against sqlite

    CT_DoLog EXTRA "Building sqlite"
    CT_DoExecLog ALL make ${JOBSFLAGS}

    CT_DoLog EXTRA "Installing sqlite"
    CT_DoExecLog ALL make install

    CT_Popd
    CT_EndStep
}

fi # CT_SQLITE

if [ "${CT_SQLITE_TARGET}" = "y" ]; then

do_sqlite_target() {
    CT_DoStep INFO "Installing sqlite for the target"
    mkdir -p "${CT_BUILD_DIR}/build-sqlite-for-target"
    CT_Pushd "${CT_BUILD_DIR}/build-sqlite-for-target"

    CT_DoLog EXTRA "Configuring sqlite"
    cp ../../config.cache .
    CT_DoExecLog CFG                                            \
    CC="${CT_TARGET}-gcc"                                       \
    CFLAGS="-g -Os -fPIC -DPIC -DSQLITE_SECURE_DELETE -DSQLITE_ENABLE_FTS3 -DSQLITE_ENABLE_UNLOCK_NOTIFY" \
    "${CT_SRC_DIR}/sqlite-${CT_SQLITE_VERSION}/configure"       \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --target=${CT_TARGET}                                   \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --enable-shared                                         \
        --enable-static

    CT_DoLog EXTRA "Building sqlite"
    CT_DoExecLog ALL make ${JOBSFLAGS}

    CT_DoLog EXTRA "Installing sqlite"
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install

    CT_Popd
    CT_EndStep
}

fi # CT_SQLITE_TARGET

fi # CT_SQLITE || CT_SQLITE_TARGET
