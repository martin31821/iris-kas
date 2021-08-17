FROM ghcr.io/siemens/kas/kas:2.5

RUN set -ex \
# Add buster-backports to repos
    && echo 'deb http://deb.debian.org/debian buster-backports main' >> /etc/apt/sources.list \
    && apt-get update \
# Install QEMU deps (TAP devices)
    && apt-get install --no-install-recommends -y \
        iptables \
    \
# Install QEMU from backports (more recent version for bugfixes)
    && apt-get install --no-install-recommends -y -t buster-backports qemu-system \
# No upgrades for qemu
    && apt-mark hold qemu-system \
    && rm -rf /var/lib/apt/lists
# Print QEMU version
RUN qemu-system-aarch64 --version