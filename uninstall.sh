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

whoami=`whoami`

function main {
echo -e "Uninstalling valkyrie:\n"

echo "[+] Removing valkyrie installation directory..."
rm -r /opt/valkyrie

echo "[+] Removing valkyrie configuration directory..."
rm -r /etc/valkyrie 2> /dev/null
rm -r /var/log/valkyrie 2> /dev/null

echo "[+] Removing valkyrie program..."
rm /sbin/valkyrie 2> /dev/null

echo "[+] Removing valkyrie manual page..."
rm /usr/share/man/man8/valkyrie.8.gz 2> /dev/null

echo -e "\nUninstalling finished."
}

if [ "$whoami" == "root" ]; then
        echo -n -e "Are you sure you want to remove/uninstall valkyrie [Y/n]? "
	read agree
	if [ "$agree" == "Y" ] || [ "$agree" == "y" ]; then		
		if [ -d "/opt/valkyrie/" ]; then 
			main
		else
			echo -e "\nError: valkyrie program is not installed on your system"
			exit 1
		fi
	else
		exit 0
	fi
else
	echo -e "Error: Cannot remove/uninstall valkyrie,\n       it may require superuser privileges (eg. root)."
	exit 1
fi