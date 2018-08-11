#!/bin/sh
TMP=/tmp/audit.$$
bundle-audit update
bundle-audit check  > $TMP
if [ "`cat $TMP |wc -l`" != "1" ]; then
   cat $TMP
   echo "Please either update gem or if that is not possible update ignore list in"
   echo $0
   exit 1
fi
rm -f $TMP
exit 0
