# ISPConfig Role - Ansible

[Title Overview]: #overview
[Title Minimal quickstart]: #minimal-quickstart
[Title Requirement]: #requirement
[Title Configuring the role]: #configuring-the-role
[Title Config Role Variables]: #variables
[Title Sources]: #sources
[Title License]: #license

## Summary

- [Overview][Title Overview]
- [Requirement][Title Requirement]
- [Minimal QuickStart][Title Minimal quickstart]
- [Configuring the role][Title Configuring the role]
- [Sources][Title Sources]
- [License][Title License]

## Overview

This role install and configure the ensemble of tools for ISPConfig system.

## Requirement
- Ansible 2.5 (not tested with previous versions)
- OS : Debian Stretch
- Hostname need to be set.

- Metronome XMPP Server is not installed.


## Minimal Quickstart

Install the role, then :

```
---
- hosts: localhost
  roles:
    - ispconfig
  vars:
    hostname_fqdn: 'xx@xx.xx'
    mysql_root_password: 'apfjapfjpaj'

```

## Configuring the role
### Variables

| VARIABLE                                        | TYPE          | REQUIRED | DEFAULT                                      | DESCRIPTION |
|-------------------------------------------------|---------------|----------|----------------------------------------------|-------------|
| mysql_root_password                             | string        | yes      | none                                         | Needed by mysql |
| hostname_fqdn                                   | string        | yes      | none                                         | Needed by the role |
| mailman_email                                   | string        | no       | none                                         | Install and configure mailman if definied. Also need mailman_password |
| mailman_password                                | string        | no       | none                                         | Needed by mailman_email |


## Sources
- https://www.howtoforge.com/tutorial/perfect-server-debian-9-stretch-apache-bind-dovecot-ispconfig-3-1/2/
- https://www.howtoforge.com/tutorial/securing-ispconfig-3-with-a-free-lets-encrypt-ssl-certificate/
- https://github.com/ahrasis/LE4ISPC
- https://www.security-helpzone.com/2015/12/03/securiser-postfix-avec-lantispam-amavis/

## License

This file is part of Waccounts.

Waccounts is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Waccounts is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Waccounts.  If not, see <https://www.gnu.org/licenses/>.