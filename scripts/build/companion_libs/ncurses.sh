# Build script for ncurses

do_ncurses_get() { :; }
do_ncurses_extract() { :; }
do_ncurses() { :; }
do_ncurses_target() { :; }

if [ "${CT_NCURSES}" = "y" -o "${CT_NCURSES_TARGET}" = "y" ]; then

do_ncurses_get() {
    CT_GetFile "ncurses-${CT_NCURSES_VERSION}" .tar.gz  \
               {ftp,http}://ftp.gnu.org/pub/gnu/ncurses \
               ftp://invisible-island.net/ncurses
}

do_ncurses_extract() {
    CT_Extract "ncurses-${CT_NCURSES_VERSION}"
    CT_DoExecLog ALL chmod -R u+w "${CT_SRC_DIR}/ncurses-${CT_NCURSES_VERSION}"
    CT_Patch "ncurses" "${CT_NCURSES_VERSION}"
}

if [ "${CT_NCURSES}" = "y" ]; then

do_ncurses() {
    CT_DoStep INFO "Installing ncurses"
    mkdir -p "${CT_BUILD_DIR}/build-ncurses"
    CT_Pushd "${CT_BUILD_DIR}/build-ncurses"

    CT_DoLog EXTRA "Configuring ncurses"

    # Use build = CT_REAL_BUILD so that configure thinks it is
    # cross-compiling, and thus will use the ${CT_BUILD}-*
    # tools instead of searching for the native ones...
    CT_DoExecLog CFG                                            \
    "${CT_SRC_DIR}/ncurses-${CT_NCURSES_VERSION}/configure"     \
        --build=${CT_BUILD}                                     \
        --host=${CT_BUILD}                                      \
        --prefix="${CT_BUILDTOOLS_PREFIX_DIR}"                  \
        --with-build-cc=${CT_REAL_BUILD}-gcc                    \
        --with-build-cpp=${CT_REAL_BUILD}-gcc                   \
        --with-build-cflags="${CT_CFLAGS_FOR_HOST}"             \
        --without-libtool                                       \
        --without-pkg-config                                    \
        --disable-rpath                                         \
        --enable-echo                                           \
        --enable-const                                          \
        --without-gpm                                           \
        --enable-symlinks                                       \
        --disable-lp64                                          \
        --with-chtype='long'                                    \
        --with-mmask-t='long'                                   \
        --disable-termcap                                       \
        --without-profile                                       \
        --without-debug                                         \
        --with-normal                                           \
        --without-shared                                        \
        --without-ticlib                                        \
        --without-ada

    CT_DoLog EXTRA "Building ncurses"
    CT_DoExecLog ALL make

    CT_DoLog EXTRA "Installing ncurses"
    CT_DoExecLog ALL make install

    CT_Popd
    CT_EndStep
}

fi # CT_NCURSES

if [ "${CT_NCURSES_TARGET}" = "y" ]; then

do_ncurses_target() {
    local -a ncurses_target_opts

    CT_DoStep INFO "Installing ncurses for the target"
    mkdir -p "${CT_BUILD_DIR}/build-ncurses-for-target"
    CT_Pushd "${CT_BUILD_DIR}/build-ncurses-for-target"

    CT_DoLog EXTRA "Configuring ncurses"

    [ "${CT_CC_LANG_CXX}" = "y" ] || ncurses_target_opts+=("--without-cxx" "--without-cxx-binding")
    [ "${CT_CC_LANG_ADA}" = "y" ] || ncurses_target_opts+=("--without-ada")

    cp ../../config.cache .
    CT_DoExecLog CFG                                            \
    CC="${CT_TARGET}-gcc"                                       \
    CFLAGS="-g -Os -fPIC -DPIC"                                 \
    "${CT_SRC_DIR}/ncurses-${CT_NCURSES_VERSION}/configure"     \
        --build=${CT_BUILD}                                     \
        --host=${CT_TARGET}                                     \
        --cache-file="$(pwd)/config.cache"                      \
        --sysconfdir=/etc                                       \
        --localstatedir=/var                                    \
        --mandir=/usr/share/man                                 \
        --infodir=/usr/share/info                               \
        --prefix=/usr                                           \
        --without-libtool                                       \
        --without-pkg-config                                    \
        --disable-rpath                                         \
        --enable-echo                                           \
        --enable-const                                          \
        --without-gpm                                           \
        --enable-symlinks                                       \
        --disable-lp64                                          \
        --with-chtype='long'                                    \
        --with-mmask-t='long'                                   \
        --disable-termcap                                       \
        --without-profile                                       \
        --without-debug                                         \
        --with-normal                                           \
        --with-shared                                           \
        --with-ticlib                                           \
        --enable-widec                                          \
        --disable-big-core                                      \
        --with-default-terminfo-dir=/etc/terminfo               \
        --with-terminfo-dirs="/etc/terminfo:/lib/terminfo:/usr/share/terminfo" \
        "${ncurses_target_opts[@]}"

    CT_DoLog EXTRA "Building ncurses"
    CT_DoExecLog ALL make

    CT_DoLog EXTRA "Installing ncurses"
    CT_DoExecLog ALL make DESTDIR="${CT_SYSROOT_DIR}" install

    cd $CT_SYSROOT_DIR/usr/lib
    for i in form menu ncurses panel tic; do
      rm -f lib${i}.a lib${i}.so
      ln -sfv lib${i}w.a lib${i}.a
      echo "INPUT(-l${i}w)" > lib${i}.so
    done
    ln -sfv libncurses++w.a libncurses++.a

    CT_Popd
    CT_EndStep
}

fi # CT_NCURSES_TARGET

fi # CT_NCURSES || CT_NCURSES_TARGET
