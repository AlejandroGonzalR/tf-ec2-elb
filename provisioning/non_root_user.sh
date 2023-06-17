#!/bin/bash

sudo useradd -m -s /usr/bin/bash ${username}
echo "${username}:${password}" | chpasswd
sudo chown -R ${username}:${username} /home/${username}
