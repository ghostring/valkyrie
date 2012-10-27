#!/bin/bash
#
#
# Part of valkyrie                                  
# Copyright (C) Gika Megawan <mail@gika09.info>     
# This program is published under a GPLv3 license 
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# X CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
# AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNEC-
# TION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


user=`whoami`

function valkyrie_script {
echo '#!/bin/bash
#
#  This file is part of Valkyrie
#  Copyright (C) Gika Megawan <l0g.gika@yahoo.es>
#  This program is published under a GPLv3 license
#
#  Provides: Valkyrie
#  Short-Description: Start/stop the valkyrie network security daemon
#  Description: Controls the main valkyrie network security daemon "valkyrie.pl"

path_script="/opt/valkyrie/valkyrie.pl"
case $1 in 
	'start')
	start="$path_script start"
	$start
	;;
	'stop')
	stop="$path_script stop"
	$stop
	;;
	'restart')
	restart="$path_script restart"
	$restart
	;;
	'status')
	status="$path_script status"
	$status
	;;
	*)
	echo "Usage: valkyrie [start|stop|restart|status]"
	exit 1
	;;
esac
' > valkyrie
}

function perl_modules {
gnu_c=$(whereis gcc | awk '{print $2}')
gnu_make=$(whereis make | awk '{print $2}')
if [ "$gnu_c" != "" ]; then 
  if [ "$gnu_make" != "" ]; then
  
  cd modules/

  echo -n -e "\nInstalling Daemon::Control modules...\n"
  tar zxf Daemon-Control-0.000009.tar.gz
  cd Daemon-Control-0.000009
  perl Makefile.PL
  make && make install
  cd ..
  rm -r Daemon-Control-0.000009
  
  echo -n -e "\nInstalling List::MoreUtils modules...\n"
  tar zxf List-MoreUtils-0.33.tar.gz
  cd List-MoreUtils-0.33
  perl Makefile.PL
  make && make install
  cd ..
  rm -r List-MoreUtils-0.33
  
  echo -n -e "\nInstalling Net::SMTP::SSL modules...\n"
  tar zxf Net-SMTP-SSL-1.01.tar.gz
  cd Net-SMTP-SSL-1.01
  perl Makefile.PL
  make && make install
  cd ..
  rm -r Net-SMTP-SSL-1.01

  echo -n -e "\nInstalling Config::YAML::Tiny modules...\n"
  tar zxf Config-YAML-Tiny-1.42.0.tar.gz
  cd Config-YAML-Tiny-1.42.0
  perl Makefile.PL
  make && make install
  cd ..
  rm -r Config-YAML-Tiny-1.42.0
  
  echo -n -e "\nInstalling Net::Pcap::Easy modules...\n"
  tar zxf Net-Pcap-Easy-1.4207.tar.gz
  cd Net-Pcap-Easy-1.4207
  perl Makefile.PL
  make && make install
  cd ..
  rm -r Net-Pcap-Easy-1.4207
  cd ..
  else
    echo -n -e "\nError: Compile Failed, The GNU MAKE program not found\n"
    exit 1
  fi
else
  echo -n -e "\nError: Compile Failed, The GNU C program not found\n"
  exit 1
fi
}

function dependencies {
# iptables
iptable=$(whereis iptables | awk '{print $2}')
if [ "$iptable" == "" ]; then
  echo -n -e "Error: The depedencies 'iptables' not installed\n"
  exit 1
fi

# Ifconfig
ifconf=$(whereis ifconfig | awk '{print $2}')
if [ "$ifconf" == "" ]; then
  echo -n -e "Error: The depedencies 'ifconfig' not installed\n"
  exit 1
fi
}


function main {
echo -e "Installing valkyrie:\n";

# checking dependencies
dependencies

# checking perl modules
perl_modules

# creating directory
echo "Creating valkyrie directory..."
mkdir /opt/valkyrie
mkdir /var/log/valkyrie
mkdir /etc/valkyrie

# copying all file
echo "Copying all file to '/opt/valkyrie'"
cp -r * /opt/valkyrie
rm /opt/valkyrie/install.sh
rm /opt/valkyrie/uninstall.sh

# creating valkyrie file
echo "Creating valkyrie file..."
touch valkyrie
valkyrie_script

# copying program to 'sbin' directory
echo "Copying valkyrie program to '/sbin'"
chmod +x valkyrie
mv valkyrie /sbin/valkyrie

# copying file configuration to 'etc' directory
echo "Copying file configuration to '/etc'"
cp -r config/config.yml /etc/valkyrie

# copying file configuration to 'man8' directory
echo "Copying valkyrie manual pages to '/usr/share/man/man8'"
cp doc/*.gz /usr/share/man/man8

# set executable flag
chmod +x /opt/valkyrie/valkyrie.pl
chmod +x /opt/valkyrie/valkyrieMain.pl
chmod +x /opt/valkyrie/packetcapture.pm

echo -e "\nInstallation finished. Type valkyrie as root to run.\n"
exit 0
}
if [ "$user" == "root" ]; then
	echo -n -e "Are you sure you want to install valkyrie [Y/n]? "
	read lanjut
	if [ "$lanjut" == "Y" ] || [ "$lanjut" == "y" ]; then	
		echo -n -e "\nType \033[4menter\033[0m to read the license of valkyrie..."
		read 
		more doc/COPYING
                loops="True"
                while [ $loops == "True" ]; do
		  echo -n -e "\nDo you agree [Y/n]? "
		  read agree
		  if [ "$agree" == "Y" ] || [ "$agree" == "y" ]; then	
			main
		  elif [ "$agree" == "N" ] || [ "$agree" == "n" ]; then
			exit 0
		  fi
                done
	else
		exit 0
	fi
else
	echo -e "Error: Cannot install valkyrie,\n       it may require superuser privileges (eg. root)."
	exit 1
fi
