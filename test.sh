#!/bin/sh

MONTH=2592000
#for dir in /data/repos/*
for dir in /root/*
do
	if [ -d $dir ]; then
		t=`date +%s -r $dir`
		now=`date +%s`
		diff=$[ $now - $t ]
		if [ $diff -gt $MONTH ]; then
			echo "$dir change 1 month ago ($diff)"
		else
			echo "$dir changed $diff seconds ago"
		fi

		#grep 'db = ' $dir/conf/svnserve.conf 
	fi
done

