#!/bin/bash

echo "Running as $USER"
echo "Adding user to remote machine:"
echo " - ssh key auth"
echo " - sudo nopasswd"
echo " "
echo -n "Admin username: "
read ROOT_USER
echo -n "Admin password: "
read -s ROOT_PASS
echo ""
echo -n "Remote host: "
read REMOTE_HOST
echo " "
echo "Using ssh key: ~/.ssh/id_rsa.pub"
SSH_KEY="$(cat ~/.ssh/id_rsa.pub)"

echo " "
echo "Running playbook..."

export ROOT_USER
export ROOT_PASS
export SSH_KEY

ansible-playbook -i $REMOTE_HOST, site.yml