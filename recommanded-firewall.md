# SECURITY
## Protect from Flood / DDOS
```
iptables -A FORWARD -p tcp --syn -m limit --limit 1/second -j ACCEPT
iptables -A FORWARD -p udp -m limit --limit 1/second -j ACCEPT
iptables -A FORWARD -p icmp --icmp-type echo-request -m limit --limit 1/second -j ACCEPT
```
## Protect from port scans
```
iptables -A FORWARD -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s -j ACCEPT
```
# Recommanded rules
## ICMP
```
iptables -A INPUT -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT
```
## Traceroute
```
iptables -A INPUT -p udp --sport 33434:33524 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT -m comment --comment "Traceroute IN"
iptables -A OUTPUT -p udp --dport 33434:33524 -m state --state NEW -j ACCEPT -m comment --comment "Traceroute OUT"
```
## DNS
```
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT -m comment --comment "DNS OUT TCP"
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT -m comment --comment "DNS OUT UDP"
iptables -A INPUT -p tcp --dport 53 -j ACCEPT -m comment --comment "DNS OUT TCP"
iptables -A INPUT -p udp --dport 53 -j ACCEPT -m comment --comment "DNS OUT UDP"
```
## NTP
```
iptables -A OUTPUT -p udp --dport 123 -j ACCEPT -m comment --comment "NTP OUT"
```
## HTTP, HTTPS
```
iptables -A INPUT -p tcp -m multiport --dports 80,443 -j ACCEPT
iptables -A OUTPUT -p tcp -m multiport --dports 80,443 -j ACCEPT
```
## HKP (apt-key)
```
iptables -A OUTPUT -p tcp --dport 11371 -j ACCEPT -m comment --comment "allow apt-key"
```
## Mail SMTP + TLS/SSL
```
iptables -A OUTPUT -p tcp -m multiport --dports 25,587 -j ACCEPT
```
## ISPConfig Interface
```
iptables -A INPUT -p tcp --dport 8080 -j ACCEPT -m comment --comment "TCP 8080 (ISPConfig)"
```
## Mail INPUT
```
iptables -A INPUT -p tcp -m multiport --dports 25,587 -j ACCEPT
```
## FTP
```
iptables -A INPUT -p tcp --dport 21 -j ACCEPT
iptables --append INPUT --protocol tcp --dport 47000:47100 --jump ACCEPT -m comment --comment "FTP Passive ports"
```
## POP3
```
iptables -A INPUT -p tcp -m multiport --dports 110,995 -j ACCEPT -m comment --comment "POP3/SSL"
```
## IMAP
```
iptables -A INPUT -p tcp -m multiport --dports 143,993 -j ACCEPT -m comment --comment "IMAP/SSL"
```
