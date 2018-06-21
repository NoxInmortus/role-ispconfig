AWH Zabbix Agent - Ansible
=========

This role install and configure `Zabbix Agent`

Version Available :
-------------------
- 2.4 

Compatible OS
------------

- Debian Wheezy
- Debian Jessie
- Ubuntu Trusty (12.04)
- Ubuntu Utopic (12.10)

TODO:
----
- Centos 6 & 7

Role Variables
--------------

- `zabbix_server`           : IP address (or hostname) of Zabbix server (default `127.0.0.1`).
- `zabbix_agent_listenport` : Listen port for Agent (default `10050`).
- `zabbix_agent_timeout`    : Timeout (default `30`).
- `zabbix_agent_logfile`    : Name of Log file (default `/var/log/zabbix/zabbix_agentd.log`).
- `zabbix_agent_pidfile`    : Name of PID file (default `/var/run/zabbix/zabbix_agentd.pid`).

Example Playbook
----------------

```
- hosts: myhosts
  user: devops
  sudo: true
  roles:
   - awh-zabbix-agent
  vars:
    zabbix_server             : 10.0.0.6
    zabbix_agent_listenport   : 10050
```
         
Tests
----
Go to directory `tests` and use `docker-compose` :

```

 # Test Wheezy :
 docker-compose run --rm wheezy

 # Test Jessie :
 docker-compose run --rm jessie

 # Test Ubuntu :
 docker-compose run --rm ubuntu
 
```

License
-------


Author Information
------------------

 - Nicolas Berthe - ALTERWAY/Hosting