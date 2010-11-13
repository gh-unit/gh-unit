#!/bin/bash

set -e

for ext in "m" "h" "c"
do
	find . -type f -name "*.$ext" -exec perl -ni -e 'chomp; print "$_\n"' {} \;
done

# Ensures all files end with a newline.
for ext in "m" "h" "c"
do
  find . -type f -name "*.$ext" -print | xargs printf "e %s\nw\n" | ed -s;
done