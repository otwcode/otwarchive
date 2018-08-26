#!/bin/bash
set -e

# PDF
if ! [ -x "$(command -v wkhtmltopdf)" ]; then
  wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
  tar --directory="${HOME}" -xvf wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
  ln -s "${HOME}/wkhtmltox/bin/wkhtmltopdf" "${HOME}/bin/wkhtmltopdf"
fi
wkhtmltopdf --version

# Calibre

# Calibre depends on python-dateutil,
# which has this error in 2.7.3: https://stackoverflow.com/a/27634264
# so we downgrade:
sudo pip install python-dateutil==2.2
ebook-convert --version
