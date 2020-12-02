#!/bin/bash



# set version
websitebackup_version="1.0.0"
# set date
websitebackup_date="02.12.2020"
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
connection_details="$ssh_user@$ssh_host"

# you may have to install sshpass, see https://stackoverflow.com/a/62623099/753676 for details
# alternatively create and use a SSH key, which is more secure

# set ssh connection
connection_ssh="sshpass -p$ssh_password ssh $connection_details"

# get more details for debugging
# connection_ssh="sshpass -p$ssh_password ssh -vt $connection_details"

# set scp connection
connection_scp="sshpass -p$ssh_password scp $connection_details"


# retrieve and save hostkey if needed, the entries are hashed for better security, alternatively remove the -H option
# ssh-keyscan -H $ssh_host >> ~/.ssh/known_hosts


# clean up remote backup directory
$connection_ssh "rm -rfv $backups_path" && echo "remote backup directory cleaned up"


# create remote backup directory
$connection_ssh "mkdir -p $backups_path/$backupname" && echo "remote backup directory created"

# create remote files backup
$connection_ssh "tar cfpz $backups_path/$backupname/$backupname""_files.tar.gz $website_path" && echo "remote files backup completed"

# create remote database backup
$connection_ssh "mysqldump -u $db_user -p'$db_password' $db_name --result-file=$backups_path/$backupname/$backupname'_database.sql'" && echo "remote database backup completed"


# create local backup directory
mkdir $backupname && echo "created local backup directory"


# download remote files backup
$connection_scp:$backups_path/$backupname/$backupname"_files.tar.gz" $backupname && echo "downloaded remote files backup"

# download remote database backup
$connection_scp:$backups_path/$backupname/$backupname"_database.sql" $backupname && echo "downloaded remote database backup"


# delete remote files backup
$connection_ssh "rm $backups_path/$backupname/$backupname'_files.tar.gz'" && echo "deleted remote files backup"

# delete remote database backup
$connection_ssh "rm $backups_path/$backupname/$backupname'_database.sql'" && echo "deleted remote database backup"

# delete remote backup directory
$connection_ssh "rm -d $backups_path/$backupname" && echo "deleted remote backup directory"
