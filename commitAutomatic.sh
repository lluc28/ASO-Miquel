#!/bin/bash

data="$1"

git add .
git commit -m "$data"
git push
