#!/bin/bash

A=$1
B=$2

if [ $# -ne 2 ]; then
    echo "Please specify two Beacon text files!" 1>&2
    exit 0
elif [ ! -f "$A" ]; then
    echo "File not found: $A" 1>&2
    exit 0
elif [ ! -f "$B" ]; then
    echo "File not found: $B" 1>&2
    exit 0
fi

MAP_A=`./beacon-meta-lines $A | awk -F': ' '/#TARGET:/ { print $2 }'`
MAP_B=`./beacon-meta-lines $B | awk -F': ' '/#PREFIX:/ { print $2 }'`

if [ "$MAP_A" != "$MAP_B" ]; then  
    echo "PREFIX and TARGET do not match!" 1>&2
    exit 0
fi

PREFIX=`./beacon-meta-lines $A | awk -F': ' '/#PREFIX:/ { print $2 }'`
TARGET=`./beacon-meta-lines $B | awk -F': ' '/#TARGET:/ { print $2 }'`

echo "#PREFIX: $PREFIX"
echo "#TARGET: $TARGET"
echo

./beacon-link-lines $A | ./beacon-sort -vk=3 > a.beacon.tmp
./beacon-link-lines $B | ./beacon-sort -vk=1 > b.beacon.tmp

join -t \| -1 3 -2 1 -o 1.1 -o 2.3 a.beacon.tmp b.beacon.tmp |  sed 's/|/||/'
