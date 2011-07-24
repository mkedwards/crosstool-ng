# Build script for xmlrpcpp

do_xmlrpcpp_get() { :; }
do_xmlrpcpp_extract() { :; }
do_xmlrpcpp() { :; }
do_xmlrpcpp_target() { :; }

if [ "${CT_XMLRPCPP}" = "y" -o "${CT_XMLRPCPP_TARGET}" = "y" ]; then

do_xmlrpcpp_get() {
    CT_GetFile "xmlrpc++${CT_XMLRPCPP_VERSION}" .tar.gz    \
               "http://mesh.dl.sourceforge.net/sourceforge/xmlrpcpp/xmlrpc%2B%2B/Version%20${CT_XMLRPCPP_VERSION}"
    # Downloading from sourceforge may leave garbage, cleanup
    CT_DoExecLog ALL rm -f "${CT_TARBALLS_DIR}/showfiles.php"*
}

do_xmlrpcpp_extract() {
    CT_Extract "xmlrpc++${CT_XMLRPCPP_VERSION}"
    mv "${CT_SRC_DIR}/xmlrpc++${CT_XMLRPCPP_VERSION}" "${CT_SRC_DIR}/xmlrpcpp-${CT_XMLRPCPP_VERSION}"
    CT_Patch "xmlrpcpp" "${CT_XMLRPCPP_VERSION}"
}

if [ "${CT_XMLRPCPP}" = "y" ]; then

do_xmlrpcpp() {
    CT_DoStep INFO "Installing xmlrpcpp"
    rm -rf "${CT_BUILD_DIR}/build-xmlrpcpp"
    cp -a "${CT_SRC_DIR}/xmlrpcpp-${CT_XMLRPCPP_VERSION}" "${CT_BUILD_DIR}/build-xmlrpcpp"
    CT_Pushd "${CT_BUILD_DIR}/build-xmlrpcpp"

    CT_DoLog EXTRA "Building xmlrpcpp"
    CT_DoExecLog ALL make ${JOBSFLAGS}                          \
    CXX="${CT_HOST}-g++"                                        \
    prefix="${CT_PREFIX_DIR}"                                   \
    all

    CT_DoLog EXTRA "Installing xmlrpcpp"
    CT_DoExecLog ALL make                                       \
    CXX="${CT_HOST}-g++"                                        \
    prefix="${CT_PREFIX_DIR}"                                   \
    install

    CT_Popd
    CT_EndStep
}

fi # CT_XMLRPCPP

if [ "${CT_XMLRPCPP_TARGET}" = "y" ]; then

do_xmlrpcpp_target() {
    CT_DoStep INFO "Installing xmlrpcpp for the target"
    rm -rf "${CT_BUILD_DIR}/build-xmlrpcpp-for-target"
    cp -a "${CT_SRC_DIR}/xmlrpcpp-${CT_XMLRPCPP_VERSION}" "${CT_BUILD_DIR}/build-xmlrpcpp-for-target"
    CT_Pushd "${CT_BUILD_DIR}/build-xmlrpcpp-for-target"

    CT_DoLog EXTRA "Building xmlrpcpp"
    CT_DoExecLog ALL make ${JOBSFLAGS}                          \
    CXX="${CT_TARGET}-g++"                                      \
    prefix=/usr                                                 \
    all

    CT_DoLog EXTRA "Installing xmlrpcpp"
    CT_DoExecLog ALL make                                       \
    CXX="${CT_TARGET}-g++"                                      \
    prefix=/usr                                                 \
    DESTDIR="${CT_SYSROOT_DIR}"                                 \
    install

    CT_Popd
    CT_EndStep
}

fi # CT_XMLRPCPP_TARGET

fi # CT_XMLRPCPP || CT_XMLRPCPP_TARGET
