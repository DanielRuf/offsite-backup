@echo off


:: set the encoding to utf8
chcp 65001


:: set version
set websitebackup_version=1.0.0
:: set date
set websitebackup_date=03.05.2017
:: set author
set websitebackup_author=Daniel Ruf (https://daniel-ruf.de)

:: output program information
echo website backup %websitebackup_version% (%websitebackup_date%) by %websitebackup_author%


:: set date
set datestr=%date:~6,4%_%date:~3,2%_%date:~0,2%

:: set time
set timestr=%time:~0,2%_%time:~3,2%_%time:~6,2%
if "%timestr:~0,1%"==" " set timestr=0%timestr:~1,8%

:: set backup directory name
set backupname=%datestr%_%timestr%


:: SSH connection settings, please change them
set ssh_hostkey=43:51:43:a1:b5:fc:8b:b7:0a:3a:a9:b1:0f:66:73:a8
set ssh_host=localhost
set ssh_user=user
set ssh_password=pass


:: database connection settings, please change them
set db_user=user
set db_name=db
set db_password=pass


:: path settings, please change them
set website_path=/www/absolute/path/website.tld/
set backups_path=/backups/website


:: set connection details
set connection_details=-pw %ssh_password% -hostkey %ssh_hostkey% %ssh_user%@%ssh_host%

:: set plink connection
set connection_plink=plink.exe -ssh %connection_details%

:: get more details like the hostkey
:: set connection_plink=plink.exe -v -ssh %connection_details%

:: set pscp connection
set connection_pscp=pscp.exe -sftp %connection_details%


:: clean up remote backup directory
%connection_plink% rm -rfv %backups_path% && echo remote backup directory cleaned up


:: create remote backup directory
%connection_plink% mkdir -p %backups_path%/%backupname% && echo remote backup directory created

:: create remote files backup
%connection_plink% tar cfpz %backups_path%/%backupname%/%backupname%_files.tar.gz %website_path% && echo remote files backup completed

:: create remote database backup
%connection_plink% mysqldump -u %db_user% -p'%db_password%' %db_name% --result-file=%backups_path%/%backupname%/%backupname%_database.sql && echo remote database backup completed


:: create local backup directory
mkdir %backupname% && echo created local backup directory


:: download remote files backup
%connection_pscp%:%backups_path%/%backupname%/%backupname%_files.tar.gz %backupname% && echo downloaded remote files backup

:: download remote database backup
%connection_pscp%:%backups_path%/%backupname%/%backupname%_database.sql %backupname% && echo downloaded remote database backup


:: delete remote files backup
%connection_plink% rm %backups_path%/%backupname%/%backupname%_files.tar.gz && echo deleted remote files backup

:: delete remote database backup
%connection_plink% rm %backups_path%/%backupname%/%backupname%_database.sql && echo deleted remote database backup

:: delete remote backup directory
%connection_plink% rm -d %backups_path%/%backupname% && echo deleted remote backup directory
