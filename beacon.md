% BEACON link dump format
% Jakob Voß

# Introduction

BEACON is a data interchange format for large numbers of uniform links.  A
BEACON **link dump** consists of:

* a set of **links** ([](#links)),
* a set of **meta fields** ([](#meta-fields)).

Each link consists of a source identifier, a target identifier, and an optional
annotation. Common patterns in these elements can be used to abbreviate
serializations of link dumps.  This specification defines:

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

The first element of a link is called source identifier and the second is
called target identifier. In most cases these identifiers are URLs or URIs. If
a target identifier does not start with `http` or `https`, two vertical bars
MUST be used:

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

If both source identifiers for people and target identifiers for documents
follow a pattern, links can be abbreviated with the meta fields `PREFIX` and
`TARGET` as following:

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

Samples of RDF in this document are expressed in Turtle syntax [](#TURTLE). 

# Basic concepts

## Links

A link in a link dump is a directed connection between two resources,
optionally enriched by an annotation. A link is compromised of
three elements:

* a **source identifier**,
* a **target identifier**,
* an **annotation**.

All elements MUST be whitespace-normalized ([](#whitespace-normalization))
Unicode strings that MUST NOT contain a `VBAR` character. Source identifier and
target identifier define where a link is pointing from and to respectively. The
identifiers MUST NOT be empty strings and they SHOULD be URIs [](#RFC3986). The
annotation can optionally be used to further describe the link or parts of it.
A missing annotation is equal to the empty string. The meaning of a link can be
indicated by the **RELATION** meta field ([](#relation)).

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

     WHITESPACE  =  1*( CR | LF | SPACE )

     SPACE       =  HTAB | SP

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

# BEACON format

A **BEACON file** is an UTF-8 encoded Unicode file [](#RFC3629). The file MAY
begin with an Unicode Byte Order Mark and it SHOULD end with a line break. The
first line of a BEACON file SHOULD be the character sequence "`#FORMAT:
BEACON`". The rest of the file consists of a (possibly empty) set of lines that
express meta fields ([](#meta-fields)), followed by a set of lines with link
tokens which links are constructed from ([](#link-construction)).  At least one
empty line SHOULD be used to separate meta lines and link lines. If no empty
line is given, the first link line MUST NOT begin with `"#"`.

     BEACONFILE  =  [ %xEF.BB.BF ]        ; Unicode UTF-8 Byte Order Mark
                    [ "#FORMAT" SEPARATOR "BEACON" *SPACE LINEBREAK ]
                    *( METALINE LINEBREAK )
                    *( *SPACE LINEBREAK ) ; empty lines
                     LINKLINE *( LINEBREAK LINKLINE )
                    [ LINEBREAK ]

The order of meta lines and of link lines, respectively, is irrelevant. 

A **meta line** specifies a meta field ([](#meta-fields)) and its value,
separated by colon and/or tabulator or space: 

     METALINE    =  "#" METAFIELD SEPARATOR METAVALUE

     SEPARATOR   =  ":" *SPACE / +SPACE

     METAFIELD   =  +( %x41-5A )   ;  "A" to "Z"

     METAVALUE   =  LINE

Each link is given on a **link line** with its source token, optionally follwed by
annotation token and target token:

     LINKLINE    =  SOURCE /
                    SOURCE VBAR TARGET /   ; if TARGET is http: or https:
                    SOURCE VBAR ANNOTATION /
                    SOURCE VBAR ANNOTATION VBAR TARGET

     SOURCE      =  TOKEN

     TARGET      =  TOKEN

     ANNOTATION  =  TOKEN

The ambiguity of rule `LINKLINE` with one occurrence of `VBAR` is resolved is
following:

* If the target meta field ([](#target)) has its default value `{+ID}`, and the 
  message meta field ([](#message)) has its default value `{annotation}`, and 
  the whitespace-normalized second token begins with "http:" or "https:", then 
  the second token is used as target token.
* The second token is used as annotation token otherwise.

This way one can use two forms to encode links to HTTP URIs (given target 
meta field and message meta field with their default values):

    foo|http://example.org/foobar
    foo||http://example.org/foobar

## Link construction

Link elements in BEACON format are given in abbreviated form of **link
tokens**. Each link is constructed from:

* a mandatory source token
* an optional annotation token
* an optional target token, which is set to the source token if missing

All tokens MUST be whitespace-normalized before further
processing.  

Construction rules are based on the value of link construction meta fields
([](#link-construction-meta-fields)). A link is constructed as following:

* The source identifier is constructed from the `PREFIX` meta field URI pattern by 
  inserting the source token, as defined in [](#uri-patterns).
* The target identifier is constructed from the `TARGET` meta field URI pattern by 
  inserting the target token, as as defined in [](#uri-patterns).
* The annotation is constructed from the `MESSAGE` meta field by literally 
  replacing every occurrence of the character sequence `{annotation}` by the 
  annotation token.  The resulting string MUST be whitespace-normalized after
  construction additional encoding MUST NOT be applied.

The following table illustrates construction of a link:

     meta field  +  link token  -->  link element
    ---------------------------------------------------
     prefix      |  source       |   source identifier
     target      |  target       |   target identifier
     message     |  annotation   |   annotation

Constructed source identifier and target identifier SHOULD be syntactically
valid URIs. Applications MAY ignore links with invalid URIs and SHOULD give a
warning. Note that annotation tokens are always ignored if the `MESSAGE` meta
field does not contain the sequence `{annotation}`. Applications SHOULD give a
warning in this case.

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

The RECOMMENDED MIME type of BEACON files is "text/beacon". The file
extension `.txt` SHOULD be used when storing BEACON files.

# Meta fields

A link dump SHOULD contain a set of **meta fields**, each identified by its
name build of uppercase letters `A-Z`.  Relevant meta fields for link
construction ([](#link-construction-meta-fields)), for description of the link
dump ([](#link-dump-meta-fields)), and for description of source dataset and
target dataset ([](#dataset-meta-fields)) are defined in the following.
Additional meta fields, not defined in this specification, SHOULD be ignored.
All meta field values MUST be whitespace-normalized. Missing meta field values
and empty strings MUST be set to the field’s default value, which is the empty
string unless noted otherwise. The following diagram shows which meta fields
belong to which dataset. Repeatable fields are marked with a plus character
(`+`): 

                        +-----------------------+
                        | link dump             |
                        |                       |
                        |  * DESCRIPTION+       |
                        |  * CREATOR+           |
                        |  * CONTACT+           |
                        |  * HOMEPAGE+          |
                        |  * FEED+              |
                        |  * TIMESTAMP+         |
                        |  * UPDATE             |
                        |                       |
                        | +-------------------+ |
                        | | link construction | |
                        | |                   | |   +-----------------+
    +----------------+  | |  * PREFIX         | |   | target dataset  |
    | source dataset | ---|  * TARGET         |---> |                 |
    |                |  | |  * RELATION       | |   |  * TARGETSET    |
    |                | ---|  * MESSAGE        |---> |  * NAME+        |
    |  * SOURCESET   |  | |  * ANNOTATION     | |   |  * INSTITUTION+ |
    |                | ---|                   |---> |                 |
    +----------------+  | +-------------------+ |   +-----------------+
                        +-----------------------+

Examples of meta fields are included in [](#mapping-to-rdf).

## Link construction meta fields

Link construction meta fields define how to construct links from link tokens
([](#link-construction)). See [](#mapping-link-construction-meta-fields-to-rdf)
for examples.

### PREFIX

The `PREFIX` meta field specifies an URI patter to construct sources
identfiers. If this field is not specified or set to the empty string, the
default value `{+ID}` is used. If the field value contains no template
expression, the expression `{ID}` is appended. The name `PREFIX` was choosen to
keep backwards compatibility with existing BEACON files.

### TARGET

The `TARGET` meta field specifies an URI patter to construct target
identifiers. If this field is not specified or set to the empty string, the
default value `{+ID}` is used. If the field value field contains no template
expression, the expression `{ID}` is appended.

### MESSAGE

The `MESSAGE` meta field is used as template for link annotations. The default
value is `{annotation}`.

### RELATION

All links in a link dump share a common relation type, specified by the
`RELATION` meta field. The default relation type is `rdfs:seeAlso`, but
application not interested in mapping to RDF can ignore this meta field. A
relation type MUST be either an URI or a registered link type from the IANA
link relations registry [](#RFC5988).

### ANNOTATION

The `ANNOTATION` field can be used to specify a specific the meaning of link
annotations in a link dump. The field value MUST be an URI.


## Link dump meta fields

Link dump meta fields describe the link dump as whole. See
[](#mapping-link-dump-meta-fields-to-rdf) for examples.

### DESCRIPTION

The `DESCRIPTION` meta field contains a human readable description of the link
dump.

### CREATOR

The `CREATOR` meta field contains the URI or the name of the person,
organization, or a service primarily responsible for making the link dump. The
field SHOULD NOT contain a simple URL, unless this URL is also used as URI.

### CONTACT

The `CONTACT` meta field contains an email address or similar contact
information to reach the creator of the link dump.  The field value SHOULD be a
mailbox address as specified in section 3.4 of [](#RFC5322).

### HOMEPAGE

The `HOMEPAGE` meta field contains an URL of a website with additional
information about this link dump. Note that this field does not specify
the homepage of the target dataset.

### FEED

The `FEED` meta field contains an URL, where to download the link dump from.

### TIMESTAMP

The `TIMESTAMP` field contains the date of last modification of the link dump.
Note that this value MAY be different to the last modification time of a BEACON
file that serializes the link dump.  The timestamp value MUST conform to the
`full-date` or to the `date-time` production rule in [](#RFC3339). In addition,
an uppercase `T` character MUST be used to separate date and time, and an
uppercase `Z` character MUST be present in the absence of a numeric time zone
offset.

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

## Dataset meta fields

The set that all source identifiers in a link dump originate from is called the
**source dataset** and the set that all target identifiers originate from is
called the **target dataset**. Dataset meta fields contain properties of the
source dataset or target dataset, respectively.  See
[](#mapping-dataset-meta-fields-to-rdf) for examples of this meta fields.

### SOURCESET

The source dataset can be identified by the `SOURCESET` meta field, which MUST
be an URI if given. 

### TARGETSET

The target dataset can be identified by the `TARGETSET` meta field, which MUST
be an URI if given.

### NAME

The `NAME` meta field contains a name or title of the target dataset.

### INSTITUTION

The `INSTITUTION` meta field contains the name or HTTP URI of the organization
or of an individual responsible for making available the target dataset. 

