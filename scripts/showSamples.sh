#!/bin/sh
# Yes, this is supposed to be a POSIX-compliant shell script.

# Parses all samples on the command line, and for each of them, prints
# the versions of the main tools

# Use tools discovered by ./configure
. "${CT_LIB_DIR}/paths.mk"

[ "$1" = "-v" ] && opt="$1" && shift
[ "$1" = "-w" ] && opt="$1" && shift

# GREP_OPTIONS screws things up.
export GREP_OPTIONS=

# Dump a single sample
dump_single_sample() {
    local verbose=0
    local complibs
    [ "$1" = "-v" ] && verbose=1 && shift
    [ "$1" = "-w" ] && wiki=1 && shift
    local width="$1"
    local sample="$2"
    case "${sample}" in
        current)
            sample_type="l"
            sample="${current_tuple}"
            width="${#sample}"
            . $(pwd)/.config
            ;;
        *)  if [ -f "${CT_TOP_DIR}/samples/${sample}/crosstool.config" ]; then
                sample_top="${CT_TOP_DIR}"
                sample_type="L"
            else
                sample_top="${CT_LIB_DIR}"
                sample_type="G"
            fi
            . "${sample_top}/samples/${sample}/crosstool.config"
            ;;
    esac
    if [ -z "${wiki}" ]; then
        t_width=14
        printf "%-*s  [%s" ${width} "${sample}" "${sample_type}"
        [ -f "${sample_top}/samples/${sample}/broken" ] && printf "B" || printf " "
        [ "${CT_EXPERIMENTAL}" = "y" ] && printf "X" || printf " "
        echo "]"
        if [ ${verbose} -ne 0 ]; then
            case "${CT_TOOLCHAIN_TYPE}" in
                cross)  ;;
                canadian)
                    printf "    %-*s : %s\n" ${t_width} "Host" "${CT_HOST}"
                    ;;
            esac
            printf "    %-*s : %s\n" ${t_width} "OS" "${CT_KERNEL}${CT_KERNEL_VERSION:+-}${CT_KERNEL_VERSION}"
            if [    -n "${CT_GMP}"              \
                 -o -n "${CT_MPFR}"             \
                 -o -n "${CT_PPL}"              \
                 -o -n "${CT_CLOOG}"            \
                 -o -n "${CT_MPC}"              \
                 -o -n "${CT_LIBELF}"           \
                 -o -n "${CT_ELFUTILS}"         \
                 -o -n "${CT_LIBUNWIND}"        \
                 -o -n "${CT_ZLIB}"             \
                 -o -n "${CT_BZIP2}"            \
                 -o -n "${CT_XZ}"               \
                 -o -n "${CT_POPT}"             \
                 -o -n "${CT_EXPAT}"            \
                 -o -n "${CT_NCURSES}"          \
                 -o -n "${CT_PCRE}"             \
                 -o -n "${CT_SQLITE}"           \
                 -o -n "${CT_ATTR}"             \
                 -o -n "${CT_ACL}"              \
                 -o -n "${CT_XMLRPCPP}"         \
                 -o -n "${CT_GMP_TARGET}"       \
                 -o -n "${CT_MPFR_TARGET}"      \
                 -o -n "${CT_PPL_TARGET}"       \
                 -o -n "${CT_CLOOG_TARGET}"     \
                 -o -n "${CT_MPC_TARGET}"       \
                 -o -n "${CT_LIBELF_TARGET}"    \
                 -o -n "${CT_ELFUTILS_TARGET}"  \
                 -o -n "${CT_LIBUNWIND_TARGET}" \
                 -o -n "${CT_ZLIB_TARGET}"      \
                 -o -n "${CT_BZIP2_TARGET}"     \
                 -o -n "${CT_XZ_TARGET}"        \
                 -o -n "${CT_POPT_TARGET}"      \
                 -o -n "${CT_EXPAT_TARGET}"     \
                 -o -n "${CT_NCURSES_TARGET}"   \
                 -o -n "${CT_PCRE_TARGET}"      \
                 -o -n "${CT_SQLITE_TARGET}"    \
                 -o -n "${CT_ATTR_TARGET}"      \
                 -o -n "${CT_ACL_TARGET}"       \
                 -o -n "${CT_XMLRPCPP_TARGET}"  \
               ]; then
                printf "    %-*s :" ${t_width} "Companion libs"
                complibs=1
            fi
            [ -z "${CT_GMP}"    -a -z "${CT_GMP_TARGET}"    ] || printf " gmp-%s"       "${CT_GMP_VERSION}"
            [ -z "${CT_MPFR}"   -a -z "${CT_MPFR_TARGET}"   ] || printf " mpfr-%s"      "${CT_MPFR_VERSION}"
            [ -z "${CT_PPL}"    -a -z "${CT_PPL_TARGET}"    ] || printf " ppl-%s"       "${CT_PPL_VERSION}"
            [ -z "${CT_CLOOG}"  -a -z "${CT_CLOOG_TARGET}"  ] || printf " cloog-ppl-%s" "${CT_CLOOG_VERSION}"
            [ -z "${CT_MPC}"    -a -z "${CT_MPC_TARGET}"    ] || printf " mpc-%s"       "${CT_MPC_VERSION}"
            [ -z "${CT_LIBELF}" -a -z "${CT_LIBELF_TARGET}" ] || printf " libelf-%s"    "${CT_LIBELF_VERSION}"
            [ -z "${CT_ELFUTILS}" -a -z "${CT_ELFUTILS_TARGET}" ] || printf " elfutils-%s" "${CT_ELFUTILS_VERSION}"
            [ -z "${CT_LIBUNWIND}" -a -z "${CT_LIBUNWIND_TARGET}" ] || printf " libunwind-%s" "${CT_LIBUNWIND_VERSION}"
            [ -z "${CT_ZLIB}"   -a -z "${CT_ZLIB_TARGET}"   ] || printf " zlib-%s"      "${CT_ZLIB_VERSION}"
            [ -z "${CT_BZIP2}"  -a -z "${CT_BZIP2_TARGET}"  ] || printf " bzip2-%s"     "${CT_BZIP2_VERSION}"
            [ -z "${CT_XZ}"     -a -z "${CT_XZ_TARGET}"     ] || printf " xz-%s"        "${CT_XZ_VERSION}"
            [ -z "${CT_POPT}"   -a -z "${CT_POPT_TARGET}"   ] || printf " popt-%s"      "${CT_POPT_VERSION}"
            [ -z "${CT_EXPAT}"  -a -z "${CT_EXPAT_TARGET}"  ] || printf " expat-%s"     "${CT_EXPAT_VERSION}"
            [ -z "${CT_NCURSES}" -a -z "${CT_NCURSES_TARGET}" ] || printf " ncurses-%s" "${CT_NCURSES_VERSION}"
            [ -z "${CT_PCRE}"   -a -z "${CT_PCRE_TARGET}"   ] || printf " pcre-%s"      "${CT_PCRE_VERSION}"
            [ -z "${CT_SQLITE}" -a -z "${CT_SQLITE_TARGET}" ] || printf " sqlite-%s"    "${CT_SQLITE_VERSION}"
            [ -z "${CT_ATTR}"   -a -z "${CT_ATTR_TARGET}"   ] || printf " attr-%s"      "${CT_ATTR_VERSION}"
            [ -z "${CT_ACL}"    -a -z "${CT_ACL_TARGET}"    ] || printf " acl-%s"       "${CT_ACL_VERSION}"
            [ -z "${CT_XMLRPCPP}" -a -z "${CT_XMLRPCPP_TARGET}" ] || printf " xmlrpcpp-%s" "${CT_XMLRPCPP_VERSION}"
            [ -z "${complibs}"  ] || printf "\n"
            printf  "    %-*s : %s\n" ${t_width} "binutils" "binutils-${CT_BINUTILS_VERSION}"
            printf  "    %-*s : %s" ${t_width} "C compiler" "${CT_CC}-${CT_CC_VERSION} (C"
            [ "${CT_CC_LANG_CXX}" = "y"     ] && printf ",C++"
            [ "${CT_CC_LANG_FORTRAN}" = "y" ] && printf ",Fortran"
            [ "${CT_CC_LANG_JAVA}" = "y"    ] && printf ",Java"
            [ "${CT_CC_LANG_ADA}" = "y"     ] && printf ",ADA"
            [ "${CT_CC_LANG_OBJC}" = "y"    ] && printf ",Objective-C"
            [ "${CT_CC_LANG_OBJCXX}" = "y"  ] && printf ",Objective-C++"
            [ -n "${CT_CC_LANG_OTHERS}"     ] && printf ",${CT_CC_LANG_OTHERS}"
            printf ")\n"
            printf  "    %-*s : %s\n" ${t_width} "C library" "${CT_LIBC}${CT_LIBC_VERSION:+-}${CT_LIBC_VERSION}"
            printf  "    %-*s :" ${t_width} "Tools"
            [ "${CT_TOOL_sstrip}"   ] && printf " sstrip"
            [ "${CT_DEBUG_dmalloc}" ] && printf " dmalloc-${CT_DMALLOC_VERSION}"
            [ "${CT_DEBUG_duma}"    ] && printf " duma-${CT_DUMA_VERSION}"
            [ "${CT_DEBUG_gdb}"     ] && printf " gdb-${CT_GDB_VERSION}"
            [ "${CT_DEBUG_ltrace}"  ] && printf " ltrace-${CT_LTRACE_VERSION}"
            [ "${CT_DEBUG_strace}"  ] && printf " strace-${CT_STRACE_VERSION}"
            [ "${CT_DEBUG_tcpdump}" ] && printf " tcpdump-${CT_TCPDUMP_VERSION}"
            [ "${CT_DEBUG_oprofile}"] && printf " oprofile-${CT_OPROFILE_VERSION}"
            [ "${CT_DEBUG_latencytop}"] && printf " latencytop-${CT_LATENCYTOP_VERSION}"
            [ "${CT_DEBUG_valgrind}"] && printf " valgrind-${CT_VALGRIND_VERSION}"
            [ "${CT_DEBUG_bash}"    ] && printf " bash-${CT_BASH_VERSION}"
            [ "${CT_DEBUG_gawk}"    ] && printf " gawk-${CT_GAWK_VERSION}"
            [ "${CT_DEBUG_tar}"     ] && printf " tar-${CT_TAR_VERSION}"
            [ "${CT_DEBUG_procps}"  ] && printf " procps-${CT_PROCPS_VERSION}"
            [ "${CT_DEBUG_cgreen}"  ] && printf " cgreen-${CT_CGREEN_VERSION}"
            [ "${CT_DEBUG_gmock}"   ] && printf " gmock-${CT_GMOCK_VERSION}"
            printf "\n"
        fi
    else
        case "${CT_TOOLCHAIN_TYPE}" in
            cross)
                printf "| ''${sample}''  | "
                ;;
            canadian)
                printf "| ''"
                printf "${sample}" |sed -r -e 's/.*,//'
                printf "''  | ${CT_HOST}  "
                ;;
            *)          ;;
        esac
        printf "|  "
        [ "${CT_EXPERIMENTAL}" = "y" ] && printf "**X**"
        [ -f "${sample_top}/samples/${sample}/broken" ] && printf "**B**"
        printf "  |  ''${CT_KERNEL}''  |"
        if [ "${CT_KERNEL}" != "bare-metal" ];then
            if [ "${CT_KERNEL_LINUX_HEADERS_USE_CUSTOM_DIR}" = "y" ]; then
                printf "  //custom//  "
            else
                printf "  ${CT_KERNEL_VERSION}  "
            fi
        fi
        printf "|  ${CT_BINUTILS_VERSION}  "
        printf "|  ''${CT_CC}''  "
        printf "|  ${CT_CC_VERSION}  "
        printf "|  ''${CT_LIBC}''  |"
        if [ "${CT_LIBC}" != "none" ]; then
            printf "  ${CT_LIBC_VERSION}  "
        fi
        printf "|  ${CT_THREADS:-none}  "
        printf "|  ${CT_ARCH_FLOAT_HW:+hard}${CT_ARCH_FLOAT_SW:+soft}  "
        printf "|  C"
        [ "${CT_CC_LANG_CXX}" = "y"     ] && printf ", C++"
        [ "${CT_CC_LANG_FORTRAN}" = "y" ] && printf ", Fortran"
        [ "${CT_CC_LANG_JAVA}" = "y"    ] && printf ", Java"
        [ "${CT_CC_LANG_ADA}" = "y"     ] && printf ", ADA"
        [ "${CT_CC_LANG_OBJC}" = "y"    ] && printf ", Objective-C"
        [ "${CT_CC_LANG_OBJCXX}" = "y"  ] && printf ", Objective-C++"
        [ -n "${CT_CC_LANG_OTHERS}"     ] && printf "\\\\\\\\ Others: ${CT_CC_LANG_OTHERS}"
        printf "  "
        ( . "${sample_top}/samples/${sample}/reported.by"
          if [ -n "${reporter_name}" ]; then
              if [ -n "${reporter_url}" ]; then
                  printf "|  [[${reporter_url}|${reporter_name}]]  "
              else
                  printf "|  ${reporter_name}  "
              fi
          else
              printf "|  [[http://ymorin.is-a-geek.org/|YEM]]  "
          fi
        )
        sample_updated="$( hg log -l 1 --template '{date|shortdate}' "${sample_top}/samples/${sample}" )"
        printf "|  ${sample_updated}  "
        echo "|"
    fi
}

# Get largest sample width
width=0
for sample in "${@}"; do
    [ ${#sample} -gt ${width} ] && width=${#sample}
done

if [ "${opt}" = -w ]; then
    printf "^ %s  |||||||||||||||\n" "$( date "+%Y%m%d.%H%M %z" )"
    printf "^ Target  "
    printf "^ Host  "
    printf "^  Status  "
    printf "^  Kernel headers\\\\\\\\ version  ^"
    printf "^  binutils\\\\\\\\ version  "
    printf "^  C compiler\\\\\\\\ version  ^"
    printf "^  C library\\\\\\\\ version  ^"
    printf "^  Threading\\\\\\\\ model  "
    printf "^  Floating point\\\\\\\\ support  "
    printf "^  Languages  "
    printf "^  Initially\\\\\\\\ reported by  "
    printf "^  Last\\\\\\\\ updated  "
    echo   "^"
elif [ -z "${opt}" ]; then
    printf "%-*s  Status\n" ${width} "Sample name"
fi

for sample in "${@}"; do
    ( dump_single_sample ${opt} ${width} "${sample}" )
done

if [ "${opt}" = -w ]; then
    printf "^ Total: ${#@} samples  || **X**: sample uses features marked as being EXPERIMENTAL.\\\\\\\\ **B**: sample is curently BROKEN. |||||||||||||"
    echo   ""
elif [ -z "${opt}" ]; then
    echo '      L (Local)       : sample was found in current directory'
    echo '      G (Global)      : sample was installed with crosstool-NG'
    echo '      X (EXPERIMENTAL): sample may use EXPERIMENTAL features'
    echo '      B (BROKEN)      : sample is currently broken'
fi
