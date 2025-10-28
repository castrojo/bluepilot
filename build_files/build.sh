#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux 

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket

### Copy Brewfiles
# Copy all Brewfiles from /brew to /usr/share/ublue-os/homebrew/
# These will be available for users to install packages via Homebrew/Brew
mkdir -p /usr/share/ublue-os/homebrew/
cp /ctx/brew/*.Brewfile /usr/share/ublue-os/homebrew/

### Setup ujust
# Consolidate ujust files from /ujust directory into system location
if [ -d "/ctx/ujust" ]; then
    echo "Setting up ujust custom commands..."
    mkdir -p /usr/share/ublue-os/just
    find /ctx/ujust -iname '*.just' -exec printf "\n\n" \; -exec cat {} \; >> /usr/share/ublue-os/just/60-custom.just
    echo "ujust commands installed to /usr/share/ublue-os/just/60-custom.just"
fi
