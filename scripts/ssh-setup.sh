#!/bin/bash

echo
echo 'Purpose: This utility creates an SSH key, copies the public key to the Raspberry Pi, and updates the OpenSSH config file.'
echo 'Platform: Linux and macOS'
echo 'Version: 1.0, September 2019'
echo 'Author: Dave Glover, http://github.com/gloveboxes'
echo 'Licemce: MIT. Free to use, modify, no liability accepted'
echo
echo

BC=$'\033[30;48;5;82m'
EC=$'\033[0m'

while true; do
    read -p "Enter Raspberry Pi Network IP Address: " PYLAB_IPADDRESS < /dev/tty
    read -p "Enter your login name: " PYLAB_LOGIN < /dev/tty
    read -p "Raspberry Pi Network Address ${BC}$PYLAB_IPADDRESS${EC}, login name ${BC}$PYLAB_LOGIN${EC} Correct? ([Y]es,[N]o,[Q]uit): " yn < /dev/tty
    case $yn in
        [Yy]* ) break;;
        [Qq]* ) exit 1;;
        [Nn]* ) continue;;
        * ) echo "Please answer yes(y), no(n), or quit(q).";;
    esac
done

PYLAB_SSHCONFIG=~/.ssh/config
PYLAB_TIME=$(date)

if [ ! -d "~/.ssh" ]; then
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh
fi

if [ ! -f ~/.ssh/id_rsa_python_lab ]; then 
	echo
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Generating SSH Key file ~/.ssh/id_rsa_python_lab"
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo

	ssh-keygen -t rsa -N "" -b 4096 -f ~/.ssh/id_rsa_python_lab < /dev/tty
fi

echo
echo '++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
echo 'Copying SSH Public Key to the Raspberry Pi'
echo
echo -e '\033[30;48;5;82mAccept continue connecting: type yes \033[0m'
echo -e '\033[30;48;5;82mThe Raspberry Pi Password is raspberry \033[0m'
echo
echo -e '\033[30;48;5;82mThe password will NOT display as you type it \033[0m'
echo -e '\033[30;48;5;82mWhen you have typed the password press ENTER \033[0m'
echo
echo -e '\033[30;48;5;82mYou may need to press ENTER twice \033[0m'
echo '++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
echo

ssh-copy-id -i ~/.ssh/id_rsa_python_lab $PYLAB_LOGIN@$PYLAB_IPADDRESS < /dev/tty

if [ $? == 0 ]; then
	echo '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
	echo "Updating SSH Config file $PYLAB_SSHCONFIG"
	echo '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
	echo

	echo >> $PYLAB_SSHCONFIG
	echo "#Begin-PyLab $PYLAB_TIME" >> $PYLAB_SSHCONFIG
	echo "Host pylab-$PYLAB_LOGIN" >> $PYLAB_SSHCONFIG
	echo "    HostName $PYLAB_IPADDRESS" >> $PYLAB_SSHCONFIG
	echo "    User $PYLAB_LOGIN" >> $PYLAB_SSHCONFIG
	echo "    IdentityFile ~/.ssh/id_rsa_python_lab" >> $PYLAB_SSHCONFIG
	echo "#End-PyLab" >> $PYLAB_SSHCONFIG
	echo >> $PYLAB_SSHCONFIG
else 
	echo
	echo "Copy of the SSH Public Key to the Raspberry Pi failed"
	echo
fi

