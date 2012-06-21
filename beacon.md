% BEACON link dump format
% Jakob Voß

# Introduction

## Overview

BEACON is a data interchange format for large numbers of uniform links.  A
BEACON link dump consists of:

* a set of [links](#links), each consisting of four elements ([](#links)),
* a set of [meta fields](#meta-fields).

All links typically share a common URI pattern for source and for target,
respectively. For instance a BEACON dump could consist of links between two
domains that use different local identifier systems:

    http://example.org/{ID1} ---> http://example.com/{ID2}

A special case is the use of the same local identifier that can be used to
construct both, source and target of a link, for instance:

    http://example.org/{ID}  ---> http://example.com/{ID}.html

A BEACON link dump can be serialized in a condense [BEACON text
format](#beacon-text-format) and in [BEACON XML format](#beacon-xml-format).
The link dump can further be serialized in RDF, if the relation type of its
links is an URI.

## Notational Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be
interpreted as described in [](#RFC2119).

The formal grammar rules in this document are to be interpreted as described in
[](#RFC5234), including the following core ABNF syntax rules:

     ALPHA       =  %x41-5A / %x61-7A   ; A-Z / a-z
	 DIGIT       =  %x30-39             ; 0-9
	 HEXDIG      =  DIGIT / "A" / "B" / "C" / "D" / "E" / "F"
     HTAB        =  %x09                ; horizontal tab
     LF          =  %x0A                ; linefeed
     CR          =  %x0D                ; carriage return
     SP          =  %x20                ; space

The `SCHEME` rule is copied from [](#RFC3986):

     SCHEME      =  ALPHA *( ALPHA / DIGIT / "+" / "-" / "." )

In addition, the operator `-` is used to express exceptions to forbid line
breaks and vertical bars in the following rules: 

     BEACONLINE  =  *( CHAR - LINEBREAK )

     BEACONVALUE =  *( CHAR - ( LINEBREAK / VBAR ) )

     LINEBREAK   =  LF | CR LF | CR

     VBAR        =  %x7C          ; vertical bar ("|")


## String normalization 

A Unicode string is normalized according to this specification, by stripping
leading and trailing whitespace and by replacing all `WHITESPACE` character
sequences by a single space (`SP`).

     WHITESPACE  =  1*( CR | LF | HTAB | SP )

The set of allowed Unicode characters in BEACON is the set of valid Unicode
characters from UCS which can also be expressed in XML 1.0, excluding some
discouraged control characters:

	 CHAR        =  WHITESPACE / %x21-7E / %xA0-D7FF / %xE000-FFFD
	             /  %x10000-1FFFD / %x20000-2FFFD / %x30000-3FFFD
	             /  %x40000-4FFFD / %x50000-5FFFD / %x60000-6FFFD
	             /  %x70000-7FFFD / %x80000-8FFFD / %x90000-9FFFD
	             /  %xA0000-AFFFD / %xB0000-BFFFD / %xC0000-CFFFD
	             /  %xD0000-DFFFD / %xE0000-EFFFD / %xF0000-FFFFD
	             /  %x10000-10FFFD

An application MAY allow additional characters or disallow additional
characters by stripping them or by replacing them with the replacement
character `U+FFFD`.

Applications SHOULD further apply Unicode Normalization Form Canonical
Composition (NFKC) to all strings.

## URI patterns

A URI pattern in this specification is an URI Template, as defined in
[](#RFC6570), with all template expressions being either `{ID}` for simple
string expansion or `{+ID}` for reserved expansion. If no template expression
is given, the pattern MUST be processed as if the expression `{ID}` was
appended. For this reason the following URI patterns are equal:

     http://example.org/
	 http://example.org/{ID}

A URI pattern is used to construct a URI by replacing all template expressions
with an identifier value. All identifier characters in the `unreserved` range
from [](#RFC3986), and characters in the `reserved` range or character
sequences matching the `pct-encoded` rule for expressions being `{+ID}`, are
copied literally.  All other characters are copied the URI as the sequence of
pct-encoded triplets corresponding to that character's encoding in UTF-8
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
	  Müller            {ID}        M%C3%BCller
	  Müller            {+ID}       M%C3%BCller
      M%C3%BCller       {ID}        M%25C3%25BCller
      M%C3%BCller       {+ID}       M%C3%BCller

## Mappings to RDF

RDF snippets in this document are given in Turtle syntax [](#TURTLE) with the
following namespace prefixes:

	@prefix foaf: <http://xmlns.com/foaf/0.1/> .
    @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
    @prefix dcterms:  <http://purl.org/dc/terms/extent> .

The base URI `<>` is used in examples to denote the URI of a Beacon dump.

# Links

A link in BEACON is a typed connection between two resources that are
identified by URIs [](#RFC3986). A link is compromised of four elements:

* a source URI,
* a target URI,
* a relation type, 
* a qualifier.

A BEACON link dump is an annotated set of links with identical relation type.
A relation type is either a registered link type from the IANA link relations
registry  [](#RFC5988) or an URI. Some examples of relation types:

	 alternate
	 describedby
	 replies
     http://www.w3.org/2002/07/owl#sameAs
	 http://xmlns.com/foaf/0.1/isPrimaryTopicOf
	 http://purl.org/spar/cito/cites

In a [serialized BEACON dump](#serialization) the relation type is specified by
the link [meta field](#meta-fields). The other elements of a link are
constructed from [link fields](#link-fields-and-construction) and meta fields
given in a serialization. 

A qualifier is an optional Unciode that can be used to further describe the
link or parts of it. Its value is the empty string by default.

     QUALIFIER      =  *( CHAR - LINEBREAK )

The meaning of a link and its elements is not defined by this specification,
but guidelines are given in [](#interpreting-beacon-links).

# Meta fields

A BEACON dump SHOULD contain a set of meta fields, each field identified by its
name. Meta field names are build of lowercase letters `a-z`. In [BEACON text
format](#beacon-text-format), meta field names are case insensitive and SHOULD
be given in uppercase letters.  Valid meta fields are defined in the following.
Additional meta fields, not defined in this specification SHOULD be ignored.
All meta field values MUST be normalized Unicode strings
[](#string-normalization). Missing meta fields and meta fields with the empty
string as normalized field value MUST be set to their default value, which is
the empty string unless noted otherwise.

## Fields for link construction

The meta fields `prefix`, `target`, `link`, and `message` are only used to
abbreviate link elements in BEACON serializations.  Applications MUST ignore
these fields after they have been used to construct a full BEACON dump from a
serialized BEACON file. For instance the following BEACON text serialization
contains a single link:

     #PREFIX: http://example.org/
     #TARGET: http://example.com/
     #MESSAGE: Hello World!

     foo

The same link could be serialized as following, without any meta fields: 

     http://example.org/foo|Hello World!|http://example.com/foo

The default meta fields values of this examples could also be specified as:

     #PREFIX: {+ID}
     #TARGET: {+ID}
     #MESSAGE: {about}

Another possible serialization would be:

     #PREFIX: http://example.org/
     #TARGET: http://example.com/
     #MESSAGE: Hello {about}

     foo|World!

The link line in this example is equal to:

     foo|World!|foo

Applications SHOULD ignore equal links in one Beacon dump and it is RECOMMENDED
to indicate duplicated links with a warning.

### prefix

The prefix field specifies an URI pattern that is used to construct link
sources.  If no prefix meta field was specified, the default value `{+ID}` is
used.  The name `prefix` was choosen to keep backwards compatibility with
existing BEACON dumps.

### target

The target field specifies an URI pattern to construct link targets.  If no
target meta field was specified, the default value `{+ID}` is used.

### link

The link field specifies the relation type for all links in a BEACON dump.
The default relation type is `http://www.w3.org/2000/01/rdf-schema#seeAlso`.

### message

The message meta field is used as template for link qualifiers. The default
value is `{about}`. Note that all link qualifiers are equal, if the field value
does not contain the sequence `{about}`.

## Annotating meta fields

The meta fields `name`, `description`, `institution`, `creator`, `contact`,
`qualifier`, `reference`, `feed`, `timestamp`, and `update` describe a BEACON
dump.  The meaning of these fields is defined by RDF properties from the DCMI
Metadata Terms [](#DCTERMS) and other vocabularies.  A mapping of annotating
meta fields to RDF properties is given in [](#interpreting-beacon-links).

### name

The name meta field contains a name or title of the BEACON dump and/or of
all of its targets. For instance if all links point to resources in a database,
the name meta field contains the name of the database.

The RDF property of this field is `http://purl.org/dc/terms/title` from
the DCMI Metadata Terms.

### description

The description meta field contains a human readable description of the BEACON
dump.

The RDF property of this field is `http://purl.org/dc/terms/description` from
the DCMI Metadata Terms.

### creator

The creator meta field contains the URI or the name of the person,
organization, or a service primarily responsible for making the BEACON dump.
This field corresponds to the `creator` from the DCMI Metadata Terms. The
creator is an instace of the `Agent` class from the FOAF vocabulary.

The following examples of meta field values:

    Bea Beacon

    http://example.org/people/bea

can be mapped to:

    <> dcterms:creator "Bea Beacon" .
    <> dcterms:creator [ a foaf:Agent ; foaf:name "Bea Beacon" ] .
    
	<> dcterms:creator <http://example.org/people/bea> .
	<http://example.org/people/bea> a foaf:Agent .


This field SHOULD NOT contain a simple URL unless this URL is also used as URI.

### contact

The contact meta field contains an email address or similar contact information
to reach the creator of the BEACON dump.  The contact MUST be a mailbox address
as specified in section 3.4 of [](#RFC5322), for instance:

     admin@example.com
	
	 Bea Beacon <bea@example.org>

The contact meta field corresponds to the `mbox` property and the `name`
property from the FOAF vocabulary [@FOAF]. The domain of the the contact meta
field is the Beacon dump. The sample field values can be mapped to:

     <> dcterms:creator [
	     foaf:mbox <mailto:admin@example.com>
     ] .

     <> dcterms:creator [
	     foaf:name "Bea Beacon" ;
	     foaf:mbox <mailto:bea@example.org>
     ] .

### institution

The institution meta field contains the organization or individual of an
institution or publisher responsible for the target database.  The field value
can be an URI or a literal name. The 

The RDF property of this field is `http://purl.org/dc/terms/publisher` or
`http://purl.org/dc/terms/creator` (???) from the DCMI Metadata Terms.


### reference

The reference field contains an URL of a website with additional information
about this BEACON link dump.

The RDF property of this field is `http://xmlns.com/foaf/0.1/homepage` from 
the FOAF vocabulary.

### feed

The feed field contains an URL, where to download the BEACON dump from. In
addition to standard URL schemes, alternative established URI forms for
retrieval, such as magnet URIs MAY be allowed.

The RDF property of this field is `http://rdfs.org/ns/void#dataDump` from the
VoID vocabulary.

### timestamp

The timestamp field contains the date of last modification of the BEACON dump.
This date MUST conform to the `full-date` or to the `date-time` production rule
in [](#RFC3339). In addition, an uppercase `T` character MUST be used to
separate date and time, and an uppercase `Z` character MUST be present in the
absence of a numeric time zone offset. Some examples of valid timestamp values:

     2012-05-30
     2012-05-30T15:17:36+02:00
     2012-05-30T13:17:36Z

The RDF property of this field is `http://purl.org/dc/terms/modified` from the
DCMI Metadata Terms.

### update

The update field specifies how frequently the BEACON dump is likely to change.
The field corresponds to the `<changefreq>` element in [Sitemaps XML
format](#Sitemaps). Valid values are:

* `always`
* `hourly`
* `daily`
* `weekly`
* `monthly`
* `yearly`
* `never` 

The value `always` SHOULD be used to describe BEACON dumps that change each
time they are accessed. The value `never` SHOULD be used to describe archived
BEACON dumps. Please note that the value of this tag is considered a hint and
not a command. 

The RDF property of this field is 
`http://web.resource.org/rss/1.0/modules/syndication/updatePeriod` from
the RSS 1.0 Syndication Module [](#RSSSYND).

### qualifier

The optional qualifier field specifies the relation type of relations between
link target and link qualifier.

# Link fields and construction

Each link in a serialized BEACON dump is given in form of up to four fields:

* source field,
* optional qualifier field,
* optional target field.

From these fields, combined with the BEACON dump's [meta fields](#meta-fields),
the full [link](#links) is constructed. All field values MUST be
[normalized](#string-normalization) before further processing. Missing
optional fields MUST be set to the empty string.  The full link is then
constructed as following:

The **link source** is constructed from the [prefix meta field](#prefix) URI
pattern by inserting the source field as identifier value, as defined in
[](#uri-patterns).

The **link target** is constructed from the [target meta field](#target) URI
pattern by inserting as identifier value, as defined in [](#uri-patterns):

* the target field, if the target field is not the empty string,
* the source field, otherwise.

Constructed link sources and link targets MUST be a syntactically valid URIs. A
client MUST ignore links with invalid URIs and it SHOULD give a warning.

The **link qualifier** is constructed from the qualifier field and the [message
meta field](#message) as following. The message field value is used as string
pattern in which the character sequences `{about}` is literally replace by the
qualifier field. A warning SHOULD be given if the message meta field does not
contain this sequence and the qualifier field is not the empty string, because
the qualifier field is ignored in this case.

Additional encoding MUST NOT be applied to field values during this process.
The resulting string MUST be [normalized](#string-normalization) after
construction.

The following table illustrates construction of a link:

    meta field    link field(s)   -->  link element
     prefix        source         -->   source
     target        source,target  -->   target
	 message       qualifier      -->   qualifier
	 link          -              -->   relation type

# Serialization

## BEACON text format

A BEACON text file is an UTF-8 encoded Unicode file [](#RFC3629), split into
lines by line breaks. The file consists of a set of lines with meta fields,
followed by a set of lines with link fields. A BEACON text file MAY begin with
an Unicode Byte Order Mark and it SHOULD end with a line break:

     BEACONTEXT  =  [ BOM ] [ START ] *METALINE *EMPTY [ LINKS ]
	
     BOM         =  %xEF.BB.BF     ; Unicode UTF-8 Byte Order Mark

At least one empty line SHOULD be used to separate meta lines and link lines.
The order public of meta lines and the order of link lines is irrelevant. 

	EMPTY        =  *( *WHITESPACE LINEBREAK )

The BEACON text file SHOULD start with an additional, fixed meta field:

     START       =  "#FORMAT: BEACON" LINEBREAK

A meta line specifies a [meta field](#meta-fields) and its value. Meta field
names are case insensitive and SHOULD be given in uppercase letters.

     METALINE    =  "#" METAFIELD ":" METAVALUE LINEBREAK

     METAFIELD   =  "PREFIX" / "TARGET" / "LINK" / "MESSAGE" 
                 /  "NAME" / "DESCRIPTION" / "INSTITUTION" 
                 /  "QUALIFIER" / "REFERENCE"
                 /  "CONTACT" / "FEED" / "TIMESTAMP" / "UPDATE"
 
     METAVALUE   =  BEACONLINE

Each link is given on a link line with its source field, optionally follwed by
additional fields:

     LINKS       =  LINK *( LINEBREAK LINK ) [ LINEBREAK ]

     LINK        =  SOURCE [ VBAR QUALIFIER [ VBAR TARGET ] ] 

     SOURCE      =  BEACONVALUE

     TARGET      =  BEACONVALUE

## BEACON XML format

A BEACON XML file is a valid XML file conforming to the following schema. The
file SHOULD be encoded in UTF-8 [](#RFC3629). The file MUST:

  * Begin with an opening `<beacon>` tag and end with a closing `</beacon>` tag.
  * Specify the default namespace `http://purl.org/net/example`.
  * Include an empty `<link/>` tag for each link.
  * Include the [source field](#link-fields-and-construction) as XML attribute
    `id` of each `<link/>` element.

The file MAY further:

  * Specify [meta fields](#meta-fields) as XML attributes to the `<beacon>` tag.
  * Specify link fields `target` and/or `about` as attributes to the `<link>` 
    element.

All attributes MUST be given in lowercase. An informal schema of BEACON XML is
given in [](#relax-ng-schema-for-beacon-xml).

To process BEACON XML, a complete and stream-processing XML parser, for
instance the Simple API for XML [](#SAX), is RECOMMENDED, in favor of
parsing with regular expressions or similar methods prone to errors.
Additional XML attributes of `<link>` elements and `<link>` elements without
`id` attribute SHOULD be ignored.

Note that in contrast to BEACON text format, link fields MAY include line
breaks, which are removed by whitespace normalization. Furthermore id field,
qualifier field and target field MAY include a vertical bar, which is encoded as
`%7C` during construction the link.


# Security Considerations

...TODO... 

(URLs MAY be used to inject code and qualifiers MAY be used to inject HTML?)

