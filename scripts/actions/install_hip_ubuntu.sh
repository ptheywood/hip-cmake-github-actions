#! /usr/bin/env bash

# Todo: Full version of this as a script, including:
# Todo: Respect input env vars
# Todo: better subpackage management etc
# Todo: 7.x is different thatn 6.x etc
# Todo: Ubuntu version differences


## -----------------
## Check for root/sudo
## -----------------

# Detect if the script is being run as root, storing true/false in is_root.
is_root=false
if (( $EUID == 0)); then
   is_root=true
fi
# Find if sudo is available
has_sudo=false
if command -v sudo &> /dev/null ; then
    has_sudo=true
fi
# Decide if we can proceed or not (root or sudo is required) and if so store whether sudo should be used or not. 
if [ "$is_root" = false ] && [ "$has_sudo" = false ]; then 
    echo "Root or sudo is required. Aborting."
    exit 1
elif [ "$is_root" = false ] ; then
    USE_SUDO=sudo
else
    USE_SUDO=
fi

# enable command printing for CI debugging
set -x

# following ubuntu instructions from:
# https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/prerequisites.html
# https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/install-methods/package-manager/package-manager-ubuntu.html

# install deps
$USE_SUDO apt-get install -y python3-setuptools python3-wheel

# Signing key
$USE_SUDO mkdir --parents --mode=0755 /etc/apt/keyrings
wget https://repo.radeon.com/rocm/rocm.gpg.key -O - | gpg --dearmor | $USE_SUDO tee /etc/apt/keyrings/rocm.gpg > /dev/null

# register packages
$USE_SUDO tee /etc/apt/sources.list.d/rocm.list << EOF
deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/7.2.1 noble main
deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/graphics/7.2.1/ubuntu noble main
EOF
$USE_SUDO tee /etc/apt/preferences.d/rocm-pin-600 << EOF
Package: *
Pin: release o=repo.radeon.com
Pin-Priority: 600
EOF
$USE_SUDO apt update

# Install packages.
# Todo: Install as few as possible, this will be big and unversioned
$USE_SUDO apt install -y rocm-hip-runtime-dev
