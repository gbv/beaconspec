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
  : is a Unicode string in a Beacon files used to construct a link
target database
  : is the set (or superset) of all target URIs in a link dump.
relation type
  : ...

<!--
# Interpreting Beacon links

The interpretation of links in a link dump is not restricted to a specific
format. The most common use cases are RDF triples and links in HTML.

## Examples

For instance the following link, in a Beacon text file:

    #ANNOTATION: http://www.w3.org/2000/01/rdf-schema#label

    http://example.org|example|http://example.com

could be mapped to the following RDF triples:

	<http://example.org> rdfs:seeAlso <http://example.com> .
    <http://example.com> rdfs:label "example" .

-->

# HTML links

A link in a Beacon dump can be mapped to a HTML link (`<a>` element) as
following:

* link source corresponds to the website which a HTML link is included at,
* link target corresponds to the `href` attribute,
* link annotation corresponds to the textual content,

For instance the following link, given in a Beacon text file:

     http://example.com|example|http://example.org

can be mapped to the following HTML link:

     <a href="http://example.org">example</a>

The annotation, however, may be the empty string. The meta field `name` may be
used alternatively as textual content. The relation type may also be used to
automatically create an appropriate link label, such as "same entity" 
for relation type `http://www.w3.org/2002/07/owl#sameAs` or "more information
about this" for relation type `foaf:isPrimaryTopicOf`.


# RELAX NG Schema for Beacon XML

Below is a schema of [Beacon XML format](#beacon-xml-format) in RELAX NG Compact
syntax [](#RELAX-NGC). The schema is non-normative and given for reference
only.

    default namespace = "http://purl.org/net/beacon"

	element beacon {
	  attribute prefix      { text }.
	  attribute target      { text },
	  attribute link        { xsd:anyURI },
	  attribute message     { text },
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
	  attribute annotation  { xsd:anyURI },
	  attribute sourcetype  { xsd:anyURI },
	  attribute targettype  { xsd:anyURI },
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
            target="http://example.org/"
			name="ACME document">
       <link id="foo" target="bar" />
       ...TODO: better example...
    </beacon>
