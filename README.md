# BEACON link dump format

This repository contains drafts of the **BEACON link dump format** specification. BEACON is a data interchange format for large numbers of uniform links.  

The format was developed to exchange mappings between authority files and resources incultural institutions but it can also serve as serialization format for RDF graphs with uniform triples.  

## Specification

Specification drafts are managed and published [in a GitHub repository](https://github.com/gbv/beaconspec):

* [latest version](https://gbv.github.io/beaconspec/beacon.html)
* [draft-003](https://gbv.github.io/beaconspec/draft-voss-beacon-003.html) (December 2017)
* [draft-002](https://gbv.github.io/beaconspec/draft-voss-beacon-002.html) (November 2017)
* [draft-001](https://gbv.github.io/beaconspec/draft-voss-beacon-002.html) (July 2014)

Earlier drafts had been developed in Wikipedia starting in February 2010:

* [BEACON format](https://de.wikipedia.org/wiki/Wikipedia:BEACON/Format) (German Wikipedia)

## Use cases

* [BEACON files used in/by Wikipedia](https://de.wikipedia.org/wiki/Wikipedia:BEACON) (most comprehensive list)
* [BEACON exported by Wikidata tool](https://tools.wmflabs.org/wikidata-todo/beacon.php)
* [findbuch.de link aggregator](https://beacon.findbuch.de/)
* Link shorteners archived by http://urlte.am/ are BEACON without meta fields (see [helper script](https://github.com/ArchiveTeam/urlteam-stuff/blob/master/tools/mkbeacon.pl) to add metadata)
* [wdmapper](https://wdmapper.readthedocs.io/) uses BEACON as output format for mappings extracted from Wikidata, see [BEACON files at project coli-conc](http://coli-conc.gbv.de/concordances/wikidata/)
* [wikidata-taxonomy](https://www.npmjs.com/package/wikidata-taxonomy) contains the script `wdmappings` to extract ontology mappings in BEACON format
* ...

## Implementations

The implementations are not fully aligned with the current state of specification. Most applications don't use dedicated implementations because the format is simple enough to create/parse "by hand".

* [Java implementation](https://github.com/thunken/beacon)
* [Perl implementation](https://metacpan.org/release/Data-Beacon)
* [JavaScript implementation](https://github.com/gbv/beacon-js) (work in progress)
* ... 

## How to modify this specification

The specification of BEACON link dump format is being prepared in a public git
repository, located at <https://github.com/gbv/beaconspec>. It uses the
technique described in [RFC 7328](https://tools.ietf.org/html/rfc7328.html).

The specification is written in Pandoc Markdown syntax in the file `beacon.md`.
Additional parts are included in the file `appendices.md`, `rfctemplate.xml`,
and bibliographic references in the directory `ref`. To compile the
specification in RFC style there is a `Makefile`. To create a snapshot in HTML
and TXT format you need:

* [Pandoc](http://johnmacfarlane.net/pandoc/),
* an XSLT transformator (`xsltproc`),
* [xml2rfc](http://xml.resource.org/) version 2.

To install at Ubuntu Linux with Python, call:

    sudo apt-get install pandoc xsltproc xml2rfc
    sudo pip install xml2rfc

To further install `pandoc2rfc` after cloning the repository you must call:

    git submodule update --init

You can then modify `beacon.md`, `appendices.md`, `rfctemplate.xml` and create
a nice HTML version by simply invoking `make`.

