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

# following ubuntu instructions (mix of RHEL and rocky instructions) from:  
# https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/prerequisites.html
# https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/install-methods/package-manager/package-manager-ubuntu.html
# https://wiki.almalinux.org/repos/AlmaLinux.html

# Add EPEL
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
$USE_SUDO rpm -ivh epel-release-latest-8.noarch.rpm
$USE_SUDO dnf config-manager --set-enabled powertools

# install deps
$USE_SUDO dnf install python3-setuptools python3-wheel

# register ROCm repositories
# Todo: This is where version selection would go (for 7.2 and 7.2.1 at least)
$USE_SUDO tee /etc/yum.repos.d/rocm.repo <<EOF
[rocm]
name=ROCm 7.2.1 repository
baseurl=https://repo.radeon.com/rocm/el8/7.2.1/main
enabled=1
priority=50
gpgcheck=1
gpgkey=https://repo.radeon.com/rocm/rocm.gpg.key

[amdgraphics]
name=AMD Graphics 7.2.1 repository
baseurl=https://repo.radeon.com/graphics/7.2.1/el/8/main/x86_64/
enabled=1
priority=50
gpgcheck=1
gpgkey=https://repo.radeon.com/rocm/rocm.gpg.key
EOF
$USE_SUDO dnf clean all

# Install packages.
# Todo: Install as few as possible, this will be big and unversioned
# Todo: install the versioned package name, in case multiple versions are available from the same rocm.repo
$USE_SUDO dnf install -y rocm-hip-runtime-devel
