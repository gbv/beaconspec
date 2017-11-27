# Glossary

BEACON
  : a data interchange format as specified in this document.

BEACON file
  : a link dump serialized in BEACON format.

BEACON format
  : a condense format to serialize link dumps as specified in this document. 

link
  : a source identifier, target identifier, relation type, and (optional) link
    annotation. Given in form of link tokens in BEACON format to construct links
    from.

link annotation
  : an additional description of a link given as non-empty Unicode string. 

link dump
  : a set of links and meta fields.

link token
  : a Unicode string in BEACON format used to construct a link.

meta field
  : a property to describe a link dump, a source database, a target database, or
    how to construct links from BEACON format.

source identifier
  : identifier where a link points from.

target identifier
  : identifier where a link points to.

source database
  : the set (or superset) of all source URIs in a link dump.

target database
  : the set (or superset) of all target URIs in a link dump.

relation type
  : the type of connection between target identifier and source identifier.

# Mapping BEACON to HTML

An important use-case of BEACON is the creation of HTML links to related
documents.  A link in a BEACON dump can be mapped to a HTML link (`<a>`
element) as following:

* link source corresponds to the website which a HTML link is included at,
* link target corresponds to the `href` attribute,
* link annotation corresponds to the textual content,

For instance the following link, given in a BEACON file:

     http://example.com|example|http://example.org

can be mapped to the following HTML link:

     <a href="http://example.org">example</a>

Note that the link annotation is optional. Additional meta fields can be used
to construct appropriate HTML links.  For instance the meta fields

     #RELATION: http://xmlns.com/foaf/0.1/isPrimaryTopicOf
     #SOURCETYPE: http://xmlns.com/foaf/0.1/Person 
     #NAME: ACME documents

can be used to create a link such as

     <span>
       More information about this person
       <a href="http://example.com/foo">at ACME documents</a>.
     </span>  

because `http://xmlns.com/foaf/0.1/isPrimaryTopicOf` translates to "more
information about", `http://xmlns.com/foaf/0.1/Person` translates to "this
person", and the target dataset’s name "ACME documents" can be used as link
label.

# BEACON XML format

A BEACON XML file is a valid XML file conforming to the following schema. The
file SHOULD be encoded in UTF-8 [](#RFC3629). The file MUST:

  * Begin with an opening `<beacon>` tag and end with a closing `</beacon>` tag.
  * Specify the default namespace `http://purl.org/net/beacon`.
  * Include an empty `<link/>` tag for each link.
  * Include the source token as XML attribute `source` of each `<link/>` element.

The file MAY further:

  * Specify [meta fields](#meta-fields) as XML attributes to the `<beacon>` tag.
  * Specify link tokens `target` and/or `annotation` as attributes to the 
    `<link>` element.

All attributes MUST be given in lowercase. 

To process BEACON XML files, a complete and stream-processing XML parser, for
instance the Simple API for XML [](#SAX), is RECOMMENDED, in favor of parsing
with regular expressions or similar methods prone to errors.  Additional XML
attributes of `<link>` elements and `<link>` elements without `source`
attribute SHOULD be ignored.

Note that in contrast to BEACON text files, link tokens MAY include line
breaks, which MUST BE removed by whitespace normalization. Furthermore id field,
annotation field and target token MAY include a vertical bar, which MUST be replaced
by the character sequence `%7C` before further processing.

A schema of BEACON XML format in RELAX NG Compact syntax [](#RELAX-NGC) can be
given as following:

    default namespace = "http://purl.org/net/beacon"

    element beacon {
      attribute prefix      { text }.
      attribute target      { text },
      attribute message     { text },
      attribute source      { text },
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

# Mapping example

A short example of a link dump serialized in BEACON text format:

    #FORMAT: BEACON
    #PREFIX: http://example.org/
    #TARGET: http://example.com/
    #NAME:   ACME document

    alice||foo
    bob
    ada|bar

The link dump can be mapped to RDF as following:

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

The same link dump serialized in BEACON XML format:

    <?xml version="1.0" encoding="UTF-8"?>
    <beacon xmlns="http://purl.org/net/beacon" 
            prefix="http://example.org/"
            target="http://example.com/"
            name="ACME document">
       <link source="alice" target="foo" />
       <link source="bob" />
       <link source="ada" annotation="bar" />
    </beacon>

# Extended example

To give an extended example, the "ACME" company wants to provide links from
people to documents that each person contributed to (a "contributor"
relationship in terms of Dublin Core). A list of all people is available from
`http://example.com/people/` and a list of all documents, titled "ACME
documents", is available from `http://example.com/documents/`. This information
can be expressed in a serialized link dump with BEACON meta fields as
following:

    #FORMAT: BEACON
    #INSTITUTION: ACME
    #RELATION: http://purl.org/dc/elements/1.1/contributor
    #SOURCESET: http://example.com/people/
    #TARGETSET: http://example.com/documents/
    #NAME: ACME documents

Both source identifiers for people and target identifiers for documents follow
a pattern, so links can be abbreviated as following:

    #PREFIX: http://example.com/people/
    #TARGET: http://example.com/documents/{+ID}.about

    alice||23
    bob||42

From this form the following links can be constructed:

    http://example.com/people/alice|http://example.com/documents/23.about
    http://example.com/people/bob|http://example.com/documents/42.about

The example can be extended by addition of a third element for each link. For
instance the annotation could be used to specifcy the date of each document:

    #ANNOTATION: http://purl.org/dc/elements/1.1/date

    alice|2014-03-12|23
    bob|2013-10-21|42

