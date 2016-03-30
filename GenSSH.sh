#!/bin/bash

function echo_indent {
	echo "   "${1}
}

function echo_red {
        color=31
        echo -e "\033[0;${color}m${1}\033[0;39m"
}

function echo_green {
        color=32
        echo -e "\033[0;${color}m${1}\033[0;39m"
}

function echo_yellow {
        color=33
        echo -e "\033[0;${color}m${1}\033[0;39m"
}

function echo_blue {
        color=34
        echo -e "\033[0;${color}m${1}\033[0;39m"
}

function prereq {
        echo_green "### Checking for the installation of required commands... ###"
        requisites=git,xclip,ssh-add,ssh-keygen
        for prereq_com in `echo ${requisites} | sed -e "s/,/ /g"`
                do
                com_bin=`which ${prereq_com}`
                if [ -z ${com_bin} ];then
                        echo_indent ${prereq_com}" is missing! Please install. "`echo_red "(Warn)"`
                        echo_indent "On RPM-based distros (e.g. RedHat, Fedora, CentOS, etc...), issue - as a super-user;"
                        echo_yellow "yum install "${prereq_com}
                        echo_indent "On APT-based distros (e.g. Debian, Ubuntu, etc...), issue - as a super-user;"
                        echo_yellow "apt-get install "${prereq_com}
                        echo_indent "On other distros, please refer to appropriate documentations on installing commands - OR you should already know. :P"
                else
                        echo_indent ${prereq_com}" is installed and is available as "${com_bin}" ! "`echo_green "(Good)"`
                fi
        done
        echo "Paused for 10sec"
        sleep 10s
}

function description {
	echo_green "### What this script will do... ###"
	echo_indent "This scripts aims to help beginners to GitHub on initial setup procedures."
	echo ""
	echo_indent "Usage;"
	echo_indent '-e:"you@example.com" -n:"Your Name"'
	echo_indent ""
	echo_indent ""
	echo_indent ""
	echo_indent ""
	echo_indent ""
	echo_indent ""
}

function pending {
git config --global user.email ${email}
git config --global user.name ${name}

# Creates a new ssh key, using the provided email as a label
det_ssh=`find ~/.ssh/ -type f | grep rsa`
if [ -z "${det_ssh}" ];
	then
	ssh-keygen -t rsa -b 4096 -C ${email}
fi

# start the ssh-agent in the background
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

# Downloads and installs xclip. If you don't have `apt-get`, you might need to use another installer (like `yum`)
sudo apt-get install xclip

# Copies the contents of the id_rsa.pub file to your clipboard
xclip -sel clip < ~/.ssh/id_rsa.pub
}

clear

prereq

description
