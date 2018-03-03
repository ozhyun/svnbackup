#!/bin/sh

for dir in /data/repos/*
do
	if [ -d $dir ]; then
		echo "$dir"
		grep 'db = ' $dir/conf/svnserve.conf 
	fi
done

