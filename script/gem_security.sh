#!/bin/sh
TMP=/tmp/audit.$$
bundle-audit update
# Ignoring issues related to outdated gems required for 4.0 step. To be updated at earliest convinience
bundle-audit check --ignore OSVDB-96425 OSVDB-131677 CVE-2015-3227 CVE-2015-7577 CVE-2016-6316 CVE-2016-2098 CVE-2016-2097 CVE-2016-0752 CVE-2015-7581 CVE-2015-7576 CVE-2016-0751 > $TMP
if [ "`cat $TMP |wc -l`" != "1" ]; then
   cat $TMP
   echo "Please either update gem or if that is not possible update ignore list in"
   echo $0
   exit 1
fi
rm -f $TMP
exit 0
