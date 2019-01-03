#   Copyright 2017-2018 ckb-next Development Team <ckb-next@googlegroups.com>
#   All rights reserved.
#
#   Redistribution and use in source and binary forms, with or without
#   modification, are permitted provided that the following conditions are met:
#   
#   1. Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
#   2. Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
#   3. Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from this
#   software without specific prior written permission. 
#   
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#   ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
#   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
#   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
#   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
#   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
#   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
#   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#   POSSIBILITY OF SUCH DAMAGE.

# Detect the init system.

# The result is stored in CKB_NEXT_DETECTED_INIT_SYSTEM.

function(detect_init_system)

    set(CKB_NEXT_DETECTED_INIT_SYSTEM "unknown" PARENT_SCOPE)

    if (MACOS)
        set(CKB_NEXT_DETECTED_INIT_SYSTEM "launchd" PARENT_SCOPE)
    elseif (LINUX)
        # Used to prevent false SysVinit detection on systems that have
        # /etc/inittab with systemd
        set(DISALLOW_SYSVINIT FALSE)

        # NOTE: upstart is checked first to correctly behave on systems which
        # still have upstart but it is not enabled by default and systemd is
        # used instead. (Ubuntu 15.04+)

        # A way to check for upstart
        execute_process(
            COMMAND initctl --version
            OUTPUT_VARIABLE initctl_output
            OUTPUT_STRIP_TRAILING_WHITESPACE)

        if ("${initctl_output}" MATCHES "upstart")
            set(CKB_NEXT_DETECTED_INIT_SYSTEM "upstart" PARENT_SCOPE)
            set(DISALLOW_SYSVINIT TRUE)
        endif ()

        # A way to check for systemd
        if (EXISTS "/run/systemd/system")
            set(CKB_NEXT_DETECTED_INIT_SYSTEM "systemd" PARENT_SCOPE)
            set(DISALLOW_SYSVINIT TRUE)
        endif ()

        # A way to check for OpenRC
        if (EXISTS "/run/openrc/softlevel")
            set(CKB_NEXT_DETECTED_INIT_SYSTEM "OpenRC" PARENT_SCOPE)
            set(DISALLOW_SYSVINIT TRUE)
        endif ()

        # A way to check for SysVinit
        # Fall back to this only if any of the above haven't been found
        if (EXISTS "/etc/inittab" AND EXISTS "/lib/lsb/init-functions"
                AND NOT DISALLOW_SYSVINIT)
            set(CKB_NEXT_DETECTED_INIT_SYSTEM "SysVinit" PARENT_SCOPE)
        endif ()

    endif ()

    if ("${CKB_NEXT_DETECTED_INIT_SYSTEM}" STREQUAL "unknown")
        message(WARNING "No supported system service detected.
        Supported services are: systemd, launchd, OpenRC, upstart, SysVinit.")
    else ()
        message(STATUS "${CKB_NEXT_DETECTED_INIT_SYSTEM} detected")
    endif ()

endfunction()

function(check_valid_init_system)

    if (NOT ("${CKB_NEXT_INIT_SYSTEM}" STREQUAL "launchd" OR
        "${CKB_NEXT_INIT_SYSTEM}" STREQUAL "systemd" OR
        "${CKB_NEXT_INIT_SYSTEM}" STREQUAL "upstart" OR
        "${CKB_NEXT_INIT_SYSTEM}" STREQUAL "OpenRC" OR
        "${CKB_NEXT_INIT_SYSTEM}" STREQUAL "SysVinit" OR
        "${CKB_NEXT_INIT_SYSTEM}" STREQUAL "unknown"))
        message(FATAL_ERROR "\"${CKB_NEXT_INIT_SYSTEM}\" is not a valid init system.
        Recognised values are: systemd, launchd, OpenRC, upstart, SysVinit, unknown")
    endif ()

endfunction()
