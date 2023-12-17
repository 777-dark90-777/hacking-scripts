#!/bin/bash

#create ascii banner torixy
echo -e "\e[31m
████████╗ ██████╗ ██████╗ ██╗██╗  ██╗██╗   ██╗
╚══██╔══╝██╔═══██╗██╔══██╗██║╚██╗██╔╝╚██╗ ██╔╝
   ██║   ██║   ██║██████╔╝██║ ╚███╔╝  ╚████╔╝ 
   ██║   ██║   ██║██╔══██╗██║ ██╔██╗   ╚██╔╝  
   ██║   ╚██████╔╝██║  ██║██║██╔╝ ██╗   ██║   
   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝   ╚═╝   
Version 1.0 by 777_dark90_777                             
\e[0m"






helpstring="Usage: torixy.sh [OPTION]...
Options:
  -install to	install tor, privoxy and netcat
  -start to start tor and privoxy
  -stop to stop tor and privoxy
  -h to show this help

Examples:
  sudo torixy.sh -install
  sudo torixy.sh -start
  sudo torixy.sh -stop
  torixy.sh -h"

if [ "$1" == "-h" ]; then
    echo "$helpstring"
    exit 1
fi

#check if runnnig as root
if [ "$EUID" -ne 0 ]
  then 
      echo -e "\e[31mPlease run as root\e[0m"
      echo "$helpstring"
  exit
fi

#if wrong parameter is given
if [ "$1" != "-install" ] && [ "$1" != "-start" ] && [ "$1" != "-stop" ] && [ "$1" != "-h" ]; then
    echo "wrong parameter"
    echo "$helpstring"
    exit 1
fi



#check if no parameter is given
if [ $# -eq 0 ]; then
    echo "No arguments supplied"
    echo "$helpstring"
    exit 1
fi

if [ "$1" == "-install" ]; then

    echo "check if tor is installed"
    #Che if tor installed
    if ! [ -x "$(command -v tor)" ]; then
    echo 'Error: tor is not installed, install tor.' >&2
    apt install -y tor
    tor --version
    #exit 1
    else
    echo 'tor is installed.' >&2
    fi

    #check if netcat is installed, if not install netcat
    if ! [ -x "$(command -v nc)" ]; then
    echo 'Error: netcat is not installed, install netcat.' >&2
    apt install -y netcat
    #exit 1
    else
    echo 'netcat is installed.' >&2
    fi

    #check if privoxy is installed, if not install privoxy
    if ! [ -x "$(command -v privoxy)" ]; then
    echo 'Error: privoxy is not installed, install privoxy.' >&2
    apt install -y privoxy
    privoxy --version
    #exit 1
    else
    echo 'privoxy is installed.' >&2
    fi

    #check if curl is installed, if not install curl
    if ! [ -x "$(command -v curl)" ]; then
    echo 'Error: curl is not installed, install curl.' >&2
    apt install -y curl
    #exit 1
    else
    echo 'curl is installed.' >&2
    fi

    #set temporary write permission to /etc/tor/torrc
    #backup file /etc/tor/torrc
    cp /etc/tor/torrc /etc/tor/torrc.bak

    #if ControlPort 9051 not exist add ControlPort 9051
    if ! grep -q "ControlPort 9051" /etc/tor/torrc; then
      echo "push /etc/tor/torrc setting" 
      chmod 777 /etc/tor/torrc
      echo "ControlPort 9051" >> /etc/tor/torrc
    else
      echo "ControlPort 9051 already exist"
    fi
      
    #if HashedControlPassword not exist add HashedControlPassword
    if ! grep -q "HashedControlPassword" /etc/tor/torrc; then
      echo HashedControlPassword $(tor --hash-password "hacktheworld" | tail -n 1) >> /etc/tor/torrc
    else
      echo "HashedControlPassword already exist"
    fi
    
    #set original permission to /etc/tor/torrc
    chmod 644 /etc/tor/torrc

    #if 127.0.0.1:9050 not exist in /etc/privoxy/config add 
    if ! grep -q "forward-socks5t / 127.0.0.1:9050 ." /etc/privoxy/config; then
      echo "push /etc/privoxy/config setting" 
      #set temporary write permission to /etc/privoxy/config
      chmod 777 /etc/privoxy/config
      #backup file /etc/privoxy/config
      cp /etc/privoxy/config /etc/privoxy/config.bak
      echo "forward-socks5t / 127.0.0.1:9050 ." >> /etc/privoxy/config
      chmod 644 /etc/privoxy/config
    else
      echo "forward-socks5t / 127.0.0.1:9050 . already exist" 
    fi

    echo "all set, use ./torixy.sh -start to start tor and privoxy"
    #se original permission to /etc/privoxy/config
fi

#if $OPTARG == "start"
if [ "$1" == "-start" ]; then
    #start tor
    tor --version
    service tor start
    service tor status
    echo "check if tor is running"

    #start privoxy
    echo "start privoxy, if fail disable ipv6 with the comand sed -i "s/.*\[::1\]:8118/# &/" /etc/privoxy/config"
    service privoxy start
    service privoxy status

    ip=$(curl -s http://icanhazip.com/)
    torip=$(torify curl -s http://icanhazip.com/)

    echo "Current IP is: $ip"
    echo "Current Tor IP is: $torip"

    echo "check authentication"
    echo -e 'AUTHENTICATE "hacktheworld"\r\nsignal NEWNYM\r\nQUIT' | nc 127.0.0.1 9051

    ip=$(curl -s http://icanhazip.com/)
    torip=$(torify curl -s http://icanhazip.com/)

    echo "Current IP is: $ip"
    echo "Current Tor IP is: $torip"

    #create explanaition variable string for user
    echo "Run torify firefox www.duckduckgo.com or..."
    echo "You can also set proxy in firefox [HTTP and HTTPs 127.0.0.1 Port 8118]"
    echo "Good practice to start a local vpn before access to tor network"
fi

#if $OPTARG == "stop"
if [ "$1" == "-stop" ]; then
    echo "stop tor and privoxy"
    service tor stop
    service privoxy stop
fi



