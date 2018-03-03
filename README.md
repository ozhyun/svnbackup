# SVN Backup
Can be used in crontab:
#Sunday do full backup
30 01 * * 0 /data/backup_repos.sh full
#Monday ~ Saturday do incr backup
30 01 * * 1-6 /data/backup_repos.sh incr

