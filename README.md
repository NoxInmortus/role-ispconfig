# ISPConfig - Ansible Role

[Title Overview]: #overview
[Title Minimal quickstart]: #minimal-quickstart
[Title Requirement]: #requirement
[Title Configuring the role]: #configuring-the-role
[Title Config Role Variables]: #variables
[Title Tags]: #tags
[Title Sources]: #sources
[Title Credits]: #credits
[Title License]: #license

## Summary

- [Overview][Title Overview]
- [Requirement][Title Requirement]
- [Minimal QuickStart][Title Minimal quickstart]
- [Configuring the role][Title Configuring the role]
- [Tags][Title Tags]
- [Sources][Title Sources]
- [Credits][Title Credits]
- [License][Title License]

## Overview

This role install and configure the ensemble of tools for ISPConfig system. But it does a little more than that :

- Install jailkit through repository
- Install certbot through backports repository
- Security enforcement (see below)
- Postfix tuning
- Apache2 tuning
- MySQL tuning

After deploying the entire role : `cd /tmp/ispconfig3_install/install && php -q install.php`
Once everything is installed, generate a let's encrypt certificate for your `hostname_fqdn variable`.
You can get the `mysql_root_password` if automatically generated in `/root/.my.cnf`
Then start the role again with `ispconfig_ssl` tag to use the let's encrypt certificate.

If you want to update your ispconfig installation, run `php -q update.php` instead of `php -q install.php`.

Security Enforcement :
- /etc/fail2ban/jail.local
- /etc/apache2/conf-enabled/roundcube.conf
- /etc/apache2/conf-enabled/phpmyadmin.conf
- /etc/apache2/conf-enabled/security.conf

- Access Roundcube interface : `https://<hostname_fqdn>/webmail`
- Access PhpMyAdmin interface : `https://<hostname_fqdn>/databases` (every scriptkiddy is looking for /phpmyadmin or something close).

There is also an iptables sample with required firewall rules for make everything works fine, with a few security rules in bonus. Check the `recommanded-firewall.md` file.

## Disclaimer

This role is hudge, it install a lot of stuff (and it does not install clamav by the way), and although I managed to make dozens of tests, I may have missed some issues, so feel free to contact me or to help me out improving this role.

## Requirement

- Ansible 2.5
- OS : Debian Stretch

## Minimal Quickstart

Install the role, then :

```
---
- hosts: localhost
  roles:
    - ispconfig
  vars:
    hostname_fqdn: 'foo.org'
```

## Configuring the role

There is a lot of variables (list) used to manage packages and other stuff, feel free to take a look in `defaults/main.yml` and to surcharge vars if needed.

The install process is quite clear and commented, all tasks have explicit name, you won't be lost if you want to understand how the whole stuff works.

For a full installation, you will want to set every `instal_xxx` variables to true. But you may not want to install everything.

### Variables

| VARIABLE                        | TYPE   | REQUIRED | DEFAULT | DESCRIPTION          |
|---------------------------------|--------|----------|---------|----------------------|
| hostname_fqdn                   | STRING | yes      | none    | FQDN for the system. |
| mysql_root_password             | STRING | no       | none    | Mysql root password. A random password will be generated if not defined, but this is viable for a one-shot deployement, don't relaunch mysql tasks after that. |
| admin_email                     | STRING | no       | none    | Required for mailman & used by rkhunter. |
| admin_email_mailman_password    | STRING | no       | none    | Required for mailman. A random password will be generated if admin_email is defined and install_mailman is true. |
| security_whitelist              | LIST   | no       | none    | IPs to whitelist for fail2ban, postfix, roundcube and phpmyadmin. |
| pureftpd_passive_ports          | STRING | no       | '47000 47100' | Passive ports for pureftpd. |
| pureftpd_quota_mount            | STRING | no       | none    | mount-point path for pure-ftpd quota configuration. Example : `/dev/mapper/Debian9--Template--vg-root` |
| postfix_relayhost               | STRING | no       | none    | Configure a relayhost for postfix. |

| VARIABLE                 | TYPE   | REQUIRED | DEFAULT | DESCRIPTION                     |
|--------------------------|--------|----------|---------|---------------------------------|
| install_preconfiguration | BOOL   | no       | false   | Deploy pre-configuration tasks  |
| install_apt              | BOOL   | no       | false   | Deploy apt tasks (base packages install) |
| install_security_packages| BOOL   | no       | false   | Install & configure security packages (rkhunter, fail2ban...) |
| install_jailkit          | BOOL   | no       | false   | Install & configure jailkit |
| install_postfix          | BOOL   | no       | false   | Install & configure postfix |
| install_mail_security    | BOOL   | no       | false   | Install & configure amavis & spamassassin |
| install_mailman          | BOOL   | no       | false   | Install & configure mailman. Require admin_email |
| install_pureftpd         | BOOL   | no       | false   | Install & configure pureftpd |
| install_pureftpd_ssl     | BOOL   | no       | false   | Configure SSL for pureftpd. Require ftp variables. Notice that ssl certificate will be overwrited if ispconfig_ssl tasks are deployed. |
| install_apache2          | BOOL   | no       | false   | Install & configure apache2 |
| install_php              | BOOL   | no       | false   | Install php7.0 |
| install_php7_1           | BOOL   | no       | false   | Install php7.1 (will have php7.0 + php7.1 as default version) |
| install_php7_2           | BOOL   | no       | false   | Install php7.2 (will have php7.0 (+ php7.1 if enabled) + php7.2 as default version) |
| install_mysql            | BOOL   | no       | false   | Install & configure mysql |
| install_mysql_secure     | BOOL   | no       | false   | Deploy mysql_secure_installation tasks |
| install_phpmyadmin       | BOOL   | no       | false   | Install phpmyadmin |
| install_roundcube        | BOOL   | no       | false   | Install & configure roundcube. You need to run mysql and apache2 tasks before roundcube |
| install_ispconfig        | BOOL   | no       | false   | Get ISPConfig installer in /tmp/ |
| install_ispconfig_ssl    | BOOL   | no       | false   | Configure ISPConfig,postfix, pureftpd and dovecot with let's encrypt certificate |
| install_metronome        | BOOL   | no       | false   | Install Metronome XMPP Server in /opt/metronome |
| install_finalize         | BOOL   | no       | false   | Deploy finalization tasks |
| mysql_already_installed  | BOOL   | no       | false   | Consider passing this var to true after a first deploy of mysql tasks. This will skip the mysql tasks using/touching the root password. Useful when you did not have defined mysql_root_password and it is generated automatically |
roundcube_already_installed| BOOL   | no       | false   | Consider passing this var to true after a first deploy of roundcube tasks. This will skip the task using mysql root password. Useful when you did not have defined mysql_root_password and it is generated automatically |

#### FTP Variables
| VARIABLE             | TYPE   | REQUIRED | DEFAULT | DESCRIPTION         |
|----------------------|--------|----------|---------|---------------------|
| ftp_ssl_country      | string | no       | none    | Country two first letters (US,EN,FR,ES...) |
| ftp_ssl_state        | string | no       | none    | State               |
| ftp_ssl_locality     | string | no       | none    | City                |
| ftp_ssl_organization | string | no       | none    | Organization        |
| ftp_ssl_ou           | string | no       | none    | Organisation Unit   |

## Tags
You can start a set of tasks using some tags (feel free to use):

```
ispconfig_preconfiguration
ispconfig_apt
ispconfig_jailkit
ispconfig_postfix
ispconfig_mailman
ispconfig_pureftpd
ispconfig_apache2
ispconfig_php
ispconfig_mysql
ispconfig_mysql_secure
ispconfig_phpmyadmin
ispconfig_roundcube
ispconfig_installer
ispconfig_ssl
ispconfig_metronome
ispconfig_finalize
```

## Sources
- https://www.howtoforge.com/tutorial/perfect-server-debian-9-stretch-apache-bind-dovecot-ispconfig-3-1/2/
- https://www.howtoforge.com/tutorial/securing-ispconfig-3-with-a-free-lets-encrypt-ssl-certificate/
- https://github.com/ahrasis/LE4ISPC
- https://www.security-helpzone.com/2015/12/03/securiser-postfix-avec-lantispam-amavis/
- https://www.howtoforge.com/community/threads/resolved-dkim-issue.78804/#post-373349

### Fail2ban sources
- https://www.tartarefr.eu/proteger-apache-avec-fail2ban/
- https://www.supinfo.com/articles/single/2660-proteger-votre-vps-apache-avec-fail2ban
- https://technique.arscenic.org/securite/article/fail2ban-limitation-des-tentatives-d-intrusion
- https://www.digitalocean.com/community/tutorials/how-to-protect-an-apache-server-with-fail2ban-on-ubuntu-14-04
- https://www.muehlencord.de/wordpress/2015/07/28/protecting-servers-with-fail2ban-apache-httpd-webserver/

## Credits

Author : Alban E.G.

## License

This file is part of the ISPConfig ansible role.

The ISPConfig ansible role is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

The ISPConfig ansible role is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with the ISPConfig ansible roles.  If not, see <https://www.gnu.org/licenses/>.
