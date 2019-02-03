#!/bin/bash
set -e

# PDF
wget https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox_0.12.5-1.trusty_amd64.deb
sudo dpkg -i ./wkhtmltox_0.12.5-1.trusty_amd64.deb
sudo apt-get install -f
wkhtmltopdf --version

# Calibre

# Calibre depends on python-dateutil,
# which has this error in 2.7.3: https://stackoverflow.com/a/27634264
# so we downgrade:
sudo pip install python-dateutil==2.2
ebook-convert --version
