#!/bin/bash

echo "" > tmp

for url in $(lynx --dump http://de.wikipedia.org/wiki/Wikipedia:BEACON | grep -o "http:.*" | grep -v  "http://de.wikipedia" | sort | uniq)
do
    echo "$url"
    curl "$url" | head | grep '^#' >> tmp
done

sort tmp > metafields

