#!/bin/bash
set -e

sudo apt-get update -qq

# PDF
sudo apt-get install -qq xfonts-75dpi xfonts-base
wget https://media.archiveofourown.org/systems/wkhtmltox_0.12.5-1.bionic_amd64.deb
sudo dpkg -i ./wkhtmltox_0.12.5-1.bionic_amd64.deb
wkhtmltopdf --version

# Calibre
sudo apt-get install -qq calibre
ebook-convert --version
