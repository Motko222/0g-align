path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) 
folder=$(echo $path | awk -F/ '{print $NF}')
source $path/env

#create service
printf "[Unit]
Description=$folder node
After=network.target
Wants=network-online.target

[Service]
EnvironmentFile=/root/scripts/$folder/env
Environment=""
User=root
Group=root
ExecStart=$folder
Restart=always
RestartSec=30
LimitNOFILE=65536
LimitNPROC=4096
StandardOutput=journal
StandardError=journal
SyslogIdentifier=$folder
WorkingDirectory=/root/$folder

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/$folder.service

sudo systemctl daemon-reload
sudo systemctl enable $folder
