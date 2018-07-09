#!/bin/bash

set -e

# PDF
if ! [ -x "$(command -v wkhtmltopdf)" ]; then
  wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
  tar --directory="${HOME}" -xvf wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
  ln -s "${HOME}/wkhtmltox/bin/wkhtmltopdf" "${HOME}/bin/wkhtmltopdf"
fi
wkhtmltopdf -h

# MOBI

# This needs to be run in the test pipeline;
# if run here it only lasts until the end of the script
export PERL5LIB="${HOME}/perl5/lib/perl5"

if ! [ -x "$(command -v html2mobi)" ]; then
  # Dependency for GD
  bash ./script/codeship_libgd2.sh

  # Install cpanm
  # http://cwinters.com/2015/10/03/recipe-for-sqitch-on-codeship.html
  mkdir -p "${HOME}/bin/"
  pushd "${HOME}/bin/"
  curl -L https://cpanmin.us/ -o cpanm
  chmod +x cpanm
  popd

  # http://www.ida.liu.se/~tompe44/mobiperl/
  cpanm --notest -q install Palm::PDB
  cpanm --notest -q install GD
  cpanm --notest -q install XML::Parser::Lite::Tree
  cpanm --notest -q install Image::BMP
  cpanm --notest -q install Image::Size
  cpanm --notest -q install HTML::TreeBuilder
  cpanm --notest -q install Getopt::Mixed
  cpanm --notest -q install Date::Parse
  cpanm --notest -q install Date::Format
  cpanm --notest -q install URI::Escape

  wget http://media.archiveofourown.org/ao3/new_vagrant/mobiperl-0.0.43.tar
  tar xvf mobiperl-0.0.43.tar
  pushd mobiperl-0.0.43
  cp -r Palm MobiPerl "${PERL5LIB}"
  cp html2mobi "${HOME}/bin/"
  popd
fi

html2mobi
