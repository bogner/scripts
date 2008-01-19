#!/bin/bash
# deletes config files that were generated this session and not last

whitelist="${HOME}/scripts/clean_configs-whitelist"
greylist="${HOME}/scripts/clean_configs-greylist"
wd="${HOME}"

cd $wd
delete=$(
    ls -d $(cat $whitelist) \
        $(cat $greylist) | \
        diff - <(ls -A | awk '/^\./') | \
        awk '/^>/ { for (i = 2; i <= NF; ++i) print $i }'
    )
ls -A | awk '/^\./' > $greylist
#rm -f $delete
echo "greylist is now:"
cat $greylist
echo
echo "you may check and run the following:"
echo "( cd $wd; rm -f $delete )"
