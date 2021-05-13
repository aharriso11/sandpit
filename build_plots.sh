#!/bin/bash
set -x #echo on

rm -f timestamp*

commit_string=$(date '+%Y_%m_%d_%H%M')

touch "timestamp${commit_string}"

rscript "/users/andrewharrison/Documents/R/covid admissions dorset.R"
rscript "/users/andrewharrison/Documents/R/covid dorset cases.R"
rscript "/users/andrewharrison/Documents/R/covid daily cases.R"

cd /users/andrewharrison/Documents/Github/sandpit

# echo "push_${commit_string}"

git add *.png
git commit -am "'push_${commit_string}'"
git push
