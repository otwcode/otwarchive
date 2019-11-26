#!/bin/bash

# Skip if there's a special string in the commit message.
if [[ $CI_MESSAGE =~ "[skip codeship tests]" ]]; then
  echo "Skipped Codeship tests."
  exit 0
fi

# By default, retry a command 3 times before exiting with errors.
MAX_LOOP=${TRIES:-3}
n=0
export TEST_RUN="$1"

until [[ $n -ge $MAX_LOOP ]]; do
  echo "Attempt $n"
  bash -c "$2" && break # substitute your command here
  n=$[$n+1]
done

if [[ $n -eq $MAX_LOOP ]]; then
  exit 1
fi
exit 0
