path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) 
folder=$(echo $path | awk -F/ '{print $NF}')
source /$path/env

read -p "Address? " address
read -p "Token ids? " ids

cd /root/$folder
./0g-alignment-node approve --key $ZG_ALIGNMENT_NODE_SERVICE_PRIVATEKEY --tokenIds $ids \
--chain-id 16661 --contract 0x7BDc2aECC3CDaF0ce5a975adeA1C8d84Fd9Be3D9 --rpc "https://evmrpc.0g.ai" --destNode $address
