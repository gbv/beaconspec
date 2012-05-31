This git repository contains specification of **BEACON link dump format** to be
prepared for publication as Request for Comment (RFC).

# BEACON format

BEACON is a simple format to serialize a number of uniform links. 
It is primarily used to collect mappings between authority files
and information resources in libraries and related organizations.

# How to modify the specification

A specification of BEACON link dump format is being prepared in a public git
repository, located at <https://github.com/gbv/beaconspec>. The specification
is written in Pandoc Markdown syntax in the file `beacon.md`. Additional parts
are included in the file `appendices.md`, `rfctemplate.xml`, and bibliographic
references in the directory `ref`. To compile the specification in RFC style
there is a `Makefile`. To create a snapshot in HTML and TXT format you need:

* [Pandoc](http://johnmacfarlane.net/pandoc/),
* an XSLT transformator (`xsltproc`),
* [xml2rfc](http://xml.resource.org/).

To install at Ubuntu Linux, call:

    sudo aptitude install pandoc xsltproc xml2rfc

To further install `pandoc2rfc` after cloning the repository you must call:

    git submodule init
    git submodule update

You can then modify `beacon.md`, `appendices.md`, `rfctemplate.xml` and create
a nice HTML version by simply invoking `make`.

# Snapshots and recent changes

Sources and recent changes can be found at <http://github.com/gbv/beaconspec>.
A snapshots in HTML formats is at <http://gbv.github.com/beaconspec/beacon.html>.

