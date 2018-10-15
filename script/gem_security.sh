#!/bin/sh
TMP=/tmp/audit.$$
bundle-audit update
# TODO remove CVE-2018-1000201 after AO3-2839
# TODO remove CVE-2018-14404 after AO3-5543
bundle-audit check --ignore CVE-2018-1000201 CVE-2018-14404 > $TMP
if [ "`cat $TMP |wc -l`" != "1" ]; then
   cat $TMP
   echo "Please either update gem or if that is not possible update ignore list in"
   echo $0
   exit 1
fi
rm -f $TMP
exit 0
