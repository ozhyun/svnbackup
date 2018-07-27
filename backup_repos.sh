#!/bin/sh
REPOSITORY_DIR="/data/repos"
BACKUP_DIR="/data/backup"
DATE=$(date +%Y-%m-%d)
LAST_BACKUPED_VERSION="$BACKUP_DIR/VERSION"
RETVAL=0

usage() {
	echo $"Usage: $0  <full|incr|rotate> "
	RETVAL=1
}


do_full_backup() {
	local VERSION_FILE="$BACKUP_DIR/$DATE/VERSION"

	#create backup dir
	mkdir -p $BACKUP_DIR/$DATE
	
	#empty the version file
	if [ -f $VERSION_FILE ]; then
		rm -f $VERSION_FILE
	fi

	#backup authz & passwd
	cp -f $REPOSITORY_DIR/authz $BACKUP_DIR/$DATE
	cp -f $REPOSITORY_DIR/passwd $BACKUP_DIR/$DATE

	#backup all of the repositories
	for dir in $REPOSITORY_DIR/*
	do
		if [ -d $dir ]; then
			repos_name=$(basename $dir)
			version=$(svnlook youngest $dir)
			echo $repos_name $version >> $BACKUP_DIR/$DATE/VERSION
			echo $repos_name $version >> $LAST_BACKUPED_VERSION
			svnadmin hotcopy --clean-logs $dir $BACKUP_DIR/$DATE/$repos_name
		fi
	done
}

# remove the backup created one month ago
do_rotate() {
	local MONTH=2592000
	for dir in $BACKUP_DIR/*
	do
		if [ -d $dir ]; then
			create_time=`date +%s -r $dir`
			now=`date +%s`
			diff=$[ $now - $create_time ]
			if [ $diff -gt $MONTH ]; then
				echo "$dir change 1 month ago ($diff), remove now"
				rm -rf $dir
			fi
		fi
	done
}

do_incr_backup() {
	local VERSION_FILE="$BACKUP_DIR/$DATE/VERSION"

	# MUST did full backup at least once before running this routine 
	if [ ! -f $LAST_BACKUPED_VERSION ]; then
		echo $"Haven't done any full backup till now, please do full backup firstly!"
		RETVAL=1
		return
	fi

	#create backup dir
	mkdir -p $BACKUP_DIR/$DATE
	
	#empty the version file
	if [ -f $VERSION_FILE ]; then
		rm -f $VERSION_FILE
	fi

	#backup authz & passwd
	cp -f $REPOSITORY_DIR/authz $BACKUP_DIR/$DATE
	cp -f $REPOSITORY_DIR/passwd $BACKUP_DIR/$DATE
	
	#backup all of the repositories
	for dir in $REPOSITORY_DIR/*
	do
		if [ -d $dir ]; then
			repos_name=$(basename $dir)
			version_old=$(grep "$repos_name" $LAST_BACKUPED_VERSION | awk -F' ' '{print $2}')
			version_now=$(svnlook youngest $dir)
			if [ "$version_old" = "$version_now" ]; then
				echo "$repos_name hasn't changed since version $version_now"
				continue
			fi
			echo "$repos_name $version_old:$version_now" >> $BACKUP_DIR/$DATE/VERSION
			svnadmin dump $dir -r$version_old:$version_now --incremental > $BACKUP_DIR/$DATE/$repos_name.dump
		fi
	done

	#remove obsolete backup
	do_rotate
}


case "$1" in
	full)
		do_full_backup
		;;
	incr)
		do_incr_backup
		;;
	rotate)
		do_rotate
		;;
	*)
		usage
		;;
esac

exit $RETVAL

