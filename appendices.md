# Glossary

Beacon
  : is a data interchange format as specified in this document.
Beacon file
  : is a link dump serialized in Beacon text format or Beacon XML format.
Beacon text format
  : is a condense format to serialize link dumps as specified in this document. 
Beacon XML format
  : is an XML format to serialize link dumps as specified in this document. 
link
  : is a triple of source URI, target URI, and annotation.
link dump
  : is a set of links and meta fields with common relation type for all links.
link field
  : is a Unicode string in a Beacon files used to construct a link.
source database
  : is the set (or superset) of all source URIs in a link dump.
target database
  : is the set (or superset) of all target URIs in a link dump.
relation type
  : a common releation between targets and sources in a link dump.

# RELAX NG Schema for Beacon XML

Below is a schema of [Beacon XML format](#beacon-xml-format) in RELAX NG Compact
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

A short example of a Beacon XML file is given below:

    <?xml version="1.0" encoding="UTF-8"?>
    <beacon xmlns="http://purl.org/net/beacon" 
            prefix="http://example.org/"
            target="http://example.com/"
			name="ACME document">
       <link source="foo" target="bar" />
       <link source="foo" />
       <link source="doz" annotation="baz" />
    </beacon>

