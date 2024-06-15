#!/bin/bash
# =========================================================================== #
# Description:        Migrate website(s) from Cloudpanel to Cloudpanel
# Details:            Rsync Pull, the script will run from the destination server.
# Made for:           Linux, Cloudpanel (Debian & Ubuntu) - clpctl.
# Requirements:       clpctl | ssh-keygen | ssh-copy-id root@0.0.0.0 (replace IP)
# Author:             WP Speed Expert
# Author URI:         https://wpspeedexpert.com
# Version:            0.1.0
# Make executable:    chmod +x rsync-pull-migrate.sh
# GitHub URI:         https://github.com/WPSpeedExpert/generatepress-child-epicdeals
# =========================================================================== #
# Variables
#
domainName=("domainName.com")
siteUser=("siteUser")
siteUserPassword=("!SecretPassword!")
#
vhostTemplate=("WordPress") # WooCommerce
phpVersion=("8.3")
#
databaseName=${siteUser} # change if different to siteuser
databaseUserName=${siteUser} # change if different to siteuser
databaseUserPassword=("!SecretPassword!")
#
REMOTE_SERVER_SSH=("root@0.0.0.0") # replace IP
#
LogFile=("/home/${siteUser}/rsync-pull-migrate.log")
#
# Empty the log file
truncate -s 0 ${LogFile}

# Log the date and time
echo "[+] NOTICE: Start script: $(date -u)" 2>&1 | tee -a ${LogFile}

# Add the website in CLP
echo "[+] NOTICE: Add the website to Cloudpanel: ${domainName}" 2>&1 | tee -a ${LogFile}
clpctl site:add:php --domainName=${domainName} --phpVersion=${phpVersion} --vhostTemplate=''${vhostTemplate}'' --siteUser=${siteUser} --siteUserPassword=''${siteUserPassword}''

# Add the database for the website in CLP
echo "[+] NOTICE: Add the database to Cloudpanel: ${databaseName}" 2>&1 | tee -a ${LogFile}
clpctl db:add --domainName=${domainName} --databaseName=${databaseName} --databaseUserName=${databaseUserName} --databaseUserPassword=''${databaseUserPassword}''

# Clean and remove destination website files (except for the wp-config.php & .user.ini)
echo "[+] NOTICE: Clean up the destination website files: /home/${siteUser}/htdocs/${domainName}" 2>&1 | tee -a ${LogFile}
rm -rf /home/${siteUser}/htdocs/${domainName}/
#

# Export the remote MySQL database
echo "[+] NOTICE: Export the remote database: ${databaseName}" 2>&1 | tee -a ${LogFile}
# Use Cloudpanel CLI
ssh ${REMOTE_SERVER_SSH} "clpctl db:export --databaseName=${databaseName} --file=/home/${siteUser}/tmp/${databaseName}.sql.gz" 2>&1 | tee -a ${LogFile}

echo "[+] NOTICE: Synching the database: ${databaseName}.sql.gz" 2>&1 | tee -a ${LogFile}
rsync -azP ${REMOTE_SERVER_SSH}:/home/${siteUser}/tmp/${databaseName}.sql.gz /home/${siteUser}/tmp 2>&1 | tee -a ${LogFile}

# Cleanup remote database export file
echo "[+] NOTICE: Clean up the remote database export file: /home/${siteUser}/tmp/${databaseName}.sql.gz" 2>&1 | tee -a ${LogFile}
ssh ${REMOTE_SERVER_SSH} "rm /home/${siteUser}/tmp/${databaseName}.sql.gz"

# Import the MySQL database:
echo "[+] NOTICE: Import the MySQL database: ${databaseName} ..." 2>&1 | tee -a ${LogFile}
# Use Cloudpanel CLI
clpctl db:import --databaseName=${databaseName} --file=/home/${siteUser}/tmp/${databaseName}.sql.gz 2>&1 | tee -a ${LogFile}

echo "[+] NOTICE: Clean up the database export file: /home/${siteUser}/tmp/${databaseName}.sql.gz" 2>&1 | tee -a ${LogFile}
rm /home/${siteUser}/tmp/${databaseName}.sql.gz

# Rsync website files (pull)
echo "[+] NOTICE: Start Rsync pull" 2>&1 | tee -a ${LogFile}
rsync -azP --update --delete --no-perms --no-owner --no-group --no-times --exclude 'wp-content/cache/*' ${REMOTE_SERVER_SSH}:/home/${siteUser}/htdocs/${domainName}/ /home/${siteUser}/htdocs/${domainName}

# Set correct ownership
echo "[+] NOTICE: Set correct ownership: ${siteUser} /home/${siteUser}/htdocs/${domainName}" 2>&1 | tee -a ${LogFile}
chown -Rf ${siteUser}:${siteUser} /home/${siteUser}/htdocs/${domainName}

# Set correct file permissions for folders
echo "[+] NOTICE: Set correct file permissions (755) for folders: /home/${siteUser}/htdocs/${domainName}" 2>&1 | tee -a ${LogFile}
chmod 00755 -R /home/${siteUser}/htdocs/${domainName}

# Set correct file permissions for files
echo "[+] NOTICE: Set correct file permissions (644) for files: /home/${siteUser}/htdocs/${domainName}/" 2>&1 | tee -a ${LogFile}
find /home/${siteUser}/htdocs/${domainName}/ -type f -print0 | xargs -0 chmod 00644

# Flush & restart Redis
echo "[+] NOTICE: Flush and restart Redis." 2>&1 | tee -a ${LogFile}
redis-cli FLUSHALL
sudo systemctl restart redis-server

# End of the script
echo "[+] NOTICE: End of script: $(date -u)" 2>&1 | tee -a ${LogFile}
exit 0
