# Dev-server (Ansible playbook)

*Dev-server* is an [Ansible](https://www.ansible.com/) playbook for
setting up a server with [Apache](https://httpd.apache.org/), IMAP, SMTP,
[GitLab](https://about.gitlab.com/) and [Jenkins](https://jenkins.io/).
It also sets up regular backups of the Git repositories into S3
(with the option to host S3 on your own server). It makes a heavy use of
Docker.

The playbook can be used "as is" for example to set up a server 
for a small development team. But feel free to modify as needed or
use it just for inspiration or for study purposes.

## Prerequisites

The following text assumes that:

 * You have configured a virtual machine and
installed Ubuntu 16.04.4 to it. Other Linux distributions and versions
are likely to work as well, but might need some tweaks. The playbook was
tested on Ubuntu Mate on HyperV.

 * The following text also assumes that you have configured a user called
`admin` with a password `S3cre1` and that user is configured as a
[sudoer](https://en.wikipedia.org/wiki/Sudo).

 * You have added the machine IP address to `/etc/hosts`. If the IP
 is let's say `172.27.238.245`, the relevant part of the hosts file
 should be:
    ```
    172.27.238.245 sample-server.example.com
    172.27.238.245 mail.sample-server.example.com
    172.27.238.245 git.sample-server.example.com
    172.27.238.245 jenkins.sample-server.example.com
    172.27.238.245 minio.sample-server.example.com
    172.27.238.245 www.sample-server.example.com
    ```

Knowledge of Ansible is in theory not needed if you plan to use the playbook as is. But it's highly recommended, because
it's likely you will need to do at least minor tweaks to the playbook. Also, without some understanding of Ansible it's
hard to troubleshoot when things don't work as expected.  
    
## Running the playbook

The playbook is shipped with a wrapper script `run.sh`.
It is run like this:

`./run.sh <config_directory> <host_config_name> <ansible_extra_params>`

Parameter `<config_directory>` defines for example the port numbers or subdomains
on which the various services will be available, user names and passwords for these
services etc. The Dev-server playbook ships with a sample configuration
(directory `configurations/sample-config`). You can define as many configurations as you wish,
they don't need to be placed under the Dev-server root directory
(in that case `<config_directory>` will be an absolute path). 

Parameter `<host_config_name>` is the name of the Ansible
[inventory file](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html), which should
be located in `<config_directory>/hosts`. The inventory file defines which machine the
playbook should be applied to and how to connect to that machine. For a given configuration
you may define as many inventory files as you wish, simply place them to `<config_directory>/hosts`.

The `<ansible_extra_params>` bit stands for any extra parameters you wish to pass verbatim to Ansible,
such as `--tags` or `--extra-vars`.

### Setting up everything

If you feel like trying your luck, open `bash`, `cd` to the root directory of the playbook
and run the following command:

`./run.sh configurations/sample-config sample-server --extra-vars "gitlabRestoreDir=docs/sample-config gitlabRestoreFrom=1530037521_2018_06_26_11.0.0-rc13"`

What exactly this command does will be explained later.

It might take a while for everythis to get set up. If you don't see any apparent errors, try and hit
these URLs (they are using a self-signed certificate for HTTPS, so you will need to allow access in your browser):

 * https://git.sample-server.example.com (testuser@sample-server.example.com / S3cre1Passw0rd)
 * https://jenkins.sample-server.example.com (testuser / S3cre1Passw0rd)
 * https://minio.sample-server.example.com (SAMPLEACCESSKEY / secretKey)
 * https://sample-server.example.com/sample-web (this one may take several minutes to become available)
 
 ## Step by step guide
 
 The above command does a lot of things. This section will guide you through the individual steps and explain
 how to change the configuration and re-run the setup of individual features.
 
 ### Creating users
 
 File `sample-config/vars/usersVars.yml` specifies users which will be created. They will be automatically
 added to the sudoer file. Passwords are not set for them.
 
 You can re-run the user creating using this command:
 
 `./run.sh configurations/sample-config sample-server --tags users`
 
 ### Installing additional packages
 
As a part of the machine setup, Midnight Commander is installed.
 
You can re-run the installation using this command:
 
`./run.sh configurations/sample-config sample-server --tags mc`
  
### Installing Docker

File `sample-config/vars/dockerVars.yml` specifies the URL path and URL file name pf the Docker image
to install.

You can re-run the installation using this command:
 
`./run.sh configurations/sample-config sample-server --tags docker`

Note that in order to control Docker by Ansible, an additional Ansible package mus be installed. Since
Ansible is written in Python, the `pip` tool (package manager for Python) must be installed.

You can re-run the installation of `pip` using this command:
 
`./run.sh configurations/sample-config sample-server --tags pip`

### Settings up emails (IMAP, SMTP)

File `sample-config/vars/mailVars.yml` specifies parameters for the IMAP and SMTP servers.

**A note to parameter `domainname`:**
This is the part of the email addresses to the right of the `@` sign.
Note that in Ansible `{{ inventory_hostname }}` is the hostname of the machine being set up, as
defined in the inventory file (in the sample configuration this is `sample-server.example.com`).
So for the accounts created in the sample configuration the email addresses will be
`admin@sample-server.example.com` and `testuser@sample-server.example.com`.

The SMTP and IMAP servers themselves will be accessible on `mail.sample-server.example.com`
(the subdomain is defined in parameter `hostname`).

You can re-run the installation using this command:
 
`./run.sh configurations/sample-config sample-server --tags mail`

### Setting up Minio (S3 storage)

[Minio](https://www.minio.io/) is an S3-compatible server. It provides the same API
as Amazon S3 does, but it can be hosted on your own server.

Dev-server uses Minio as a storage for GitLab backups (see later).

File `sample-config/vars/minioVars.yml` defines the access and secret key and a list of buckets.

You can re-run the installation using this command:
  
`./run.sh configurations/sample-config sample-server --tags minio`

### Setting up GitLab

