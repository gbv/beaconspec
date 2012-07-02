% Beacon link dump format
% Jakob Voß

# Introduction

Beacon is a data interchange format for large numbers of uniform links.  A
Beacon link dump consists of:

* a set of links, each a triple of source URI, target URI, and 
  annotation ([](#links)),
* a set of meta fields ([](#meta-fields)).

All links in a link dump typically share a common URI pattern for sources and a
common URI pattern for targets ([](#uri-patterns)).  This patterns are used to
abbreviate URIs in serializations of link dumps as Beacon files
([](#beacon-files)).  A Beacon file is either given in line-oriented, condense
Beacon text format ([](#beacon-text-format)) or in Beacon XML format
([](#beacon-xml-format)). 

The set or a superset of all target URIs in a link dump is called its target
database ([](#target-database)).  

An important use-case of Beacon is the creation of HTML links as described in
section [](#mapping-to-html). A link dump can also be mapped to an RDF graph
([](#mapping-to-rdf)) so Beacon provides a RDF serialization format for a
subset of RDF graphs with uniform links. 

## Notational Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be
interpreted as described in [](#RFC2119).

The formal grammar rules in this document are to be interpreted as described in
[](#RFC5234), including the ABNF core rules `HTAB`, `LF`, `CR`, and `SP`. In
addition, the operator `-` is used to exclude line breaks and vertical bars in
the following rules:

     BEACONLINE  =  *CHAR - ( *CHAR LINEBREAK *CHAR )

     BEACONVALUE =  *CHAR - ( *CHAR ( LINEBREAK / VBAR ) *CHAR )

     LINEBREAK   =  LF | CR LF | CR   ; "\n", "\r\n", or "\r"

     VBAR        =  %x7C              ; vertical bar ("|")

RDF is expressed in Turtle syntax in this document [](#TURTLE). The
following namespace prefixes are used to refer to RDF properties and classes
from the RDF and RDFS vocabularies [](#RDF), from the DCMI Metadata Terms
[](#DCTERMS), from the FOAF vocabulary [](#FOAF), the VoID vocabulary
[](#VOID), and the RSS 1.0 Syndication Module [](#RSSSYND):

     @prefix rdf:     <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
     @prefix rdfs:    <http://www.w3.org/2000/01/rdf-schema#> .
     @prefix dcterms: <http://purl.org/dc/terms/extent> .
	 @prefix foaf:    <http://xmlns.com/foaf/0.1/> .
     @prefix void:    <http://rdfs.org/ns/void#> .
	 @prefix rssynd: 
	         <http://web.resource.org/rss/1.0/modules/syndication/> .

The blank node `:dump` is used to denote the URI of the link dump and the blank
node `:database` is used to denote the URI of the target database. The
following triples are always assumed in mappings of link dumps to RDF:

     :dump a void:Linkset .
	 :database a void:Database .

## String normalization 

A Unicode string is normalized according to this specification, by stripping
leading and trailing whitespace and by replacing all `WHITESPACE` character
sequences by a single space (`SP`). 

     WHITESPACE  =  1*( CR | LF | HTAB | SP )

The set of allowed Unicode characters in Beacon dumps is the set of valid
Unicode characters from UCS which can also be expressed in XML 1.0, excluding
some discouraged control characters:

	 CHAR        =  WHITESPACE / %x21-7E / %xA0-D7FF / %xE000-FFFD
	             /  %x10000-1FFFD / %x20000-2FFFD / %x30000-3FFFD
	             /  %x40000-4FFFD / %x50000-5FFFD / %x60000-6FFFD
	             /  %x70000-7FFFD / %x80000-8FFFD / %x90000-9FFFD
	             /  %xA0000-AFFFD / %xB0000-BFFFD / %xC0000-CFFFD
	             /  %xD0000-DFFFD / %xE0000-EFFFD / %xF0000-FFFFD
	             /  %x10000-10FFFD

Applications MAY allow additional characters or disallow additional characters
by stripping them or by replacing them with the replacement character `U+FFFD`.
Applications SHOULD further apply Unicode Normalization Form Canonical
Composition (NFKC) to all strings.

## URI patterns

A URI pattern in this specification is an URI Template, as defined in
[](#RFC6570), with all template expressions being either `{ID}` for simple
string expansion or `{+ID}` for reserved expansion. If no template expression
is given, the pattern MUST be processed as if the expression `{ID}` was
appended. For instance the following URI patterns are equal:

     http://example.org/
	 http://example.org/{ID}

A URI pattern is used to construct a URI by replacing all template expressions
with an identifier value. All identifier characters in the `unreserved` range
from [](#RFC3986), and characters in the `reserved` range or character
sequences matching the `pct-encoded` rule for expressions being `{+ID}`, are
copied literally.  All other characters are copied to the URI as the sequence
of pct-encoded triplets corresponding to that character’s encoding in UTF-8
[](#RFC3629). The referenced character ranges are imported here from
[](#RFC3986) for convenience:

     pct-encoded    =  "%" HEXDIG HEXDIG
     unreserved     =  ALPHA / DIGIT / "-" / "." / "_" / "~"
     reserved       =  gen-delims / sub-delims
     gen-delims     =  ":" / "/" / "?" / "#" / "[" / "]" / "@"
     sub-delims     =  "!" / "$" / "&" / "'" / "(" / ")"
                    /  "*" / "+" / "," / ";" / "="

A URI pattern is allowed to contain the broader set of characters allowed in
Internationalized Resource Identifiers (IRI) [](#RFC3987). The URI constructed
from a URI pattern by template processing can be transformed to an IRI by
following the process defined in Section 3.2 of [](#RFC3987).

     Example value    Expression   Copied as

      path/dir          {ID}        path%2Fdir
	  path/dir          {+ID}       path/dir
	  Hello World!      {ID}        Hello%20World%21
	  Hello World!      {+ID}       Hello%20World!
	  Hello%20World     {ID}        Hello%2520World
	  Hello%20World     {+ID}       Hello%20World
      M%C3%BCller       {ID}        M%25C3%25BCller
      M%C3%BCller       {+ID}       M%C3%BCller

# Links

A link in a link dump is a directed connection between two resources that are
identified by URIs [](#RFC3986). A link is compromised of three elements:

* a source URI,
* a target URI,
* an annotation.

Source URI and target URI define where a link is pointing from and to
respectively. The annotation is an optional whitespace-normalized Unicode
string that can be used to further describe the link or parts of it. A missing
annotation is equal to the empty string. Annotations MUST match the grammar
rule `BEACONVALUE`.

Link elements are given in abbreviated form as link fields when serialized in a
Beacon file ([](#link-fields)). With a relation type ([](#relation-types))
links can be mapped to RDF triples ([](#mapping-to-rdf)) and to HTML links
([](#mapping-to-html)).

## Link fields

Each link in a serialized link dump is constructed from a "source field", a
"target field", and an "annotation field", combined with a set of meta fields
([](#link-construction)). The source field is mandatory. The annotation field
is set to the empty string if missing. The target field is set to the source
field if missing. All field values MUST be whitespace-normalized before further
processing.  The full link is then constructed as following:

* The link source is constructed from the `prefix` meta field URI pattern by 
  inserting the source field as identifier value, as defined in 
  [](#uri-patterns).
* The link target is constructed from the `target` meta field URI pattern by 
  inserting the target field as identifier value, as defined in 
  [](#uri-patterns).
* The link annotation is constructed from the `message` meta field by literally 
  replacing every occurrence of the character sequence `{annotation}` by the 
  annotation field.  The resulting string MUST be whitespace-normalized after
  construction additional encoding MUST NOT be applied.

Constructed link sources and link targets MUST be syntactically valid URIs.
Applications MUST ignore links with invalid URIs and SHOULD give a warning.
Note that annotation fields are ignored if the `message` meta field does not
contain the sequence `{annotation}`. Applications SHOULD give a warning in this
case.

The following table illustrates construction of a link:

    meta field  +  link field    -->  link element
     prefix     +   source       -->   source
     target     +   target       -->   target
	 message    +   annotation   -->   annotation

## Relation types

All links in a link dump share a common relation type. A relation type is
either an URI or a registered link type from the IANA link relations registry
[](#RFC5988).  The relation type is specified by the `relation` meta field in
Beacon files ([](#meta-fields)).

Some examples of relation types:

     http://www.w3.org/2002/07/owl#sameAs
	 http://xmlns.com/foaf/0.1/isPrimaryTopicOf
	 http://purl.org/spar/cito/cites
	 describedby
	 replies

# Meta fields

A link dump SHOULD contain a set of meta fields, each identified by its name
build of lowercase letters `a-z`. Relevant meta fields for link construction
([](#link-construction)), description of the target database
([](#target-database)), description of the link dump ([](#link-dump)), and
interpretation of links ([](#interpretation)) are defined in the following.
Additional meta fields, not defined in this specification, SHOULD be ignored.
All meta field values MUST be whitespace-normalized
([](#string-normalization)).  Missing meta field values and empty strings MUST
be set to the field’s default value, which is the empty string unless noted
otherwise. 

## Link construction

The meta fields `prefix`, `target`, and `message` are used to abbreviate links
in form of link fields in a Beacon file, as described in [](#link-fields).
Applications SHOULD ignore these fields after they have been used to construct
a full link dump with mapping to RDF from a serialized Beacon file. In
particular, applications MUST NOT differentiate between equal links constructed
from different abbreviations.  Equal links in one Beacon file SHOULD be ignored
and it is RECOMMENDED to indicate duplicated links with a warning.

For instance the following Beacon text file contains a single link:

     #PREFIX: http://example.org/
     #TARGET: http://example.com/
     #MESSAGE: Hello World!

     foo

The same link could also be serialized without any meta fields: 

     http://example.org/foo|Hello World!|http://example.com/foo

The default meta fields values could also be specified as:

     #PREFIX: {+ID}
     #TARGET: {+ID}
     #MESSAGE: {annotation}

Another possible serialization is:

     #PREFIX: http://example.org/
     #TARGET: http://example.com/
     #MESSAGE: Hello {annotation}

     foo|World!

The link line in this example is equal to:

     foo|World!|foo

### prefix

The prefix field specifies an URI pattern that is used to construct link
sources.  If no prefix meta field was specified, the default value `{+ID}` is
used.  The name `prefix` was choosen to keep backwards compatibility with
existing Beacon files.

Applications MAY map the prefix field to the RDF property `void:uriSpace` or
`void:uriRegexPattern` with `:dump` as subject, when mapping to RDF.

### target

The target field specifies an URI pattern to construct link targets.  If no
target meta field was specified, the default value `{+ID}` is used.

Applications MAY map the target field to the RDF property `void:uriSpace` or
`void:uriRegexPattern` with `:database` as subject, when mapping to RDF.

### message

The message meta field is used as template for link annotations. The default
value is `{annotation}`.

## Target database

### name

The name meta field contains a name or title of target database. This field is
mapped to the RDF property `dcterms:title`. For instance the name meta field
value "ACME documents" can be mapped to this RDF triple:

    :database dcterms:title "ACME documents" .

### institution

The institution meta field contains the name or URI of the organization or of
an individual responsible for making available the target database. This field
is maped to the RDF property `dcterms:publisher`. For instance the institution
meta field value "ACME" can be mapped to this RDF triple:

    :database dcterms:publisher "ACME" .

## Link dump

### description

The description meta field contains a human readable description of the link
dump. This field is mapped to the `dcterms:description` RDF property.  For
instance the description meta field value "Mapping from ids to documents" can
be mapped to this RDF triple:

    :dump dcterms:description "Mapping from ids to documents" .

### creator

The creator meta field contains the URI or the name of the person,
organization, or a service primarily responsible for making the link dump.
This field is mapped to the `dcterms:creator` RDF property. The
creator is an instace of the class `foaf:Agent`.

For instance the following creator meta field values:

    Bea Beacon

    http://example.org/people/bea

can be mapped the the following RDF triples, respectively:

    :dump dcterms:creator "Bea Beacon" .
    :dump dcterms:creator [ a foaf:Agent ; foaf:name "Bea Beacon" ] .
    
	:dump dcterms:creator <http://example.org/people/bea> .
	<http://example.org/people/bea> a foaf:Agent .

This field SHOULD NOT contain a simple URL unless this URL is also used as URI.

### contact

The contact meta field contains an email address or similar contact information
to reach the creator of the link dump.  The field value SHOULD be a mailbox
address as specified in section 3.4 of [](#RFC5322), for instance:

     admin@example.com
	
	 Bea Beacon <bea@example.org>

The contact meta field is mapped to the `foaf:mbox` and to the `foaf:name` RDF
properties.  The domain of the the contact meta field is the Beacon dump. The
sample field values can be mapped to:

     :dump dcterms:creator [
	     foaf:mbox <mailto:admin@example.com>
     ] .

     :dump dcterms:creator [
	     foaf:name "Bea Beacon" ;
	     foaf:mbox <mailto:bea@example.org>
     ] .

### homepage

The homepage field contains an URL of a website with additional information
about this link dump. This field is mapped to the RDF property `foaf:homepage`.
Note that this field does not specify the homepage of the target database.

### feed

The feed field contains an URL, where to download the link dump from. This
field corresponds to the `void:dataDump` RDF property. An 
example mapped to an RDF triple:

    :dump void:dataDump <http://example.com/beacon.txt> .

### timestamp

The timestamp field contains the date of last modification of the link dump.
Note that this value MAY be different to the last modification time of a Beacon
file that serializes the link dump.  The timestamp value MUST conform to the
`full-date` or to the `date-time` production rule in [](#RFC3339). In addition,
an uppercase `T` character MUST be used to separate date and time, and an
uppercase `Z` character MUST be present in the absence of a numeric time zone
offset. This field corresponds to the `dcterms:modified` property.  

For instance the following valid timestamp values:

     2012-05-30
     2012-05-30T15:17:36+02:00
     2012-05-30T13:17:36Z

can be mapped to the following RDF triples, respectively:

     :dump dcterms:modified "2012-05-30"
     :dump dcterms:modified "2012-05-30T15:17:36+02:00"
     :dump dcterms:modified "2012-05-30T13:17:36Z"

### update

The update field specifies how frequently the link dump is likely to change.
The field corresponds to the `<changefreq>` element in [Sitemaps XML
format](#Sitemaps). Valid values are:

* `always`
* `hourly`
* `daily`
* `weekly`
* `monthly`
* `yearly`
* `never` 

The value `always` SHOULD be used to describe link dumps that change each
time they are accessed. The value `never` SHOULD be used to describe archived
link dumps. Please note that the value of this tag is considered a hint and
not a command. 

The RDF property of this field is `rssynd:updatePeriod`.

## Interpretation

The following meta fields SHOULD be used to indicate the actual meaning of
links in a link dump.

### relation

The relation field specifies the relation type for all links in a link dump.
The field value MUST be an URI.  The default relation type is `rdfs:seeAlso`.

### annotation

The annotation field specifies the RDF property between link target and link
annotation. The default value is `rdf:value` having no specific meaning
[](#RDF).

### sourcetype

The sourcetype field specifies the type of entities identified by source URIs.
The field value MUST be an URI.

### targettype

The sourcetype field specifies the type of entities identified by target URIs.
The field value MUST be an URI.

# Beacon files

## Beacon text format

A Beacon text file is an UTF-8 encoded Unicode file [](#RFC3629), split into
lines by line breaks. The file consists of a set of lines with meta fields,
followed by a set of lines with link fields. A Beacon text file MAY begin with
an Unicode Byte Order Mark and it SHOULD end with a line break:

     BEACONTEXT  =  [ BOM ] [ START ] *METALINE *EMPTY [ LINKS ]
	
     BOM         =  %xEF.BB.BF     ; Unicode UTF-8 Byte Order Mark

At least one empty line SHOULD be used to separate meta lines and link lines.
The order public of meta lines and the order of link lines is irrelevant. 

	EMPTY        =  *( *WHITESPACE LINEBREAK )

The Beacon text file SHOULD start with an additional, fixed meta field:

     START       =  "#FORMAT:" +WHITESPACE "BEACON" LINEBREAK

A meta line specifies a [meta field](#meta-fields) and its value. Meta field
names are case insensitive and SHOULD be given in uppercase letters.

     METALINE    =  "#" METAFIELD ":" METAVALUE LINEBREAK

     METAFIELD   =  "PREFIX" / "TARGET" / "RELATION" / "MESSAGE" 
                 /  "NAME" / "DESCRIPTION" / "INSTITUTION" 
                 /  "ANNOTATION" / "HOMEPAGE"
                 /  "CONTACT" / "FEED" / "TIMESTAMP" / "UPDATE"
 
     METAVALUE   =  BEACONLINE

Each link is given on a link line with its source field, optionally follwed by
additional fields:

     LINKS       =  LINK *( LINEBREAK LINK ) [ LINEBREAK ]

     LINK        =  SOURCE [ VBAR ANNOTATION [ VBAR TARGET ] ] 

     SOURCE      =  BEACONVALUE

     TARGET      =  BEACONVALUE

     ANNOTATION  =  BEACONVALUE

## Beacon XML format

A Beacon XML file is a valid XML file conforming to the following schema. The
file SHOULD be encoded in UTF-8 [](#RFC3629). The file MUST:

  * Begin with an opening `<beacon>` tag and end with a closing `</beacon>` tag.
  * Specify the default namespace `http://purl.org/net/example`.
  * Include an empty `<link/>` tag for each link.
  * Include the [source field](#link-fields) as XML attribute
    `source` of each `<link/>` element.

The file MAY further:

  * Specify [meta fields](#meta-fields) as XML attributes to the `<beacon>` tag.
  * Specify link fields `target` and/or `about` as attributes to the `<link>` 
    element.

All attributes MUST be given in lowercase. An informal schema of Beacon XML
files is given in [](#relax-ng-schema-for-beacon-xml).

To process Beacon XML files, a complete and stream-processing XML parser, for
instance the Simple API for XML [](#SAX), is RECOMMENDED, in favor of parsing
with regular expressions or similar methods prone to errors.  Additional XML
attributes of `<link>` elements and `<link>` elements without `source`
attribute SHOULD be ignored.

Note that in contrast to Beacon text files, link fields MAY include line
breaks, which are removed by whitespace normalization. Furthermore id field,
annotation field and target field MAY include a vertical bar, which is encoded
as `%7C` during construction the link.

# Mappings

## Mapping to RDF

Each link can be mapped to at least one RDF triple with:

* the source URI used as subject IRI,
* the relation type used as predicate,
* the target URI used as object IRI.

As RDF is not defined on URIs but on URI references or IRIs, all URIs MUST be
transformed to an IRI by following the process defined in Section 3.2 of
[](#RFC3987). Applications MAY reject mapping link dumps with relation type
from the IANA link relations registry, in lack of official URIs. Another
valid solution is to extend the RDF model by using blank nodes as predicates.

The annotation SHOULD result in an additional RDF triple, unless its
value equals to the empty string. The additional triple is mapped with: 

* the target URI used as subject IRI,
* the `annotation` meta field used as predicate,
* the annotation value used as literal object.

Applications MAY ignore annotations and map annotations to different kinds of
RDF triples if the `annotation` meta field is the default value `rdf:value`.
For instance an annotation could contain additional information about a link
such as its provenience, date, or probability (reification).

Typical use cases of annotations include specification of labels and a "number
of hits" at the target database. For instance the following Beacon file in
Beacon text format ([](#beacon-text-format)):

     #PREFIX: http://example.org/
     #TARGET: http://example.com/ 
	 #RELATION: http://xmlns.com/foaf/0.1/primaryTopic
     #ANNOTATION: http://purl.org/dc/terms/extent

     abc|12|xy

is mapped to the following RDF triples:

     <http://example.org/abc> foaf:primaryTopic <http://example.com/xy> .
     <http://example.com/xy> dcterms:extent "12" .

If the sourcetype and/or targettype meta field is specified, another triple
can be created for each link with:

* source URI (or target URI respectively) as subject IRI
* the predicate `rdf:type`
* sourcetype (or targettype respectively) as object URI

For instance the following link dump:

     #RELATION:   http://xmlns.com/foaf/0.1/isPrimaryTopicOf
     #SOURCETYPE: http://xmlns.com/foaf/0.1/Person 
	 #TARGETTYPE: http://xmlns.com/foaf/0.1/Document 
     
     http://example.org/foo||http://example.com/bar

can be mapped to three RDF triples:

     <http://example.org/foo> a foaf:Person ;
         foaf:isPrimaryTopicOf <http://example.com/bar> .
     <http://example.com/bar> a foaf:Document .

## Mapping to HTML

This document does not specify a single mapping of links in a Beacon link dump
to links in a HTML document, so the following description is non-normative.

A link in a Beacon dump can be mapped to a HTML link (`<a>` element) as
following:

* link source corresponds to the website which a HTML link is included at,
* link target corresponds to the `href` attribute,
* link annotation corresponds to the textual content,

For instance the following link, given in a Beacon text file:

     http://example.com|example|http://example.org

can be mapped to the following HTML link:

     <a href="http://example.org">example</a>

Note that the annotation field value may be the empty string. In practice,
additional meta fields SHOULD be used to construct appropriate HTML links.
For instance the meta fields

     #RELATION: http://xmlns.com/foaf/0.1/isPrimaryTopicOf
     #SOURCETYPE: http://xmlns.com/foaf/0.1/Person 
     #NAME: ACME documents

can be used to create a link such as

     <span>
	   More information about this person
       <a href="http://example.com/foo">at ACME documents</a>.
	 </span>  

because `foaf:isPrimaryTopicOf` translates to "more information about",
`foaf:Person` translates to "this person", and the target database’s name can
be used as link label.

# Security Considerations

...TODO... 

(URLs MAY be used to inject code and annotations MAY be used to inject HTML?)

