#!/bin/bash

data="$1"

git add /home/lluc/scripts
git commit -m "$data"
git push
