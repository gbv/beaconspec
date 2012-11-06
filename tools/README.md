# Beacon processing tools

This directory contains some command line tools to process Beacon files. Most
of the tools are designed form Beacon text format only.

## Extracting meta lines and link lines

- **beacon-link-lines** removes the meta fields of a Beacon text file
- **beacon-meta-lines** only prints the meta fields of a Beacon text file

## Sorting link lines

**beacon-sort** sorts the link lines of a Beacon text file. One can specify the
link token with parameter `-vk=1` (source token), `-vk=2` (annotation token) or
`-vk=3` (target token). Some usage examples:

    awk -f beacon-sort example.beacon
    awk -f beacon-sort -vk=3 example.beacon
    beacon-sort < example.beacon
    cat example.beacon | beacon-sort -vk=2

## Joining links

Simple joins on Beacon text files can be executed if the `TARGET` of file A equals to
the `PREFIX` of file B. The script **beacon-join.sh** tries to do so, but it may not
catch every edge case yet.

## Transforming from and to RDF

The scripts `beacon2nt.awk` and `nt2beacon.awk` may not reflect the current state of
the Beacon specification.

