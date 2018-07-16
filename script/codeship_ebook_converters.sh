#!/bin/bash
set -e

# PDF
if ! [ -x "$(command -v wkhtmltopdf)" ]; then
  wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
  tar --directory="${HOME}" -xvf wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
  ln -s "${HOME}/wkhtmltox/bin/wkhtmltopdf" "${HOME}/bin/wkhtmltopdf"
fi
wkhtmltopdf -h
