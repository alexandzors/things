#!/bin/bash

#add docker key

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

#add docker repo

add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" -y

#app update

apt-get update -y

#install docker

apt-get install docker-ce -y

# Thi script is used for automated VM deployment so I don't have to constantly setup docker on new swarm nodes :)
