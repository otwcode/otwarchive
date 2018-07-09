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
cpanm --notest --sudo -q install Palm::PDB
cpanm --notest --sudo -q install GD
cpanm --notest --sudo -q install XML::Parser::Lite::Tree
cpanm --notest --sudo -q install Image::BMP
cpanm --notest --sudo -q install Image::Size
cpanm --notest --sudo -q install HTML::TreeBuilder
cpanm --notest --sudo -q install Getopt::Mixed
cpanm --notest --sudo -q install Date::Parse
cpanm --notest --sudo -q install Date::Format
cpanm --notest --sudo -q install URI::Escape

wget http://media.archiveofourown.org/ao3/new_vagrant/mobiperl-0.0.43.tar
tar xvf mobiperl-0.0.43.tar
pushd mobiperl-0.0.43
sudo cp -r Palm MobiPerl /usr/lib/perl5
sudo cp html2mobi /usr/bin/
popd
html2mobi
