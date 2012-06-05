#!/bin/bash

echo "" > beaconfiles

for url in $(lynx --dump http://de.wikipedia.org/wiki/Wikipedia:BEACON | grep -o "http:.*" | grep -v  "http://de.wikipedia" | sort | uniq)
do
    echo "|-- $url" >> beaconfiles
    curl "$url" | head -n20 >> beaconfiles	
done

grep '^#' beaconfiles | sort > metafields
