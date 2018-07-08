# ISPConfig Role - Ansible

This role install and configure the ensemble of tools for ISPConfig system.

## Compatibility
# ISPConfig Version :
- 3.1.1

# Compatible OS
- Debian Jessie

# Ansible
- Ansible 2.5
- Did not test with previous versions

## Example Playbook

```
- hosts: all
  roles:
   - ispconfig
```

## Requirements and what it does not:
- Hostname need to be set.

- NTP is not managed by this role (as it is already configured on the VMs templates).
- ufw is not installed.
- Metronome XMPP Server is not installed.

## Sources
- https://www.howtoforge.com/tutorial/perfect-server-debian-9-stretch-apache-bind-dovecot-ispconfig-3-1/2/
- https://www.howtoforge.com/tutorial/securing-ispconfig-3-with-a-free-lets-encrypt-ssl-certificate/
- https://github.com/ahrasis/LE4ISPC
- https://www.security-helpzone.com/2015/12/03/securiser-postfix-avec-lantispam-amavis/
