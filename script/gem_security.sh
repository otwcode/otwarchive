#!/bin/sh
TMP=/tmp/audit.$$
bundle-audit update
# TODO update gems, remove ignore checks:
# rails-html-sanitizer 1.0.3 to >= 1.0.4
# sanitize 4.5.0 to >= 4.6.3
bundle-audit check --ignore CVE-2018-3741 CVE-2018-3740 > $TMP
if [ "`cat $TMP |wc -l`" != "1" ]; then
   cat $TMP
   echo "Please either update gem or if that is not possible update ignore list in"
   echo $0
   exit 1
fi
rm -f $TMP
exit 0
