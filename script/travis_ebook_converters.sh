#!/bin/bash
set -e

sudo apt-get update -qq

# PDF
sudo apt-get install -qq xfonts-75dpi xfonts-base
wget https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox_0.12.5-1.xenial_amd64.deb
sudo dpkg -i ./wkhtmltox_0.12.5-1.xenial_amd64.deb
wkhtmltopdf --version

# Calibre
sudo apt-get install -qq calibre
ebook-convert --version
