#!/usr/bin/env bash
# a hardening script for debian based systems

linesx () {
  val=$(tput cols)
  x=1
  while [ $x -le $val ]; do
    echo -n 🦡
    x=$((x+1));
  done
}

buildoutbound () {
  GATEWAY="$(cat /etc/resolv.conf | grep name | cut -d' ' -f2 | head -n1)";
  /usr/sbin/ufw allow out to $GATEWAY port 53;
  GATEWAY="$(cat /etc/resolv.conf | grep name | cut -d' ' -f2 | head -n2 | tail -n1)";
  /usr/sbin/ufw allow out to $GATEWAY port 53;
  /usr/sbin/ufw allow out to any port 123 proto udp;
  echo -e "\e[1:24m WARNING \e[0m- opening up port 123/udp for NTP to any destination! Change to explicit rules if you can!"
  echo
  for source in $(cat /etc/apt/sources.list /etc/apt/sources.list.d/*); do
    echo "$source" | grep ^http | sort -u | cut -d'/' -f3 | sort -u | while read line; do
      echo "building firewall rules for $line";
      IPADDR=$(/usr/sbin/traceroute -m1  $line | head -n1 | sed 's/,//g' | cut -d' ' -f4 | sed 's/(//g' | sed 's/)//g');
      /usr/sbin/ufw allow out to $IPADDR port 80;
      /usr/sbin/ufw allow out to $IPADDR port 443;
    done
  done
}

perms () {
  chmod "$1" "$2"
  chown "$3":"$3" "$2"
}

user=$(whoami)
if [ "$user" = "root" ]; then
  echo "Proceeding as root."
else
  exit 1
fi

which aptitude || apt-get install aptitude -y || exit 1
which traceroute || aptitude install traceroute -y || exit 1

reset
echo "$(date +%Y%m%d%H%M%S) starting run."
linesx
echo
echo
echo -e "\e[1;32m deb_hardener starting"
echo
echo
aptitude install ufw apparmor -y
systemctl enable ufw
yes | /usr/sbin/ufw enable
/usr/sbin/ufw allow 22/tcp
/usr/sbin/ufw allow 443/tcp
/usr/sbin/ufw default deny outgoing
/usr/sbin/ufw default deny incoming

echo
echo
echo -e "\e[1;35m firewall rules for outbound based on apt sources\e[0m"
linesx
buildoutbound
linesx
echo
echo

/usr/sbin/ufw reload
aptitude install apparmor
systemctl enable apparmor
aptitude update -y || exit 1
aptitude upgrade -y
aptitude install apparmor-profiles -y

echo
echo
echo -e "\e[1;38m setting standard unix permissions and ownerships \e[0m"
echo
echo
perms 700 /root/ root
perms 755 /home/ root
perms 644 /etc/apt/sources.list root
perms 640 /etc/shadow root
perms 644 /etc/group root
perms 755 /etc root
perms 440 /etc/sudoers root
perms 755 /etc/systemd root
perms 755 /lib root
perms 755 /lib32 root
perms 755 /lib64 root
perms 755 /boot root
perms 555 /proc root
perms 755 /bin root
perms 755 /opt root
perms 755 /dev root
perms 755 /mnt root
perms 700 /lost+found root
perms 555 /sys root
perms 1777 /tmp root
perms 755 /run root
perms 755 /usr/sbin root
perms 755 /usr/local/sbin root
perms 755 /usr/bin root
perms 755 /usr/local/bin root

echo
echo -e "\e[1;32m exporting standard root \e[0mPATH"
echo
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin
echo
echo
echo "$(date +%Y%m%d%H%M%S) completed run."
