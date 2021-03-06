#!/bin/bash

readonly logName="/var/log/server-setup.log"

echo "Starting $(date)" | tee -a "${logName}"

echo "Install required tools " | tee -a "${logName}" 
yum install -y \
  docker \
  iptraf-ng \
  htop \
  tmux \
  vim \
  curl

echo "Setting up ssh access"  | tee -a "${logName}"
curl -s https://github.com/jujhars13.keys | tee -a /home/ec2-user/.ssh/authorized_keys

# add ec2 user to the docker group which allows docket to run without being a super-user
usermod -aG docker ec2-user

# running docker daemon as a service
chkconfig docker on
service docker start

echo "Sleeping 2s - wait for docker to start" | tee -a "${logName}"
sleep 2s 

echo "Creating rudemntary web app " | tee -a "${logName}"
mkdir -p /home/ec2-user/webapp
echo "<html><body><h1>Welcome CS peeps</h1><div> We hope you enjoy our cs server</div></body></html>" | tee -a /home/ec2-user/webapp/index.html

echo "Starting nginx web server " | tee -a "${logName}"
docker run -d \
    --restart always \
    -v /home/ec2-user/webapp:/usr/share/nginx/html \
    -p 80:80 \
    nginx

echo "get normal docker entrypoint" | tee -a "${logName}"
# we want to override this from the docker container to customise it
curl https://raw.githubusercontent.com/JimTouz/counter-strike-docker/master/hlds_run.sh -o /custom-entrypoint.sh
sed -i '2 a rm -f /opt/hlds/cstrike/addons/amxmodx/configs/maps.ini' /custom-entrypoint.sh
chmod +x /custom-entrypoint.sh

echo "Starting CS server" | tee -a "${logName}"
# courtesy of https://github.com/JimTouz/counter-strike-docker
docker run -d \
  --restart always \
  -p 26900:26900/udp \
  -p 27020:27020/udp \
  -p 27015:27015/udp \
  -p 27015:27015 \
  -e MAXPLAYERS=32 \
  -e START_MAP=fy_snow \
  -e SERVER_NAME="Economist C19 game server" \
  -e START_MONEY=16000 \
  -e BUY_TIME=1 \
  -e FRIENDLY_FIRE=1 \
  -e ADMIN_STEAM=0:1:1234566 \
  -e SERVER_PASSWORD=__SERVER_PASSWORD__ \
  -e RCON_PASSWORD=__RCON_PASSWORD__ \
  -v /custom-entrypoint.sh:/bin/custom-entrypoint.sh \
  --name cs \
  --entrypoint=/bin/custom-entrypoint.sh \
  cs16ds/server:latest +log

echo "Finished $(date)" | tee -a "${logName}"
