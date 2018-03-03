#!/bin/sh
REPOS_DIR="/data/repos"
for dir in $REPOS_DIR/*
do
	if [ -d $dir ]; then
		repos=$(basename $dir)
		version=$(svnlook youngest $dir)
		echo "$repos $version"
	fi
done
