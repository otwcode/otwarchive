#!/bin/bash
set -e

# PDF
pushd $HOME/cache
wget -N https://media.archiveofourown.org/systems/wkhtmltox_0.12.5-1.bionic_amd64.deb
sudo dpkg -i ./wkhtmltox_0.12.5-1.bionic_amd64.deb
popd
sudo apt-get install -f
wkhtmltopdf --version

# Calibre

# Calibre depends on python-dateutil,
# which has this error in 2.7.3: https://stackoverflow.com/a/27634264
# so we downgrade:
sudo pip install python-dateutil==2.2
ebook-convert --version
