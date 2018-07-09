#!/bin/bash
# Install libgd2 on Codeship - https://packages.ubuntu.com/trusty/libgd2-xpm-dev
LIBGD2_DIR=${LIBGD2_DIR:=$HOME/cache/libgd2}

set -e

if [ ! -d "${LIBGD2_DIR}" ]; then
  mkdir -p "${HOME}/libgd2"
  wget "http://archive.ubuntu.com/ubuntu/pool/main/libg/libgd2/libgd2_2.1.0.orig.tar.xz"
  tar -xaf "libgd2_2.1.0.orig.tar.xz" --strip-components=1 --directory "${HOME}/libgd2"

  (
    cd "${HOME}/libgd2" || exit 1
    ./configure --prefix="${LIBGD2_DIR}"
    make
    make install
  )
fi

ln -s "${LIBGD2_DIR}/bin/"* "${HOME}/bin"
