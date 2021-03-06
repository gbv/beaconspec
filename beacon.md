% BEACON link dump format
% Jakob Voß

# Introduction

BEACON is a data interchange format for large numbers of uniform links.  A
BEACON **link dump** consists of

* a set of **meta fields** ([](#meta-fields)) and
* a set of **links** ([](#links)).

Link dumps can be serialized in **BEACON format** ([](#beacon-format)). BEACON
format is a condense, line-oriented text format that utilizes common patterns
in links of a link dump form abbreviation. A link dump serialized in BEACON
format is also referred to as **BEACON file**.

Link dumps can further be mapped to RDF graphs with minor limitations
([](#mapping-to-rdf)).

The non-normative appendix contain a mapping of BEACON links to HTML
([](#mapping-beacon-to-html)) and a serialization of link dumps based on XML
([](#beacon-xml-format)).

The current specification is managed at <https://github.com/gbv/beaconspec>.

## Notational conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be
interpreted as described in [](#RFC2119).

The formal grammar rules in this document are to be interpreted as described in
[](#RFC5234), including the ABNF core rules `HTAB`, `LF`, `CR`, and `SP`. In
addition, the minus operator (`-`) is used to exclude line breaks and vertical
bars from the rules `LINE` and `TOKEN` in [](#beacon-files).

Samples of RDF graphs in this document are expressed in Turtle syntax [](#TURTLE).

## Examples

The simplest form of a BEACON file contains full URL links separated by one or two vertical bars:

    http://example.com/people/alice|http://example.com/documents/23.about
    http://example.com/people/bob||http://example.com/documents/42.about

The first element of a link is called source identifier and the second is
called target identifier. In most cases these identifiers are URLs or URIs. If
a target identifier does not start with `http:` or `https:`, two vertical bars
MUST be used:

    http://example.com/people/alice||urn:isbn:0123456789

Source identifier and target identifier can be abbreviated with the meta fields
`PREFIX` and `TARGET`, respectively. A simple BEACON file with such
abbreviations can look like this:

    #FORMAT: BEACON
    #PREFIX: http://example.org/id/
    #TARGET: http://example.com/about/

    12345
    6789||abc

In this examples the following two links are encoded:

    http://example.org/id/12345|http://example.com/about/12345
    http://example.org/id/6789|http://example.com/about/abc

Links can further be extended by link annotation and relation type.

# Basic concepts

## Links

A link in a link dump is a directed, typed connection between two resources,
optionally enriched by an annotation. A link is compromised of four elements:

* a **source identifier**,
* a **target identifier**,
* a **relation type**, and
* a **link annotation**.

Each elements MUST be whitespace-normalized Unicode strings
([](#whitespace-normalization)) that conforms to the `TOKEN` grammar rule given
in [](#beacon-files). All elements except link annotation MUST NOT be
empty strings.

Source identifier and target identifier define where a link is pointing from
and to respectively.  Relation type is an identifier that indicates the meaning
of a link. All these identifiers SHOULD be URIs [](#RFC3986). A link annotation
can be used to further describe a link or parts of it.

All links in a link dump share either a common relation type or a common link
annotation, or both. This uniformity is used to abbreviate links in BEACON
format ([](#beacon-format)).

The set that all source identifiers in a link dump originate from is called the
**source dataset** and the set that all target identifiers originate from is
called the **target dataset**.

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

A **URI pattern** in this specification is a URI Template, as defined in
[](#RFC6570), with all template expressions being either `{ID}` for simple
string expansion or `{+ID}` for reserved expansion. URI patterns are used in
link construction ([](#link-construction)) to expand link tokens to full
identifiers (usually URIs).

A URI pattern is allowed to contain the broader set of characters allowed in
Internationalized Resource Identifiers (IRI) [](#RFC3987). The URI constructed
from a URI pattern by template processing can be transformed to a IRI by
following the process defined in Section 3.2 of [](#RFC3987).

For instance the URI pattern `http://example.org/?id={ID}` is expanded to:

     ID variable      Expanded

      Hello World!     http://example.org/?id=Hello%20World%21
      x/?a=1&b=2       http://example.org/?id=x%2F%3Fa%3D1%26b%3D2
      M%C3%BCller      http://example.org/?id=M%25C3%25BCller

And the URI pattern `http://example.org/{+ID}` is expanded to:

     ID variable      Expanded

      Hello World!     http://example.org/Hello%20World!
      x/?a=1&b=2       http://example.org/x/?a=1&b=2
      M%C3%BCller      http://example.org/M%25C3%25BCller

# BEACON format

## BEACON files

A **BEACON file** is a UTF-8 encoded Unicode file [](#RFC3629). The file MAY
begin with a Unicode Byte Order Mark and it SHOULD end with a line break. The
rest of the file consists of four parts in this order:

1. a format indicator (`#FORMAT: BEACON`)
2. a list of meta lines
3. a list of empty lines
4. a list of link lines

All four parts are optional but RECOMMENDED. The order of meta lines and of
link lines, respectively, is irrelevant.

     LINE       =  *CHAR - ( *CHAR LINEBREAK *CHAR )

     TOKEN      =  *CHAR - ( *CHAR ( LINEBREAK / VBAR ) *CHAR )

     LINEBREAK  =  LF | CR LF | CR   ; "\n", "\r\n", or "\r"

     VBAR       =  %x7C              ; vertical bar ("|")

     SEPARATOR   =  ":" *SPACE / +SPACE

     BEACONFILE  =  [ %xEF.BB.BF ]        ; Unicode UTF-8 Byte Order Mark
                    [ "#FORMAT" SEPARATOR "BEACON" *SPACE LINEBREAK ]
                    *( METALINE LINEBREAK )
                    *( *SPACE LINEBREAK ) ; empty lines
                     LINKLINE *( LINEBREAK LINKLINE )
                    [ LINEBREAK ]

A **meta line** specifies a meta field ([](#meta-fields)) and its value,
separated by colon and/or tabulator or space:

     METALINE    =  "#" METAFIELD SEPARATOR METAVALUE

     METAFIELD   =  +( %x41-5A )   ;  "A" to "Z"

     METAVALUE   =  LINE

If a BEACON file contains multiple meta lines with same field name, all but one
of these lines MUST be ignored. Applications SHOULD emit a warning for multiple
meta lines with same field name.

Each link is given on a **link line** with its source token, optionally follwed
by annotation token and target token. These link elements are used for
([](#link-construction)) unless the source token consists of whitespace only.
If no empty line is given, the first link line MUST NOT begin with `#`.

     LINKLINE    =  SOURCE /
                    SOURCE VBAR TARGET /
                    SOURCE VBAR ANNOTATION /
                    SOURCE VBAR ANNOTATION VBAR TARGET

     SOURCE      =  TOKEN

     TARGET      =  TOKEN

     ANNOTATION  =  TOKEN

The ambiguity of rule `LINKLINE` with one `VBAR` is resolved is following:

* If the target meta field ([](#target)) has its default value `{+ID}` and
  the whitespace-normalized second token begins with `http:` or `https:`, then
  the second token is used as target token.
* The second token is used as annotation token otherwise.

This way one can use two forms to encode links to HTTP URIs (given target
meta field and message meta field with their default values):

    foo|http://example.org/bar
    foo||http://example.org/bar

Applications MAY accept link lines with more than two vertical bars but they
MUST ignore additional content between a third vertical bar and the end of the
line.

## Link construction

Link elements in BEACON format are given in abbreviated form with **link
tokens**. Each link is constructed based on meta fields for link construction
([](#meta-fields-for-link-construction)) and from

* a mandatory **source token** which MUST NOT consist of whitespace only,
* an optional **annotation token**, and
* an optional **target token**.

All tokens MUST be whitespace-normalized before further processing. The link
elements are then constructed as following (see [](#uri-patterns) for how to
construct values from URI patterns):

* The source identifier is constructed from the `PREFIX` meta field URI pattern
  by inserting the source token.

* The target identifier is constructed from the `TARGET` meta field URI pattern
  by inserting either the target token if the target token is given and not
  empty, or the source token otherwise.

* The link annotation is set to the annotation token if the `RELATION` meta
  field contains a URI and the annotation token is given and not empty.
  Otherwise the link annotation is set to the `MESSAGE` meta field.

* The relation type is set to the `RELATION` meta field if this field contains
  a URI. If this field contains a URI pattern instead, the relation type is
  constructed from this pattern by inserting the annotation token or the empty
  string if no annotation token is given.

The following table illustrates construction of a link:

     meta field  +  link token  -->  link element
    ---------------------------------------------------
     PREFIX      |  source       |   source identifier
     TARGET      |  target       |   target identifier
     MESSAGE     |  annotation   |   link annotation
     RELATION    |  annotation   |   relation type

Constructed source identifier, target identifier, and relation types SHOULD be
syntactically valid URIs. Applications MAY ignore links with invalid URIs and
SHOULD emit a warning.

Applications MUST NOT differentiate between equal links constructed from
different abbreviations. For instance the following BEACON file contains a
single link:

     #PREFIX: http://example.org/
     #TARGET: http://example.com/
     #MESSAGE: Hello World!

     foo

The same link could also be serialized without any meta fields:

     http://example.org/foo|Hello World!|http://example.com/foo

The default meta fields values can be specified as:

     #PREFIX: {+ID}
     #TARGET: {+ID}
     #RELATION: http://www.w3.org/2000/01/rdf-schema#seeAlso

Multiple occurrences of equal links in one BEACON file SHOULD be ignored.  It
is RECOMMENDED to indicate duplicated links with a warning.

## MIME type

The RECOMMENDED MIME type of BEACON files is "text/plain". The file
extension `.txt` SHOULD be used when storing BEACON files.

# Meta fields

A link dump SHOULD contain a set of **meta fields**, each identified by its
name build of uppercase letters `A-Z`.  Relevant meta fields for link
construction ([](#meta-fields-for-link-construction)), for description of the link
dump ([](#meta-fields-for-link-dumps)), and for description of source dataset and
target dataset ([](#meta-fields-for-datasets)) are defined in the following.

A link dump can only contain one value for each meta field. Additional meta
fields, not defined in this specification, SHOULD be ignored. 

All meta field values MUST be whitespace-normalized. Missing meta field values
and empty strings MUST be set to the field’s default value, which is the empty
string unless noted otherwise. The following diagram shows which meta fields
belong to which dataset.

                        +-----------------------+
                        | link dump             |
                        |                       |
                        |  * DESCRIPTION        |
                        |  * CREATOR            |
                        |  * CONTACT            |
                        |  * HOMEPAGE           |
                        |  * FEED               |
                        |  * TIMESTAMP          |
                        |  * UPDATE             |
                        |                       |
                        | +-------------------+ |
                        | | link construction | |
                        | |                   | |   +-----------------+
    +----------------+  | |  * PREFIX         | |   | target dataset  |
    | source dataset | ---|  * TARGET         |---> |                 |
    |                |  | |  * RELATION       | |   |  * TARGETSET    |
    |                | ---|  * MESSAGE        |---> |  * NAME         |
    |  * SOURCESET   |  | |  * ANNOTATION     | |   |  * INSTITUTION  |
    |                | ---|                   |---> |                 |
    +----------------+  | +-------------------+ |   +-----------------+
                        +-----------------------+

Examples of meta fields are included in [](#mapping-to-rdf).

## Meta fields for link construction

The following meta fields define how to construct links from link tokens
([](#link-construction)). See [](#meta-fields-for-link-construction-in-rdf) for
mapping of these fields to RDF.

### PREFIX

The `PREFIX` meta field specifies a URI pattern ([](#uri-patterns)) to
construct source identfiers. If the non-empty field value contains no URI
pattern, the expression `{ID}` is appended.

The default value is `{+ID}`.

The name `PREFIX` was choosen to keep backwards compatibility with existing
BEACON files.

### TARGET

The `TARGET` meta field specifies a URI pattern ([](#uri-patterns)) to
construct target identifiers. If the non-empty field value field contains no
URI pattern, the expression `{ID}` is appended.

The default value is `{+ID}`.

### MESSAGE

The `MESSAGE` meta field specifies a default value for link annotations.

### RELATION

The `RELATION` meta field specifies relation types of links. The field value
MUST be either a URI as defined in [](#RFC3986) or a URI pattern as
described in [](#uri-patterns).

The default value is `http://www.w3.org/2000/01/rdf-schema#seeAlso`.

### ANNOTATION

The `ANNOTATION` field can be used to specify the meaning of link annotations
in a link dump. The field value MUST be a URI.


## Meta fields for link dumps

Meta fields for link dumps describe the link dump as whole. See
[](#meta-fields-for-link-dumps-in-rdf) for mapping of these fields to RDF.

### DESCRIPTION

The `DESCRIPTION` meta field contains a human readable description of the link
dump.

### CREATOR

The `CREATOR` meta field contains the URI or the name of the person,
organization, or a service primarily responsible for making the link dump. The
field SHOULD NOT contain a simple URL, unless this URL is also used as URI.

### CONTACT

The `CONTACT` meta field contains an email address or similar contact
information to reach the creator of the link dump.  The field value SHOULD be
an individual mailbox address as specified in section 3.4 of [](#RFC5322).

### HOMEPAGE

The `HOMEPAGE` meta field contains a URL of a website with additional
information about this link dump. Note that this field does not specify
the homepage of the target dataset.

### FEED

The `FEED` meta field contains a URL, where to download the link dump from.

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

The value `always` SHOULD be used to describe link dumps that change each time
they are accessed. The value `never` SHOULD be used to describe archived link
dumps.

## Meta fields for datasets

Dataset meta fields contain properties of the source dataset or target dataset,
respectively.  See [](#meta-fields-for-datasets-in-rdf) for for mapping of
these fields to RDF.

### SOURCESET

The `SOURCESET` meta field contains the URI of the source dataset.

### TARGETSET

The `TARGETSET` meta field contains the URI of the target dataset.

### NAME

The `NAME` meta field contains a name or title of the target dataset.

### INSTITUTION

The `INSTITUTION` meta field contains the name or HTTP URI of the organization
or of an individual responsible for making available the target dataset.

