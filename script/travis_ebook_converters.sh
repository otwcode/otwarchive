#!/bin/bash
set -e

# PDF
wget https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox_0.12.5-1.trusty_amd64.deb
sudo apt install ./wkhtmltox_0.12.5-1.trusty_amd64.deb
wkhtmltopdf --version

# Calibre
sudo apt-get update -qq
sudo apt-get install -qq calibre
ebook-convert --version
