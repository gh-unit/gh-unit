#!/bin/sh

set -e
set -u

export DYLD_ROOT_PATH="$1"
export IPHONE_SIMULATOR_ROOT="$1"
export CFFIXED_USER_HOME="$2"

"$IPHONE_SIMULATOR_ROOT"/usr/libexec/securityd
