#!/bin/bash
path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) 
folder=$(echo $path | awk -F/ '{print $NF}')

read -p "Sure? " c
case $c in y|Y) ;; *) exit ;; esac

#install binary
mkdir -p /root/$folder
cd /root/$folder
wget https://github.com/0gfoundation/alignment-node-release/releases/latest/0g-alignment-node
chmod +x 0g-alignment-node

#create env
cd $path
[ -f env ] || cp env.sample env
nano env
