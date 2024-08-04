#!/bin/sh

cd /path/to/project
source venv/bin/activate
uvicorn app.main:app
deactivate
