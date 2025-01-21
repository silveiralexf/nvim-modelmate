#!/bin/bash

# Sets terminal color support
export TERM=screen-256color

NC='\033[0m' # No Color
RED='\033[0;31m'
GREEN='\033[0;32m'
INFO="${GREEN}[INFO]${NC}"
ERROR="${RED}[ERROR]${NC}"

required_utils=(
  ollama
  git-cliff
  q
  pre-commit
  task
)

for util in "${required_utils[@]}"; do
  if command -v "${util}" >/dev/null; then
    echo -e "${INFO} found required util ${util} in path"
  else
    echo -e "${ERROR} ${util} not found, check docs to have it installed before proceeding" 1>&2
    exit 1
  fi
done

echo -e "${INFO} all required utils found in path"
exit 0
