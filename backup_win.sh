#!/bin/bash



# set version
websitebackup_version="1.0.0"
# set date
websitebackup_date="03.05.2017"
# set author
websitebackup_author="Daniel Ruf (https://daniel-ruf.de)"

# output program information
echo "website backup $websitebackup_version ($websitebackup_date) by $websitebackup_author"


# set date
datestr=$(date +"%Y_%m_%d")

# set time
timestr=$(date +"%H_%M_%S")

# set backup directory name
backupname=$datestr"_"$timestr


# SSH connection settings, please change them
ssh_hostkey=43:51:43:a1:b5:fc:8b:b7:0a:3a:a9:b1:0f:66:73:a8
ssh_host=localhost
ssh_user=user
ssh_password=pass


# database connection settings, please change them
db_user=user
db_name=db
db_password=pass


# path settings, please change them
website_path=/www/absolute/path/website.tld/
backups_path=/backups/website


# set connection details
connection_details="-pw $ssh_password -hostkey $ssh_hostkey $ssh_user@$ssh_host"

# set plink connection
connection_plink="plink -ssh $connection_details"

# get more details like the hostkey
# connection_plink="plink -v -ssh $connection_details"

# set pscp connection
connection_pscp="pscp -sftp $connection_details"


# clean up remote backup directory
$connection_plink "rm -rfv $backups_path" && echo remote backup directory cleaned up


# create remote backup directory
$connection_plink "mkdir -p $backups_path/$backupname" && echo remote backup directory created

# create remote files backup
$connection_plink "tar cfpz $backups_path/$backupname/$backupname""_files.tar.gz $website_path" && echo remote files backup completed

# create remote database backup
$connection_plink "mysqldump -u $db_user -p'$db_password' $db_name --result-file=$backups_path/$backupname/$backupname'_database.sql'" && echo remote database backup completed


# create local backup directory
mkdir "$backupname" && echo created local backup directory


# download remote files backup
"$connection_pscp":$backups_path/"$backupname"/"$backupname""_files.tar.gz" "$backupname" && echo downloaded remote files backup

# download remote database backup
"$connection_pscp":$backups_path/"$backupname"/"$backupname""_database.sql" "$backupname" && echo downloaded remote database backup


# delete remote files backup
$connection_plink "rm $backups_path/$backupname/$backupname'_files.tar.gz'" && echo deleted remote files backup

# delete remote database backup
$connection_plink "rm $backups_path/$backupname/$backupname'_database.sql'" && echo deleted remote database backup

# delete remote backup directory
$connection_plink "rm -d $backups_path/$backupname" && echo deleted remote backup directory
