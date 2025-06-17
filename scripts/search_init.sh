#!/bin/bash

. ./scripts/load_python_env.sh

echo "Checking if search index should be setup..."

./.venv/bin/python ./app/backend/search_init.py
