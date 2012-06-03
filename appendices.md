# Interpreting BEACON links

The interpretation of links in a BEACON dump is not restricted to a specific
format. The most common use cases are HTML links and RDF triples.

## HTML links

A BEACON link can be mapped to a HTML link (`<a>` element) as following:

* link source corresponds to the website which a HTML link is included at,
* link target corresponds to the `href` attribute,
* link label corresponds to the textual content,
* link description corresponds to the `title` attribute.

For instance the following link, given in BEACON text format:

    http://example.com|example|sample site|http://example.org

can be mapped to the following HTML link:

    <a href="http://example.org" title="sample site">example</a>

## RDF triples

If link type is an URI, each link in a BEACON dump can be mapped to an RDF
triple with: 

* link source as RDF subject,
* link type as RDF property,
* link target as RDF object.

Link label and link description may result in additional triples with each of
name and description as literal value RDF object. The final intepretation of
these link annotations, however, is out of the scope of this specification 
(see https://github.com/gbv/beaconspec/issues/2 for open discussion).

For instance the following link, given in BEACON text format

    http://example.com|example|sample site|http://example.org

can be mapped to the following RDF triples in Turtle format:

    @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
	@prefix dc: <http://purl.org/dc/elements/1.1/> .
	
	<http://example.com> rdfs:seeAlso <http://example.org> .

	# additional link annotations, to be discussed
    <http://example.org> rdfs:label "example" ;
	                     dc:description "sample site" .

## Resource discovery from authority files

Consider an authority file with entities defined by an example.org institution,
and an example.com institution which provides resources about these entities.
One can express for instance in BEACON text format:

    #PREFIX: http://example.org/entity/
    #TARGET: http://example.com/about/{ID}
	#LINK: http://xmlns.com/foaf/0.1/primaryTopic

    foo

to state that the resource `http://example.com/about/foo` is about the entity
`http://example.org/entity/foo`. If the institutions do not share local
identifiers, but for instance `http://example.com/about/xy` is about
`http://example.org/entity/foo`, one can express the link in BEACON text
format and in BEACON XML format this way:

    foo|||xy

	<link target="xy">foo</link>


# RELAX NG Schema for BEACON XML

Below is a schema of [BEACON XML](#beacon-xml-format) in RELAX NG Compact
syntax [](#RELAX-NGC). The schema is non-normative and given for reference
only.

    default namespace = "http://purl.org/net/beacon"

	element beacon {
	  attribute prefix      { text }.
	  attribute target      { text },
	  attribute link        { xsd:anyURI },
	  attribute contact     { text },
	  attribute message     { text },
	  attribute description { text },
	  attribute institution { text },
	  attribute name        { text },
	  attribute feed        { xsd:anyURI },
	  attribute timestamp   { text },
	  attribute update { "always" | "hourly" | "daily" 
	    | "weekly" | "monthly" | "yearly" | "never" },
	  element link {
	    attribute id          { text },
		attribute target      { text }?,
		attribute label       { text }?,
		attribute description { text }?,
	    empty
	  }*
	}

