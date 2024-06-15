<p align="center">
  <a href="https://wpspeedexpert.com/" target="_blank">
    <img src="https://wpspeedexpert.com/wp-content/uploads/2024/06/wpspeedexpert-dark-light-grey-400.webp">
  </a>
</p>

# migrate-websites-cloudpanel
Migrate WordPress website(s) from Cloudpanel to Cloudpanel

## Details
Rsync Pull, the script will run from the destination server. Very handy in case of a migration for example when you upgrade from Debian 11 to 12 and need to migrate all websites.

### About the script
Add your variables, domain name, site-user, passwords and remote server IP to the script. Copy the SSH-Key to the source server.
* The script will add the website and database using Cloudpanel CTL: clpctl
* Export and import the database and website files
* Set correct file ownership and permissions

If the website or database already exists it will generate an error when trying to create it and continue the script.

## Requirements
Linux, Cloudpanel (Debian & Ubuntu), clpctl, ssh-key
