This git repository contains a formal specification of BEACON format.

BEACON is a simple format for serialization and distribution of uniform RDF
triples. It is primarily used to collect mappings between authority files
and information resources in libraries and related organizations.

## Sources

The specification is located in the file `beacon.md` in Pandoc Mardown syntax.
This files is used to create HTML and other output formats, including RFC.

Sources and recent changes can be found at http://github.com/gbv/beaconspec.
Snapshots in HTML and other formats are at http://gbv.github.com/beaconspec.

## Quick install

There is a `Makefile` to transform the specification into other output formats.
It requires [Pandoc](http://johnmacfarlane.net/pandoc/), an XSLT transformator
(`xsltproc`) and [xml2rfc](http://xml.resource.org/).

For Ubuntu Linux: 

    sudo aptitude install pandoc xsltproc xml2rfc

