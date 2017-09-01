#!/usr/bin/env bash

set -e

cmd="$*"

sleep 5

until [ -f "node_modules/.ready" ]; do
  sleep 1
done

exec $cmd
