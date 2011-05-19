# Build script for tz

do_cross_me_harder_tz_get() {
    CT_GetFile "tzcode${CT_TZ_VERSION}" .tar.gz \
               ftp://elsie.nci.nih.gov/pub
    CT_GetFile "tzdata${CT_TZ_VERSION}" .tar.gz \
               ftp://elsie.nci.nih.gov/pub
}

do_cross_me_harder_tz_extract() {
    mkdir -p "${CT_SRC_DIR}/tz-${CT_TZ_VERSION}"
    CT_Pushd "${CT_SRC_DIR}/tz-${CT_TZ_VERSION}"
    CT_Extract nochdir "tzcode${CT_TZ_VERSION}"
    CT_Extract nochdir "tzdata${CT_TZ_VERSION}"
    CT_Popd
}

do_cross_me_harder_tz_build() {
    CT_DoStep EXTRA "Installing host tz"
    rm -rf "${CT_BUILD_DIR}/build-tz"
    cp -a "${CT_SRC_DIR}/tz-${CT_TZ_VERSION}" "${CT_BUILD_DIR}/build-tz"
    CT_Pushd "${CT_BUILD_DIR}/build-tz"
    
    CT_DoExecLog ALL make all TOPDIR=/usr TZDIR=/usr/share/zoneinfo ETCDIR=/usr/sbin MANDIR=/usr/share/man cc=gcc
    CT_DoExecLog ALL make install TOPDIR=${CT_BUILDTOOLS_PREFIX_DIR} TZDIR=${CT_BUILDTOOLS_PREFIX_DIR}/share/zoneinfo ETCDIR=${CT_BUILDTOOLS_PREFIX_DIR}/sbin MANDIR=${CT_BUILDTOOLS_PREFIX_DIR}/share/man
    CT_Popd
    CT_EndStep

    CT_DoStep EXTRA "Installing target tz"
    rm -rf "${CT_BUILD_DIR}/build-tz-target"
    cp -a "${CT_SRC_DIR}/tz-${CT_TZ_VERSION}" "${CT_BUILD_DIR}/build-tz-target"
    CT_Pushd "${CT_BUILD_DIR}/build-tz-target"
    
    CT_DoExecLog ALL make all TOPDIR=/usr TZDIR=/usr/share/zoneinfo ETCDIR=/usr/sbin MANDIR=/usr/share/man cc=${CT_TARGET}-gcc CFLAGS="-g -Os"
    rm -rf ${CT_SYSROOT_DIR}/usr/sbin/tzselect ${CT_SYSROOT_DIR}/usr/sbin/zic ${CT_SYSROOT_DIR}/usr/sbin/zdump ${CT_SYSROOT_DIR}/usr/share/zoneinfo
    CT_DoExecLog ALL make install TOPDIR=${CT_SYSROOT_DIR}/usr TZDIR=${CT_SYSROOT_DIR}/usr/share/zoneinfo ETCDIR=${CT_SYSROOT_DIR}/usr/sbin MANDIR=${CT_SYSROOT_DIR}/usr/share/man zic=${CT_BUILDTOOLS_PREFIX_DIR}/sbin/zic
    CT_Popd
    CT_EndStep
}
