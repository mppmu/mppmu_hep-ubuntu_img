FROM rootproject/root:6.24.06-ubuntu20.04

USER root
WORKDIR /root
CMD /bin/bash


# Install packages:

RUN set -eux && export DEBIAN_FRONTEND=noninteractive \
    && sed -i 's/apt-get upgrade$/apt-get upgrade -y/' `which unminimize` \
    && (echo y | unminimize) \
    && apt-get update \
	&& apt-get install -y --no-install-recommends ca-certificates \
    && apt-get install -y locales && locale-gen en_US.UTF-8 \
    && apt-get install -y \
        less \
        rsync \
        wget curl \
        nano vim \
        bzip2 \
        \
        perl \
        \
        screen parallel mc \
        \
        python3 python3-dev python3-pip \
        \
        git \
        build-essential autoconf cmake pkg-config gfortran \
        debhelper dh-autoreconf help2man libarchive-dev python \
        squashfs-tools \
        \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


# Install Jupyter and HEP Python packages:

RUN set -eux \
    && pip3 install \
        jupyter jupyterlab metakernel bash_kernel rise jupyter_contrib_nbextensions jupyter-server-proxy \
        matplotlib \
        uproot awkward uproot3 awkward0 uproot4 awkward1 xxhash hepunits particle \
    \
    && python3 -m bash_kernel.install \
    && ln -s /opt/root/etc/notebook/kernels/root /usr/local/share/jupyter/kernels/


# Install Julia:

RUN set -eux \
    && mkdir -p /opt/julia \
    && wget -O- 'https://julialang-s3.julialang.org/bin/linux/x64/1.7/julia-1.7.0-rc1-linux-x86_64.tar.gz' \
        | tar --strip-components=1 -x -z -f - -C /opt/julia

ENV PATH="/opt/julia/bin:$PATH" MANPATH="/opt/julia/share/man:$MANPATH"


# Install code-server:

RUN set -eux \
    && tmpdebdir=`mktemp -d` \
    && wget -O "$tmpdebdir/code-server.deb" 'https://github.com/cdr/code-server/releases/download/v3.12.0/code-server_3.12.0_amd64.deb' \
    && dpkg -i "$tmpdebdir/code-server.deb" \
    && rm -rf "$tmpdebdir"
