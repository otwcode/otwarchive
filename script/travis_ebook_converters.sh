#!/bin/bash
set -e

# PDF
wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox-0.12.5_linux-generic-amd64.tar.xz
sudo tar --directory=/opt -xvf wkhtmltox-0.12.5_linux-generic-amd64.tar.xz
sudo ln -s /opt/wkhtmltox/bin/wkhtmltopdf /usr/bin/wkhtmltopdf
wkhtmltopdf --version

# Calibre
sudo apt-get update -qq
sudo apt-get install -qq calibre
ebook-convert --version
