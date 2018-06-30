# Dev-server (Ansible playbook)

*Dev-server* is an [Ansible](https://www.ansible.com/) playbook for
setting up a server with [Apache](https://httpd.apache.org/), IMAP, SMTP,
[GitLab](https://about.gitlab.com/) (with embedded Git server) and [Jenkins](https://jenkins.io/).
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

Parameter `<config_directory>` is a directory with configuration files;
the configuration files define for example the port numbers or subdomains
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

 * https://git.sample-server.example.com (`testuser@sample-server.example.com` / `S3cre1Passw0rd`)
 * https://jenkins.sample-server.example.com (`testuser` / `S3cre1Passw0rd`)
 * https://minio.sample-server.example.com (`SAMPLEACCESSKEY` / `secretKey`)
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

For GitLab there's a lot to configure:

 * GitLab itself (Git server, GitLab web interface),
 * regular backups (of Git repositories, project wikis, issue tracker) to S3,
 * sending out emails (when for example a ticket is created in GitLab issue tracker).
 
File `sample-config/vars/gitlabVars.yml` defines many configuration options which will be described
later.

You can re-run the installation using this command:
  
`./run.sh configurations/sample-config sample-server --tags gitlab`

#### ports

The playbook installs GitLab to Docker. The `ports` variable defines the mapping of the
host machine ports (HTTPS, HTTP and SSH respectively) onto the Docker container ports
(see [Ansible documentation of docker_container](
https://docs.ansible.com/ansible/latest/modules/docker_container_module.html), parameter `published_ports`). 

#### directories

The `baseDir` variable defines the GitLab root directory on the host machine.

Subdirectories you might be interested in:

 * `/srv/gitlab/data/git-data/repositories` - the Git repositories,
 * `/srv/gitlab/logs` - logs of GitLab and related tools,
 * `/srv/gitlab/data/backups` - regular backups (these are uploaded to S3, see later).
 
I don't recommend to edit `/srv/gitlab/config/gitlab.rb` directly. This file is generated automatically by
the Dev-server Ansible playbook, so it would be overwritten if you ran the playbook. Rather tweak the
playbook itself. The template is in `<playbook_root>./roles/gitlab/templates/gitlab.rb`

#### sending emails

GitLab can be configured to send emails when for example a new ticket is created
in the issue tracker. The `smtp` section of the configuration file defines all
it needs to be able to do so. In this sample configuration the SMTP server the one
set up by this Ansible playbook (see above).

#### regular backups

GitLab can be configured to regularly dump all its data (Git repositories content, wikis, issue tracker tickets),
TAR them and upload them to an S3 bucket. You can either use an S3 bucket on Amazon or use some S3-compatible
server. The Dev-server playbook ships with a setup for [Minio](https://www.minio.io/), which implements
an S3-compatible API, so you can test the backups straight on the virtual machine. See the Minio
setup section above to see how you can use Dev-server Ansible playbook to set up Minio for you
(note that in production you will probably not want to set up GitLab and Minio on the same server,
but rather on different servers in different geographical locations).

If you are using S3 on Amazon, do not define parameters `host` and `endpoint`.
If you are using S3 on an S3-compatible server, set `host` to the hostname and
`endpoint` to the full URL of the API endpoint.

Parameters `provider`, `region`, `accessKeyId` and `secretAccessKey` are standard
S3 parameters. If you are hosting your own S3-compatible server, read the documentation
to your server to see what `provider` and `region` shall be set to (for Minio
`AWS` and `eu-central-1` work fine).

Parameters `minute` and `hour` define when a backup should be taken. They will be
passed to cron.

#### restore from backups

If you need to restore GitLab from an existing backup, run the playbook like this:

`./run.sh <config_directory> <host_config_name> --extra-vars "gitlabRestoreDir=<local_directory_with_backups> gitlabRestoreFrom=<backup_file_base_name>"`

Parameters `<config_directory>` and `<host_config_name>` are the same as described above.
Parameter `<local_directory_with_backups>` is path (relative or absolute) to the directory where you have
the TAR file with the backup you wish to restore GitLab from.
Parameter `<backup_file_base_name>` is the name of the backup file with the trailing
`_gitlab_backup.tar` bit stripped off.

The Dev-server playbook ships with a sample TAR file with a backup. Once restored, the GitLab will contain
one user account (email: `testuser@sample-server.example.com`, password: `S3cre1Passw0rd`).
This backup contains a single Git repository. Further in this document a Jenkins setup
is described.

### Jenkins setup

For Jenkins there's again a lot to configure:

 * Jenkins itself (UI and user account for the UI),
 * credentials used for cloning projects from Git,
 * jobs for building and deploying the projects.
 
#### ports
 
The playbook installs Jenkins to Docker. The `ports` variable defines the mapping of the
host machine ports (only HTTPS in this case) onto the Docker container ports
(see [Ansible documentation of docker_container](
https://docs.ansible.com/ansible/latest/modules/docker_container_module.html), parameter `published_ports`). 

#### directories

The `additionalVolumes` variable defines mappings of the host machine directories onto the
docker container directories.

This is especially useful for deploying an app built by Jenkins. That way Jenkins can copy
the artifacts created during the build for example to an Apache `/var/www/html/` directory.
The artifacts themselves will be located in the Jenkins
`/var/jenkins_home/deployTargets/<job_id>` directory, where `<job_id>` is the ID
of the job defined in the `projects` section (see below). 

#### user account

At the moment the playbook allows only a single user account to be created automatically for Jenkins UI
(additional accounts can be created from the UI).

The relevant parameters are `jenkinsUsername` and `jenkinsPassword`.

#### credentials for connecting to GitLab

Each entry has an `id` (referred to from the project configuration), an arbitrary `description`
and the credentials themselves (parameters `username` and `password`).

#### jobs

You can define as many jobs as you wish in the `projects` section.
Again, specify an `id`; a directory with the name being the same as the ID will created
inside `/var/jenkins_home/deployTargets/` inside the container. This can then be used
to copy the generated artifacts to the host machine (see above).

You can also define an arbitrary `description`.

Then the Git URL
(`gitUrl`), branch (`gitBranch`) and the ID of the credentials entry defined earlier
(`gitCredentialsId`).

The last two parameters define how to build and deploy the project.
Parameter `gitPollCron` specifies is a cron expression defining when Jenkins should poll
Git to see if there were any changes and if that's the case, to update the project
from Git and trigger a build. Parameter `buildScript` is a piece of shell code
whose purpose is to build and deploy the project.

### Backup pruner setup

[Backup pruner](https://github.com/pr83/backup-pruner) 
is a tool helping with regular cleanup of old backups.
It periodically scans a given directory (filesystem, S3 and SFTP are currently supported)
containing the backups, removing files which are likely the least valuable ones, preventing
the directory from unlimited growth.

Since we have set up regular backups of GitLab to S3, we can use Backup pruner to
keep the number of the backups reasonably small.

You can find an example Backup pruner configuration in
`configurations/sample-config/vars/backupPrunerVars.yml`.
The parameter names correspond to the environment variables as described in
Backup pruner [Official documentation](https://github.com/pr83/backup-pruner).
In the sample configuration we are connecting to Minio on the virtual machine.
To connect to Amazon, do not mention the `s3Endpoint` parameter.

### Proxy setup

The services we installed to our sample server are available on nice URLs
such as https://git.sample-server.example.com, but looking to the configuration files
for the individual services it turns out that they are actually set up to be
available on URLs with port numbers, such as http://git.sample-server.example.com:1180
(and they actually are, as you can easily try).

The mapping of the "nice" URLs onto the URLs with port numbers is defined in
`configurations/sample-config/vars/proxyVars.yml`. The file should be pretty
straightforward. It configures an [nginx](https://www.nginx.com/) acting
as a [reverse proxy](https://en.wikipedia.org/wiki/Reverse_proxy).