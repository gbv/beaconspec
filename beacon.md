% BEACON link dump format
% Jakob Voß

# Introduction

BEACON is a data interchange format for large numbers of uniform links.  A
BEACON **link dump** consists of:

* a set of **links** ([](#links)),
* a set of **meta fields** ([](#meta-fields)).

Each link consists of a source URI, a target URI, and an optional annotation.
Common patterns in source URIs and target URIs respectively can be used to
abbreviate serializations of link dumps.  This specification defines:

* a serialization of link dumps (**BEACON files**) in a condense 
  line-oriented text format ([](#beacon-format)). A non-normative
  serialization based on XML is included in an appendix;
* two interpretations of link dumps as mapping to HTML and
  mapping to RDF ([](#mappings)).

The current specification is managed at <https://github.com/gbv/beaconspec>.

## Example

The simplest form of a BEACON file contains full URL links separated by a
vertical bar:

    http://example.com/people/alice|http://example.com/documents/23.about
    http://example.com/people/bob|http://example.com/documents/42.about

The first element of a link is called source URI and the second is called
target URI. If a target URI does not start with `http` or `https`, two vertical
bars MUST be used:

    http://example.com/people/alice||urn:isbn:0123456789

To give an extended example, the "ACME" company wants to provide links from
people to documents that each person contributed to (a "contributor"
relationship in terms of Dublin Core). A list of all people is available from
`http://example.com/people/` and a list of all documents, titled "ACME
documents", is available from `http://example.com/documents/`. This information
can be expressed in a serialized link dump with BEACON meta fields as
following:

    #INSTITUTION: ACME
    #RELATION:    http://purl.org/dc/elements/1.1/contributor
    #SOURCESET:   http://example.com/people/
    #TARGETSET:   http://example.com/documents/
    #NAME:        ACME documents

If both source URIs for people and target URIs for documents follow a pattern,
links can be abbreviated with the meta fields `PREFIX` and `TARGET` as
following:

    #PREFIX: http://example.com/people/
    #TARGET: http://example.com/documents/{+ID}.about

    alice||23
    bob||42

From this form the same links can be constructed as given at the beginning of
this example.

The example can be extended by addition of a third element for each link. For
instance the annotation could be used to specifcy the date of each document:

    #ANNOTATION: http://purl.org/dc/elements/1.1/date

    alice|2014-03-12|23
    bob|2013-10-21|42

## Notational Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be
interpreted as described in [](#RFC2119).

The formal grammar rules in this document are to be interpreted as described in
[](#RFC5234), including the ABNF core rules `HTAB`, `LF`, `CR`, and `SP`. In
addition, the minus operator (`-`) is used to exclude line breaks and vertical
bars from the rules LINE and TOKEN:

     LINE       =  *CHAR - ( *CHAR LINEBREAK *CHAR )

     TOKEN      =  *CHAR - ( *CHAR ( LINEBREAK / VBAR ) *CHAR )

     LINEBREAK  =  LF | CR LF | CR   ; "\n", "\r\n", or "\r"

     VBAR       =  %x7C              ; vertical bar ("|")

RDF in this document is expressed in Turtle syntax [](#TURTLE). The following
namespace prefixes are used to refer to RDF properties and classes from the RDF
and RDFS vocabularies [](#RDF), the DCMI Metadata Terms [](#DCTERMS), the FOAF
vocabulary [](#FOAF), the VoID vocabulary [](#VOID), and the RSS 1.0
Syndication Module [](#RSSSYND):

     rdf:     <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
     rdfs:    <http://www.w3.org/2000/01/rdf-schema#>
     dcterms: <http://purl.org/dc/terms/extent>
     foaf:    <http://xmlns.com/foaf/0.1/>
     void:    <http://rdfs.org/ns/void#>
     rssynd:  <http://web.resource.org/rss/1.0/modules/syndication/>

The blank node `:dump` denotes the URI of the link dump and the blank node
`:targetset` denotes the URI of the target dataset.


# Basic concepts

## Links

A link in a link dump is a directed connection between two resources that are
identified by URIs [](#RFC3986). A link is compromised of three elements:

* a **source URI**,
* a **target URI**,
* an **annotation**.

Source URI and target URI define where a link is pointing from and to
respectively. The annotation is an optional Unicode string, that can be used to
further describe the link or parts of it. Annotations MUST be
whitespace-normalized ([](#whitespace-normalization)) and MUST NOT contain a
`VBAR` character. A missing annotation is equal to the empty string. The
meaning of a link can be indicated by the **RELATION** meta field
([](#relation)).


## Allowed characters

The set of allowed Unicode characters in BEACON dumps is the set of valid
Unicode characters from UCS which can also be expressed in XML 1.0, excluding
some discouraged control characters:

     CHAR        =  WHITESPACE / %x21-7E / %xA0-D7FF / %xE000-FFFD
                 /  %x10000-1FFFD / %x20000-2FFFD / %x30000-3FFFD
                 /  %x40000-4FFFD / %x50000-5FFFD / %x60000-6FFFD
                 /  %x70000-7FFFD / %x80000-8FFFD / %x90000-9FFFD
                 /  %xA0000-AFFFD / %xB0000-BFFFD / %xC0000-CFFFD
                 /  %xD0000-DFFFD / %xE0000-EFFFD / %xF0000-FFFFD
                 /  %x10000-10FFFD

Applications SHOULD exclude disallowed characters by stripping them, by
replacing them with the replacement character `U+FFFD`, or by refusing to
process. Applications SHOULD also apply Unicode Normalization Form Canonical
Composition (NFKC) to all strings.

## Whitespace normalization 

A Unicode string is **whitespace-normalized** according to this specification,
by stripping leading and trailing whitespace and by replacing all `WHITESPACE`
character sequences by a single space (`SP`). 

     WHITESPACE  =  1*( CR | LF | HTAB | SP )

## URI patterns

A **URI pattern** in this specification is an URI Template, as defined in
[](#RFC6570), with all template expressions being either `{ID}` for simple
string expansion or `{+ID}` for reserved expansion.

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

# Meta fields

A link dump SHOULD contain a set of **meta fields**, each identified by its
name build of uppercase letters `A-Z`.  Relevant meta fields for description of
the source and target datasets ([](#source-and-target-datasets)), the link dump
([](#link-dump)), and links ([](#link-description)) are defined in the
following.  Additional meta fields, not defined in this specification, SHOULD
be ignored.  All meta field values MUST be whitespace-normalized. Missing meta
field values and empty strings MUST be set to the field’s default value, which
is the empty string unless noted otherwise. The following diagram shows which
meta fields belong to which dataset. Repeatable fields are marked with a plus
character (`+`): 

                          +------------------+
                          | link dump        |
                          |                  |
                          |  * DESCRIPTION+  |
                          |  * CREATOR+      |
                          |  * CONTACT+      |
                          |  * HOMEPAGE+     |
                          |  * FEED+         |
                          |  * TIMESTAMP+    |
                          |  * UPDATE        |
                          |                  |
                          |------------------|
                          | link description |
                          |                  |     +-----------------+
    +----------------+    |  * PREFIX        |     | target dataset  |
    | source dataset | ---|  * TARGET        |---> |                 |
    |                |    |  * RELATION      |     |  * TARGETSET    |
    |                | ---|  * MESSAGE       |---> |  * NAME+        |
    |  * SOURCESET   |    |  * ANNOTATION    |     |  * INSTITUTION+ |
    |                | ---|                  |---> |                 |
    +----------------+    +------------------+     +-----------------+


## Link dump

### DESCRIPTION

The `DESCRIPTION` meta field contains a human readable description of the link
dump. This field is mapped to the `dcterms:description` RDF property.  For
instance the field value "Mapping from ids to documents", expressible in BEACON
text format as

    #DESCRIPTION: Mapping from ids to documents

can be mapped to this RDF triple:

    :dump dcterms:description "Mapping from ids to documents" .

### CREATOR

The `CREATOR` meta field contains the URI or the name of the person,
organization, or a service primarily responsible for making the link dump.
This field is mapped to the `dcterms:creator` RDF property. The
creator is an instace of the class `foaf:Agent`.

For instance the following field values, expressed in BEACON format:

    #CREATOR: Bea Beacon
    #CREATOR: http://example.org/people/bea

can be mapped the the following RDF triples, respectively:

    :dump dcterms:creator "Bea Beacon" .
    :dump dcterms:creator [ a foaf:Agent ; foaf:name "Bea Beacon" ] .

    :dump dcterms:creator <http://example.org/people/bea> .
    <http://example.org/people/bea> a foaf:Agent .

This field SHOULD NOT contain a simple URL unless this URL is also used as URI.

### CONTACT

The `CONTACT` meta field contains an email address or similar contact
information to reach the creator of the link dump.  The field value SHOULD be a
mailbox address as specified in section 3.4 of [](#RFC5322), for instance:

     admin@example.com
    
     Bea Beacon <bea@example.org>

The `CONTACT` meta field is mapped to the `foaf:mbox` and to the `foaf:name`
RDF properties.  The domain of the the field is the BEACON dump. The sample
field values can be mapped to:

     :dump dcterms:creator [
         foaf:mbox <mailto:admin@example.com>
     ] .

     :dump dcterms:creator [
         foaf:name "Bea Beacon" ;
         foaf:mbox <mailto:bea@example.org>
     ] .

### HOMEPAGE

The `HOMEPAGE` meta field contains an URL of a website with additional
information about this link dump. This field corresponds to the RDF property
`foaf:homepage` with `dump` as subject. Note that this field does not specify
the homepage of the target dataset. For instance this field expressed in BEACON
text format

    #HOMEPAGE: http://example.org/about.html

can be mapped to this RDF triple:

    :dump foaf:homepage <http://example.org/about.html> .

### FEED

The `FEED` meta field contains an URL, where to download the link dump from.
This field corresponds to the RDF property `void:dataDump`. For instance this
field, expressed in BEACON format

    #FEED: http://example.com/beacon.txt

can be mapped to this RDF triple:

    :dump void:dataDump <http://example.com/beacon.txt> .

### TIMESTAMP

The `TIMESTAMP` field contains the date of last modification of the link dump.
Note that this value MAY be different to the last modification time of a BEACON
file that serializes the link dump.  The timestamp value MUST conform to the
`full-date` or to the `date-time` production rule in [](#RFC3339). In addition,
an uppercase `T` character MUST be used to separate date and time, and an
uppercase `Z` character MUST be present in the absence of a numeric time zone
offset. This field corresponds to the `dcterms:modified` property.  

For instance the following valid timestamp values, expressed in BEACON format:

     #TIMESTAMP: 2012-05-30
     #TIMESTAMP: 2012-05-30T15:17:36+02:00
     #TIMESTAMP: 2012-05-30T13:17:36Z

can be mapped to the following RDF triples, respectively:

     :dump dcterms:modified "2012-05-30"
     :dump dcterms:modified "2012-05-30T15:17:36+02:00"
     :dump dcterms:modified "2012-05-30T13:17:36Z"

### UPDATE

The `UPDATE` field specifies how frequently the link dump is likely to change.
The field corresponds to the `<changefreq>` element in [Sitemaps XML
format](#Sitemaps). Valid values are:

* `always`
* `hourly`
* `daily`
* `weekly`
* `monthly`
* `yearly`
* `never` 

The value "`always`" SHOULD be used to describe link dumps that change each
time they are accessed. The value "`never`" SHOULD be used to describe archived
link dumps. Please note that the value of this tag is considered a hint and not
a command. 

The RDF property of this field is `rssynd:updatePeriod`. For instance this
field, given in BEACON format:

    #UPDATE: daily

specifies a daily update, expressible in RDF as:

    :dump rssynd:updatePeriod "daily" .

## Link description

### PREFIX

The `PREFIX` meta field specifies an URI patter to construct link sources. If
this field is not specified or set to the empty string, the default value
`{+ID}` is used. If the field value contains no template expression, the
expression `{ID}` is appended.

The name `PREFIX` was choosen to keep backwards compatibility with existing
BEACON files.

Applications MAY map this field to the RDF property `void:uriSpace` or
`void:uriRegexPattern` with `:sourceset` as RDF subject.

### TARGET

The `TARGET` meta field specifies an URI patter to construct link targets. If
this field is not specified or set to the empty string, the default value
`{+ID}` is used. If the field value field contains no template expression, the
expression `{ID}` is appended.

Applications MAY map this field to the RDF property `void:uriSpace` or
`void:uriRegexPattern` with `:targetset` as RDF subject.

### MESSAGE

The `MESSAGE` meta field is used as template for link annotations. The default
value is `{annotation}`.

### RELATION

All links in a link dump share a common relation type, specified by the
`RELATION` meta field. A relation type MUST be either an URI or a registered
link type from the IANA link relations registry [](#RFC5988). The default
relation type is `rdfs:seeAlso`.  This field is mapped to the RDF property
`void:linkPredicate` with subject `:dump`.

Some examples of relation types:

     http://www.w3.org/2002/07/owl#sameAs
     http://xmlns.com/foaf/0.1/isPrimaryTopicOf
     http://purl.org/spar/cito/cites
     describedby
     replies

### ANNOTATION

The `ANNOTATION` field specifies an RDF property for RDF triples between link
target and link annotation. Without this field, the link annotation has no
explicit meaning. To give an example, the following BEACON file:

    #ANNOTATION: http://purl.org/dc/elements/1.1/format

    http://example.org/apples|sphere|http://example.org/oranges

implies the following triple if mapped to RDF:

    <http://example.org/oranges> dc:format "sphere" .


## Source and target datasets

The set that all source URIs in a link dump originate from is called the
**source dataset** and the set that all target URIs originate from is called
the **target dataset**. 

### SOURCESET

The source dataset can be identified by the `SOURCESET` meta field, which MUST
be an URI if given. This field replaces the blank node `:sourceset`.

### TARGETSET

The target dataset can be identified by the `TARGETSET` meta field, which MUST
be an URI if given. This field replaces the blank node `:targetset`.

### NAME

The `NAME` meta field contains a name or title of target dataset. This field is
mapped to the RDF property `dcterms:title`. For instance the field value "ACME
documents", expressible in BEACON format as

    #NAME: ACME documents

can be mapped to this RDF triple:

    :targetset dcterms:title "ACME documents" .

### INSTITUTION

The `INSTITUTION` meta field contains the name or URI of the organization or of
an individual responsible for making available the target dataset. This field
is mapped to the RDF property `dcterms:publisher`. For instance the field value
"ACME", expressible in BEACON format as

    #INSTITUTION: ACME

can be mapped to this RDF triple:

    :targetset dcterms:publisher "ACME" .

A field value starting with `http://` or `https://` is interpreted as URI
instead of string. For instance

    #INSTITUTION: http://example.org/acme/

can be mapped to this RDF triple:

    :targetset dcterms:publisher <http://example.org/acme/> .


# BEACON format

A BEACON file is an UTF-8 encoded Unicode file [](#RFC3629), split into lines
by line breaks (rule `LINEBREAK`). The file consists of a set of lines with
meta fields, followed by a set of lines with link tokens. A BEACON file MAY
begin with an Unicode Byte Order Mark and it SHOULD end with a line break:

     BEACONTEXT  =  [ BOM ]
                    *METALINE
                    *EMPTY
                     LINKLINE *( LINEBREAK LINKLINE )
                    [ LINEBREAK ]

     BOM         =  %xEF.BB.BF     ; Unicode UTF-8 Byte Order Mark

The order of meta lines and of link lines, respectively, is irrelevant. At
least one empty line SHOULD be used to separate meta lines and link lines.
If no empty line is given, the first link line MUST NOT begin with `"#"`.

    EMPTY        =  *WHITESPACE LINEBREAK

A meta line specifies a meta field ([](#meta-fields)) and its value, separated
by colon and/or tabulator or space: 

     METALINE    =  "#" METAFIELD SEPARATOR METAVALUE LINEBREAK

     SEPARATOR   =  ":" *( HTAB / SP ) / +( HTAB / SP )

     METAFIELD   =  +( %x41-5A )   ;  "A" to "Z"

     METAVALUE   =  LINE

A BEACON file SHOULD start with the fixed meta field `FORMAT` set to
"BEACON" ("`#FORMAT: BEACON`").

Each link is given on a link line with its source token, optionally follwed by
annotation token and target token:

     LINKLINE    =  SOURCE [ 
                      VBAR ANNOTATION /
                      VBAR ANNOTATION VBAR TARGET /
                      VBAR TARGET
                    ]

     SOURCE      =  TOKEN

     TARGET      =  TOKEN

     ANNOTATION  =  TOKEN

The ambiguity of rule `LINKLINE` with one occurrence of `VBAR` is resolved is
following:

* If the target meta field has its default value `{+ID}`, and the message meta 
  field has its default value `{annotation}`, and the whitespace-normalized second 
  token begins with "http:" or "https:", then the second token is used as target token.
* The second token is used as annotation token otherwise.

This way one can use two forms to encode links to HTTP URIs (given target 
meta field and message meta field with their default values):

    foo|http://example.org/foobar
    foo||http://example.org/foobar

## Link construction

Link elements are given in abbreviated form of **link tokens** when serialized
in a BEACON file. Each link is constructed from:

* a mandatory source token
* an optional annotation token
* an optional target token, which is set to the source token if missing

All tokens MUST be whitespace-normalized before further
processing.  The full link is then constructed as following:

* The source URI is constructed from the `PREFIX` meta field URI pattern by 
  inserting the source token, as defined in [](#uri-patterns).
* The target URI is constructed from the `TARGET` meta field URI pattern by 
  inserting the target token, as as defined in [](#uri-patterns).
* The annotation is constructed from the `MESSAGE` meta field by literally 
  replacing every occurrence of the character sequence `{annotation}` by the 
  annotation token.  The resulting string MUST be whitespace-normalized after
  construction additional encoding MUST NOT be applied.

The following table illustrates construction of a link:

     meta field  +  link token  -->  link element
    ----------------------------------------------
     prefix      |  source       |   source URI
     target      |  target       |   target URI
     message     |  annotation   |   annotation

Constructed source URI and target URI MUST be syntactically valid.
Applications MUST ignore links with invalid URIs and SHOULD give a warning.
Note that annotation tokens are always ignored if the `MESSAGE` meta field does
not contain the sequence `{annotation}`. Applications SHOULD give a warning in
this case.

Applications MUST NOT differentiate between equal links constructed from
different abbreviations. For instance the following BEACON file contains a
single link:

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

Multiple occurrences of equal links in one BEACON file SHOULD be ignored.  It
is RECOMMENDED to indicate duplicated links with a warning.

## MIME type

The recommended MIME type of BEACON files is "text/beacon". The file
extension `.txt` SHOULD be used when storing BEACON files.


# Mappings

An important use-case of BEACON is the creation of HTML links as described in
section [](#mapping-to-html). A link dump can also be mapped to an RDF graph
([](#mapping-to-rdf)) so BEACON provides a RDF serialization format for a
subset of RDF graphs with uniform links. 

## Mapping to RDF

The following triples are always assumed in mappings of link dumps to RDF:

     :sourceset a void:Dataset .
     :targetset a void:Dataset .

     :dump a void:Linkset ; 
         void:subjectsTarget :sourceset ;
         void:objectsTarget :targetset .

The mapping of meta fields that describe source dataset, target datasets, and
link dumps is described above ([](#source-and-target-datasets),
[](#link-dump)).

### Mapping links

Each link can be mapped to at least one RDF triple with:

* the source URI used as subject IRI,
* the relation type used as predicate,
* the target URI used as object IRI.

As RDF is not defined on URIs but on URI references or IRIs, all URIs MUST be
transformed to an IRI by following the process defined in Section 3.2 of
[](#RFC3987). Applications MAY reject mapping link dumps with relation type
from the IANA link relations registry, in lack of official URIs. Another
valid solution is to extend the RDF model by using blank nodes as predicates.

### Mapping link annotations

Each link annotation SHOULD result in an additional RDF triple, unless its
value equals to the empty string. The additional triple is mapped with: 

* the target URI used as subject IRI,
* the `ANNOTATION` meta field used as predicate,
* the annotation value used as literal object.

Applications MAY use a predefined URI as ANNOTATION or process the link
annotation by other means. For instance annotations could contain additional
information about a link such as its provenience, date, or probability
(reification).

Typical use cases of annotations include specification of labels and a "number
of hits" at the target dataset. For instance the following file in
BEACON format ([](#beacon-format)):

     #PREFIX: http://example.org/
     #TARGET: http://example.com/ 
     #RELATION: http://xmlns.com/foaf/0.1/primaryTopic
     #ANNOTATION: http://purl.org/dc/terms/extent

     abc|12|xy

is mapped to the following RDF triples:

     <http://example.org/abc> foaf:primaryTopic <http://example.com/xy> .
     <http://example.com/xy> dcterms:extent "12" .

## Mapping to HTML

This document does not specify a single mapping of links in a BEACON link dump
to links in a HTML document, so the following description is non-normative.

A link in a BEACON dump can be mapped to a HTML link (`<a>` element) as
following:

* link source corresponds to the website which a HTML link is included at,
* link target corresponds to the `href` attribute,
* link annotation corresponds to the textual content,

For instance the following link, given in a BEACON file:

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
`foaf:Person` translates to "this person", and the target dataset’s name can
be used as link label.

# Security Considerations

Programs should be prepared for malformed and malicious content when parsing
BEACON files, when constructing links from link tokens, and when mapping links
to RDF or HTML. Possible attacks of parsing contain broken UTF-8 and buffer
overflows. Link construction can result in unexpectedly long strings and
character sequences that may be harmless when analyzed as parts. Most notably,
BEACON data may store strings containing HTML and JavaScript code to be used
for cross-site scripting attacks on the site displaying BEACON links.
Applications should therefore escape or filter accordingly all content with
established libraries, such as Apache Escape Utils.
