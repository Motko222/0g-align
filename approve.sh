path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) 
folder=$(echo $path | awk -F/ '{print $NF}')
source /$path/env

read -p "Address? " address
read -p "Token ids? " ids

cd /root/$folder
./0g-alignment-node approve --key $ZG_ALIGNMENT_NODE_SERVICE_PRIVATEKEY --tokenIds $ids --chain-id 42161 \
 --rpc https://arb1.arbitrum.io/rpc --contract 0xdD158B8A76566bC0c342893568e8fd3F08A9dAac  --destNode $address
