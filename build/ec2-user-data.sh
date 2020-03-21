#!/bin/bash

readonly logName="/var/log/server-setup.log"

echo "Starting " | tee -a "${logName}"


echo "Install required tools " | tee -a "${logName}" 
yum install -y \
  docker \
  iptraf-ng \
  htop \
  tmux \
  vim

# add ec2 user to the docker group which allows docket to run without being a super-user
usermod -aG docker ec2-user

# running docker daemon as a service
chkconfig docker on
service docker start

echo "Sleeping 2s - wait for docker to start" | tee -a "${logName}"
sleep 2s 

echo "Creating rudemntary web app " | tee -a "${logName}"
mkdir -p /home/ec2-user/webapp
echo "<html><body><h1>Welcome CS peeps</h1><div> We hope you enjoy our webpage. - The Economist</div></body></html>" | tee -a /home/ec2-user/webapp/index.html

echo "Starting nginx container " | tee -a "${logName}"
docker run -d \
    --restart always \
    -v /home/ec2-user/webapp:/usr/share/nginx/html \
    -p 80:80 \
    nginx

echo "Finished " | tee -a "${logName}"
