#!/bin/bash

if [ "$1" == 'true' ]; then
  flutter pub publish
else
  flutter pub publish --dry-run
fi