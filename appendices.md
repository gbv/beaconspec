# Glossary

BEACON
  : is a data interchange format as specified in this document.
BEACON file
  : is a link dump serialized in BEACON text format or BEACON XML format.
BEACON text format
  : is a condense format to serialize link dumps as specified in this document. 
BEACON XML format
  : is an XML format to serialize link dumps as specified in this document. 
link
  : is a triple of source URI, target URI, and annotation.
link dump
  : is a set of links and meta fields with common relation type for all links.
link token
  : is a Unicode string in a BEACON files used to construct a link.
source database
  : is the set (or superset) of all source URIs in a link dump.
target database
  : is the set (or superset) of all target URIs in a link dump.
relation type
  : a common releation between targets and sources in a link dump.

# RELAX NG Schema for BEACON XML

Below is a schema of [BEACON XML format](#beacon-xml-format) in RELAX NG Compact
syntax [](#RELAX-NGC). The schema is non-normative and given for reference
only.

    default namespace = "http://purl.org/net/beacon"

    element beacon {
      attribute prefix      { text }.
      attribute target      { text },
      attribute message     { text },
      attribute source      { xsd:anyURI },
      attribute name        { text },
      attribute institution { text },
      attribute description { text },
      attribute creator     { text },
      attribute contact     { text },
      attribute homepage    { xsd:anyURI },
      attribute feed        { xsd:anyURI },
      attribute timestamp   { text },
      attribute update { "always" | "hourly" | "daily" 
        | "weekly" | "monthly" | "yearly" | "never" },
      attribute relation    { xsd:anyURI },
      attribute annotation  { xsd:anyURI },
      element link {
        attribute source     { text },
        attribute target     { text }?,
        attribute annotation { text }?,
        empty
      }*
    }

# Example

A short example of a BEACON XML file is given below:

    <?xml version="1.0" encoding="UTF-8"?>
    <beacon xmlns="http://purl.org/net/beacon" 
            prefix="http://example.org/"
            target="http://example.com/"
            name="ACME document">
       <link source="alice" target="foo" />
       <link source="bob" />
       <link source="ada" annotation="bar" />
    </beacon>

The link dump could also be expressed in BEACON text format:

    #PREFIX: http://example.org/
    #TARGET: http://example.com/
    #NAME:   ACME document

    alice||foo
    bob
    ada|bar

The link dump mapped to RDF:

    @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
    @prefix void: <http://rdfs.org/ns/void#> .

    :sourceset a void:Dataset ;
        void:uriSpace "http://example.org/" .

    :targetset a void:Dataset ;
	    void:uriSpace "http://example.com/" .

    :dump a void:Linkset ;
        void:subjectsTarget :sourceset ;
        void:objectsTarget :targetset ;
        void:linkPredicate rdfs:seeAlso .

    <http://example.org/alice> 
      rdfs:seeAlso <http://example.com/foo> . 
    <http://example.org/bob> 
      rdfs:seeAlso <http://example.com/bob> . 
    <http://example.org/ada> 
      rdfs:seeAlso <http://example.com/ada> . 
    <http://example.com/ada> 
      rdfs:value "bar" .

