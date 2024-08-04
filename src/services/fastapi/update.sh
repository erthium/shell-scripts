#!/bin/sh

cd /path/to/project
git pull
source venv/bin/activate
pip install -r requirements.txt
deactivate
systemctl restart project.service
