# migrate-websites-cloudpanel
Migrate WordPress website(s) from Cloudpanel to Cloudpanel

## Details
Rsync Pull, the script will run from the destination server. Very handy in case of a migration for example when you upgrade from Debian 11 to 12 and need to migrate all websites.

### About the script
* Add your variables, domain name, site-user, passwords and remote server IP.
* The script will add the website and database using Cloudpanel CTL: clpctl
* Export and import the database and website files
* Set correct file ownership and permissions

## Requirements
Linux, Cloudpanel (Debian & Ubuntu), clpctl, ssh-key
