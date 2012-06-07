# Interpreting BEACON links

The interpretation of links in a BEACON dump is not restricted to a specific
format. The most common use cases are HTML links and RDF triples.

## HTML links

A BEACON link can be mapped to a HTML link (`<a>` element) as following:

* link source corresponds to the website which a HTML link is included at,
* link target corresponds to the `href` attribute,
* link qualifier corresponds to the textual content,

For instance the following link, given in BEACON text format:

    http://example.com|example|http://example.org

can be mapped to the following HTML link:

    <a href="http://example.org">example</a>

## RDF triples

If link type is an URI, each link in a BEACON dump SHOULD be mapped to an RDF
triple with: 

* link source as RDF subject,
* link type as RDF property,
* link target as RDF object.

As RDF is defined on URI references or IRIs, link source and link target URI
must be transformed to an IRI by following the process defined in Section 3.2 
of [](#RFC3987).

In addition, the link qualifier MAY result in an additional triple with a
literal value as RDF object. For instance the following link, in BEACON text:

    #QUALIFIER: http://www.w3.org/2000/01/rdf-schema#label
    http://example.org|example|http://example.com

could be mapped to the following RDF triples in Turtle format:

    @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
	
	<http://example.org> rdfs:seeAlso <http://example.com> .
    <http://example.com> rdfs:label "example" .

A typical use case is to use qualifiers as "number of hits" at a target
resource. For instance:

    #PREFIX: http://example.org/
    #TARGET: http://example.com/ 
	#LINK: http://xmlns.com/foaf/0.1/primaryTopic
    #QUALIFIER: http://purl.org/dc/terms/extent

    abc|12

could be mapped to the following RDF triples in Turtle format:

	@prefix foaf: <http://xmlns.com/foaf/0.1/> .
    @prefix dct:  <http://purl.org/dc/terms/extent> .

    <http://example.org/abc> foaf:primaryTopic <http://example.com/abc> .
    <http://example.com/abc> dct:extent "12" .

Another possible interpretation of link qualifier is additional information
about the relationship, for instance when it was created (reification).

# RELAX NG Schema for BEACON XML

Below is a schema of [BEACON XML](#beacon-xml-format) in RELAX NG Compact
syntax [](#RELAX-NGC). The schema is non-normative and given for reference
only.

    default namespace = "http://purl.org/net/beacon"

	element beacon {
	  attribute prefix      { text }.
	  attribute target      { text },
	  attribute link        { xsd:anyURI },
	  attribute qualifier   { xsd:anyURI },

	  attribute message     { text },
	  attribute description { text },
	  attribute institution { text },
	  attribute name        { text },
	  attribute reference   { xsd:anyURI },

	  attribute contact     { text },
	  attribute feed        { xsd:anyURI },
	  attribute timestamp   { text },
	  attribute update { "always" | "hourly" | "daily" 
	    | "weekly" | "monthly" | "yearly" | "never" },
	  element link {
	    attribute id        { text },
		attribute target    { text }?,
		attribute about     { text }?,
	    empty
	  }*
	}

A short example of a file in BEACON XML format is given below:

    <?xml version="1.0" encoding="UTF-8"?>
    <beacon xmlns="http://purl.org/net/beacon">
       ...TODO...
    </beacon>
