![snake_bounce](https://carefuldata.com/images/cdlogo.png)

# deb_hardener
A script for hardening debian based systems. This script restricts network traffic and applies apparmor and permissions.
The script can be used as an enforcer, running periodically. It does not delete ufw rules, but will write them based on /etc/apt/sources.list
as well as /etc/apt/sources.d/* inputs, everything starting with http will then get a single ICMP packet sent to it, which is okay if
it fails, we are just using the DNS resolution built in to ping to collect the IP and then write allow out firewall rules for ports 80 and 443.

## Warning!
This script denies all network traffic by default, allowing in 443 and 22 only, and out only to default gateway and apt sources 80 and 443.


### One approach...
Because denying outbound can be a lot to manage, you might disable ufw normally, and then if a security event is triggered, run the deb_hardener.sh
allowing it to deny outbound until the even is resolved.


## Example:

```
bash deb_hardener.sh
```
