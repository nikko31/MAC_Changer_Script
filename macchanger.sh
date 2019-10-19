#!/bin/bash

################
##    INFO    ##
################

VERSION="0.1"
AUTHOR="Nico"
YEAR="2019"

################
##   COLORS   ##
################

RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' #NoColor

BOLD=$(tput bold)
NORMAL=$(tput sgr0)

ERROR="${BOLD}${RED}ERROR:${RS}${NORMAL}   "
INFO="${BOLD}${BLUE}INFO:${RS}${NORMAL}    "
WARNING="${BOLD}${YELLOW}WARNING:${RS}${NORMAL} "

################
## FUNCTIONS  ##
################
generateMac() {
  printf `openssl rand -hex 6 | sed 's/\(..\)/:\1/g; s/^.\(.\)[0-3]/\12/; s/^.\(.\)[4-7]/\16/; s/^.\(.\)[89ab]/\1a/; s/^.\(.\)[cdef]/\1e/'`
}

check_device() {
    ifconfig $1 > /dev/null 2> /dev/null
    if [[ $? -ne 0 ]]
    then
        echo -e "${ERROR}Can not find device / interface. Maybe it is down?\n" >&2
        exit 1
    fi

}

currentMac () {
    CURRENT=`ifconfig $1 2> /dev/null`

    if [[ $? -ne 0 ]]
    then
        printf "${ERROR}Can not find device / interface. Maybe it is down?\n"
        exit 1
    fi

    echo -e `awk '/ether/ {print $NF}' <<< "$CURRENT"`
}

print_help () {
    echo 'Usage:'
    echo '  sudo macchanger [option] [interface] '
    echo 'Options'
    echo '  -v, --version         Show version'
    echo '  -s, --show            Show MAC address'
}

show_mac () {
    CURRENT=`ifconfig $1 2> /dev/null` #redirect stderr to file /dev/null
    if [[ $? -ne 0 ]]
    then
        echo -e "${ERROR}Can not find device / interface. Maybe it is down?\n" >&2
        exit 1
    fi

    echo -e "MAC Address: "`awk '/ether/ {print $NF}' <<< "$CURRENT"`
}

################
##   PROGRAM  ##
################

#Check operating system. Must be OSX
if [[ `uname` != "Darwin" ]] 
then
    echo -e "${ERROR}MACChanger is for OSX only!" >&2
    exit 1
fi

#Check if it is privileged user EUID == 0
if [[ $EUID -ne 0 ]]
then
    ME=$(whoami | tr [:lower:] [:upper:])
    echo -e "
            ${ERROR} Damn, $ME! 
            Run macchanger as root:     sudo macchanger" >&2
    exit 1
fi

case "$1" in
    -v | --version) 
        echo -e "Version: $VERSION \nAuthor: $AUTHOR\nYear: $YEAR" 
        ;;

    -s | --show)
        if [[ -z $2 ]]
        then
            echo -e "${ERROR}required second parameter [interface]" >&2
            exit 1
        fi
        show_mac $2
        ;;
    -r | --random)
        if [[ -z $2 ]]
        then
            echo -e "${ERROR}required second parameter [interface]" >&2
            exit 1
        fi
    *) 
        print_help
        ;;
esac
