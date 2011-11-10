# Build script for qt

do_target_me_harder_qt_get() {
    CT_GetFile "qt-everywhere-opensource-src-${CT_QT_VERSION}" .tar.gz \
               http://get.qt.nokia.com/qt/source
}

do_target_me_harder_qt_extract() {
    CT_Extract "qt-everywhere-opensource-src-${CT_QT_VERSION}"
    rm -rf "${CT_SRC_DIR}/qt-${CT_QT_VERSION}"
    mv "${CT_SRC_DIR}/qt-everywhere-opensource-src-${CT_QT_VERSION}" "${CT_SRC_DIR}/qt-${CT_QT_VERSION}"
    CT_Patch "qt" "${CT_QT_VERSION}"
}

do_target_me_harder_qt_build() {
    local xplatform
    local embedded_arch

    CT_DoStep EXTRA "Installing cross qt"
    mkdir -p "${CT_BUILD_DIR}/build-qt-cross"
    CT_Pushd "${CT_BUILD_DIR}/build-qt-cross"
    
    rm -f "${CT_SRC_DIR}/qt-${CT_QT_VERSION}/mkspecs/qws/common"
    ln -s ../common "${CT_SRC_DIR}/qt-${CT_QT_VERSION}/mkspecs/qws/common"
    rm -f "${CT_SRC_DIR}/qt-${CT_QT_VERSION}/mkspecs/qws/linux-g++"
    ln -s ../linux-g++ "${CT_SRC_DIR}/qt-${CT_QT_VERSION}/mkspecs/qws/linux-g++"

    CT_DoExecLog CFG \
    CPPFLAGS="-I${CT_BUILDTOOLS_PREFIX_DIR}/include"            \
    LDFLAGS="-L${CT_BUILDTOOLS_PREFIX_DIR}/lib -Wl,-rpath=${CT_BUILDTOOLS_PREFIX_DIR}/lib" \
    "${CT_SRC_DIR}/qt-${CT_QT_VERSION}/configure"               \
            -embedded \
            -fast \
            -debug \
            -verbose \
            -exceptions \
            -opensource \
            -confirm-license \
            -prefix "${CT_BUILDTOOLS_PREFIX_DIR}" \
            -no-gui \
            -no-sql-sqlite \
            -no-iconv \
            -no-sql-db2 \
            -no-sql-ibase \
            -no-sql-mysql \
            -no-sql-psql \
            -no-sql-oci \
            -no-sql-odbc \
            -no-sql-sqlite_symbian \
            -no-sql-sqlite2 \
            -no-sql-tds \
            -no-nis \
            -no-cups \
            -no-xmlpatterns \
            -no-svg \
            -no-webkit \
            -no-javascript-jit \
            -no-script \
            -no-scripttools \
            -no-declarative \
            -no-accessibility \
            -no-qt3support \
            -no-kbd-tty \
            -no-kbd-linuxinput \
            -no-mouse-pc \
            -no-mouse-linuxtp \
            -no-mouse-linuxinput \
            -no-gfx-multiscreen \
            -no-gfx-linuxfb \
            -no-libmng \
            -system-zlib \
            -make libs \
            -make tools \
            -make translations \
            -nomake examples \
            -nomake demos \
            -nomake docs \

    CT_DoExecLog ALL make ${JOBSFLAGS}
    CT_DoExecLog ALL make install
    CT_Popd
    CT_EndStep

    CT_DoStep EXTRA "Installing target qt"
    mkdir -p "${CT_BUILD_DIR}/build-qt-target"
    CT_Pushd "${CT_BUILD_DIR}/build-qt-target"
    
    case "${CT_ARCH}:${CT_ARCH_BITNESS}" in
        x86:32)     xplatform="qws/linux-cm-g++"; embedded_arch="x86";;
        arm:*)      xplatform="qws/linux-ti-g++"; embedded_arch="armv6";;
    esac

    cp -a "${CT_LIB_DIR}/dummy-opengl-es2" .
    CT_Pushd dummy-opengl-es2
    CT_DoExecLog ALL make HOST_TUPLE="${CT_TARGET}"
    CT_DoExecLog ALL make HOST_TUPLE="${CT_TARGET}" DESTDIR="${CT_SYSROOT_DIR}" install
    CT_Popd

    CT_DoExecLog CFG \
    HOST_TUPLE="${CT_TARGET}"                                   \
    CTBU_SYSROOT="${CT_SYSROOT_DIR}"                            \
    PKG_CONFIG="${CT_TARGET}-pkg-config --define-variable=prefix=${CT_SYSROOT_DIR}/usr" \
    CFLAGS="-g -Os"                                             \
    CXXFLAGS="-g -Os"                                           \
    "${CT_SRC_DIR}/qt-${CT_QT_VERSION}/configure"               \
	-fast \
	-debug \
	-verbose \
	-exceptions \
	-opensource \
	-confirm-license \
	-xplatform $xplatform \
	-embedded $embedded_arch \
	-hostprefix ${CT_PREFIX_DIR} \
	-prefix /usr \
	-sysconfdir /etc/settings \
	-force-pkg-config \
	-no-rpath \
	-no-iconv \
	-no-sql-db2 \
	-no-sql-ibase \
	-no-sql-mysql \
	-no-sql-psql \
	-no-sql-oci \
	-no-sql-odbc \
	-no-sql-sqlite_symbian \
	-no-sql-sqlite2 \
	-no-sql-tds \
	-no-nis \
	-no-cups \
	-no-xmlpatterns \
	-no-svg \
	-no-script \
	-no-scripttools \
	-no-declarative \
	-no-accessibility \
	-no-qt3support \
	-no-gfx-multiscreen \
	-no-gfx-linuxfb \
	-no-libmng \
	-openssl \
	-dbus \
	-glib \
	-sql-sqlite \
	-system-sqlite \
	-system-zlib \
	-system-libpng \
	-system-libjpeg \
	-system-libtiff \
	-system-freetype \
	-opengl es2 \
	-plugin-gfx-simplegl \
	-plugin-gfx-eglnullws \
	-no-kbd-tty \
	-qt-kbd-linuxinput \
	-qt-mouse-linuxinput \
	-no-mouse-pc \
	-no-mouse-linuxtp \
	-webkit \
	-javascript-jit \
	-make libs \
	-make tools \
	-make translations \
	-nomake examples \
	-nomake demos \
	-nomake docs \

    CT_DoExecLog ALL \
    HOST_TUPLE="${CT_TARGET}"                                   \
    CTBU_SYSROOT="${CT_SYSROOT_DIR}"                            \
    make ${JOBSFLAGS}

    rm -rf "${CT_SYSROOT_DIR}/dummy-install"
    mkdir "${CT_SYSROOT_DIR}/dummy-install"

    CT_DoExecLog ALL \
    HOST_TUPLE="${CT_TARGET}"                                   \
    CTBU_SYSROOT="${CT_SYSROOT_DIR}"                            \
    make INSTALL_ROOT="${CT_SYSROOT_DIR}"/dummy-install install

    tar -C "${CT_SYSROOT_DIR}/dummy-install${CT_PREFIX_DIR}" -cf - lib plugins translations \
        | tar -C "${CT_SYSROOT_DIR}/usr" -xf -
    ( cd "${CT_SYSROOT_DIR}/dummy-install${CT_PREFIX_DIR}" \
          && find bin include lib mkspecs translations -name .git\* -prune -o -name .svn\* -prune -o -print \
          | LC_ALL=C sort ) >"${CT_BUILD_DIR}/build-qt-target/qt.tar.list"
    tar cf - -C "${CT_SYSROOT_DIR}/dummy-install${CT_PREFIX_DIR}" \
        --no-recursion -T "${CT_BUILD_DIR}/build-qt-target/qt.tar.list" . \
        | tar xf - -C "${CT_PREFIX_DIR}"

    rm -rf "${CT_SYSROOT_DIR}/dummy-install"

    CT_Popd
    CT_EndStep
}
