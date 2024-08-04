#!/bin/sh

cd /path/to/project
git pull
yarn install
yarn build
systemctl restart project.service
