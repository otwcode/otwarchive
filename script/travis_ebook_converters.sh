#!/bin/bash

# PDF
wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
sudo tar --directory=/opt -xvf wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
sudo ln -s /opt/wkhtmltox/bin/wkhtmltopdf /usr/bin/wkhtmltopdf
wkhtmltopdf -h

# MOBI
# http://blogs.perl.org/users/gabor_szabo/2012/07/what-package-provides-gdlib-config-in-your-distribution.html
sudo apt-get -y install libgd2-xpm-dev
# http://www.ida.liu.se/~tompe44/mobiperl/
cpanm install Palm::PDB --sudo -q
cpanm install GD --sudo -q
cpanm install XML::Parser::Lite::Tree --sudo -q
cpanm install Image::BMP --sudo -q
cpanm install Image::Size --sudo -q
cpanm install HTML::TreeBuilder --sudo -q
cpanm install Getopt::Mixed --sudo -q
cpanm install Date::Parse --sudo -q
cpanm install Date::Format --sudo -q
cpanm install URI::Escape --sudo -q

tar xvf script/mobiperl-0.0.43.tar.gz
pushd mobiperl-0.0.43
sudo cp -r Palm MobiPerl /usr/lib/perl5
sudo cp html2mobi /usr/bin/
popd
html2mobi
