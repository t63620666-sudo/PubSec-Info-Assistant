#!/bin/bash

. ./scripts/load_python_env.sh

echo 'Running "prepdocscosmos.py"'

additionalArgs=""
if [ $# -gt 0 ]; then
  additionalArgs="$@"
fi

./.venv/bin/python ./app/backend/prepdocscosmos.py './data/*' --verbose $additionalArgs
