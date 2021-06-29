FROM ghcr.io/siemens/kas/kas:2.5

RUN set -ex \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        iptables \
        qemu-system \
    && rm -rf /var/lib/apt/lists
