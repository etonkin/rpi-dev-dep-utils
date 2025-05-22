#!/bin/bash
# get wired ether addr (assuming eth0 exists: this isn't going to work on everything but it does on RPi Ubuntu)
etheraddr=$(ifconfig| grep  -e eth0 -A 1| grep ether | sed -re 's/\s+ether(.*)\s+txq(.*)/\1/g')
#test for whether etheraddr is an empty string, bin out if so 
if [ -z "${etheraddr}" ]; then
	echo "Couldn't find eth0 addr. Cowardly refusing to change machine name to semi-empty string"
	exit 1
fi

#echo "Machine wired ether IP: $etheraddr";
# get last three bytes of wired ether addr
lastthreebytes=$(echo $etheraddr | sed -re 's/(.[^:]*):(.[^:]*):(.[^:]*):(.*)/\4/g')
# test for whether last3bytes is expected length, bin out if not
last3len=${#lastthreebytes}
if (( $last3len != 8 )); then
	echo "Couldn't find appropriate length last 3 bytes; found $last3len"
	exit 1
fi


#echo "Origin last3bytes $lastthreebytes";
nogaplast3=${lastthreebytes//:/}
machinename="t-$nogaplast3"
echo "New machine name for device with etheraddr $etheraddr: $machinename"
hostnamectl set-hostname $machinename
# also alter /etc/hosts to refplect hostname
# needs a reboot to commit to it
sed -i 's/127.0.1.1.*/127.0.1.1\tREPLACEME/' /etc/hosts
sed -i "s/REPLACEME/$machinename/" /etc/hosts
