% BEACON link dump format
% Jakob Voß

# Introduction

## Overview

BEACON is a data interchange format for large numbers of uniform links.  A
BEACON link dump consists of:

* a set of [links](#links), each constructed from a set of 
  [link fields](#link-fields),
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

In addition, the operator `-` can be used in rules to express exceptions.
For instance the symbol `LINESTRING` is defined as Unicode string that does
not include a line break: 

     LINESTRING  =  *( CHAR - LINEBREAK )

     LINEBREAK   =  *( CR / LF ) ; at least linefeed or carriage return

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

# Links

A link in BEACON is a typed connection between two resources that are
identified by URIs [](#RFC3986), and is compromised of:

* a source URI,
* a target URI
* a relation type, 
* an optional label,
* an optional description.

A BEACON link dump is an annotated set of links with identical relation type.
A relation type is either a registered link type from the IANA link relations
registry  [](#RFC5988) or an URI. Some examples of relation types:

	 alternate
	 describedby
	 replies
     http://www.w3.org/2002/07/owl#sameAs
	 http://xmlns.com/foaf/0.1/primaryTopicOf
	 http://purl.org/spar/cito/cites

In a [serialized BEACON dump](#serialization) the relation type is specified by
the link [meta field](#meta-fields) and the other parts of each link are
specified by a set of [link fields](#link-fields). The meaning of a link and
its parts is not defined by this specification, but guidelines are given in
[](#interpreting-beacon-links).

# Meta fields

A BEACON dump SHOULD be annotated with a set of meta fields. Each meta field is
identified by its name, build of lowercase letters `a-z`. In [BEACON text
format](#beacon-text-format), meta field names are case insensitive and SHOULD
be given in uppercase letters.

Valid meta fields are listed in the following. Additional meta fields, not
defined in this specification SHOULD be ignored. All meta field values MUST be
normalized Unicode strings [](#string-normalization). Missing meta fields
and meta fields with the empty string as normalized field value MUST be set to
their default value, which is the empty string unless noted otherwise.

## prefix

The prefix field specifies an URI pattern that is used to construct link
sources.  If no prefix meta field was specified, the default value `{+ID}` is
used.  The name `prefix` was choosen to keep backwards compatibility with
existing BEACON dumps.

## target

The target field specifies an URI pattern to construct link targets.  If no
target meta field was specified, the default value `{+ID}` is used.

## link

The link field specifies the relation type for all links in a BEACON dump.
The default relation type is `http://www.w3.org/2000/01/rdf-schema#seeAlso`.

## contact

The contact field contains an email address or similar contact information to
reach the maintainer of the BEACON dump.  The contact SHOULD be a mailbox
address as specified in section 3.4 of [](#RFC5322), for instance:

     admin@example.com
	 Barbara Beacon <b.beacon@example.org>

## message

The message meta field is used as template for link labels. The default value
is `{label}`.

## description

The description meta field is used as template for link descriptions. The
default value is `{description}`.

## institution

The institution meta field contains the name of an institution or publisher
responsible for the link targets and/or responsible for the BEACON dump.

## name

The name meta field contains a name or title of the BEACON dump and/or of
all of its targets. For instance if all links point to resources in a database,
the name meta field contains the name of the database.

## feed

The feed field contains an URL, where to download the BEACON dump from. In
addition to standard URL schemes, alternative established URI forms for
retrieval, such as magnet URIs MAY be allowed.

## about

The about field contains an URL of a website with additional information about
this BEACON link dump.

## timestamp

The timestamp field contains the date of last modification of the BEACON dump.
This date MUST conform to the `full-date` or to the `date-time` production rule
in [](#RFC3339). In addition, an uppercase `T` character MUST be used to
separate date and time, and an uppercase `Z` character MUST be present in the
absence of a numeric time zone offset. Some examples of valid timestamp values:

     2012-05-30
     2012-05-30T15:17:36+02:00
     2012-05-30T13:17:36Z

## update

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
BEACON dumps.

# Link fields

Each link in a serialized BEACON dump is given in form of up to four fields:

* id field,
* optional label field,
* optional description field,
* optional target field.

From these fields, combined with the BEACON dump's [meta fields](#meta-fields),
the full [link](#links) is constructed. All field values MUST be
[normalized](#string-normalization) before further processing. Missing
optional fields MUST be set to the empty string.  The full link is then
constructed as following:

The **link source** is constructed from the [prefix meta field](#prefix) URI
pattern by inserting the id field as identifier value, as defined in
[](#uri-patterns).

The **link target** is constructed from the [target meta field](#target) URI
pattern by inserting as identifier value, as defined in [](#uri-patterns):

* the target field, if the target field is not the empty string,
* the id field, otherwise.

Constructed link sources and link targets MUST be a syntactically valid URIs. A
client MUST ignore links with invalid URIs and it SHOULD give a warning.

The **link label** and the **link description** are constructed from the
[message meta field](#message) or the [description meta field](#description),
respectively, as following. The respective meta field value is used as string
pattern in which the following character sequences are replaced literally:

* `{id}` is replaced by the id field,
* `{label}` and `{hits}` is replaced by the label field (the latter is 
  supported for backwards compatibility),
* `{description}` is replaced by the description field,
* `{target}` is replaced by the target field,
* `{bracket}` is replaced by the left curly bracket character `{` (`%x7D`).

Additional encoding MUST NOT be applied to field values during this process.
The resulting string MUST be [normalized](#string-normalization) after
construction.

# Serialization

## BEACON text format

A BEACON text file is an UTF-8 encoded Unicode file [](#RFC3629), split into
lines by line breaks. The file consists of a set of lines with meta fields,
followed by a set of lines with link fields. A BEACON text file MAY begin with
an Unicode Byte Order Mark and it SHOULD end with a line break:

     BEACONTEXT  =  [ BOM ] *metaline [ LINEBREAK ] links [ LINEBREAK ]
	
     BOM         =  %xEF.BB.BF     ; Unicode UTF-8 Byte Order Mark

An empty line SHOULD be used to separate meta lines and link lines. The order
of meta lines and the order of link lines is irrelevant. 

A meta line specifies a [meta field](#meta-fields) and its value. Meta field
names are case insensitive and SHOULD be given in uppercase letters.

     metaline       =  "#" metafield ":" metavalue LINEBREAK

     metafield      =  "PREFIX" / "TARGET" / "LINK" / "MESSAGE"
	                /  "DESCRIPTION" / "INSTITUTION" / "NAME" / "ABOUT"
                    /  "CONTACT" / "FEED" / "TIMESTAMP" / "UPDATE"
 
     metavalue      =  LINESTRING

Each link is given on a link line with its id field, optionally follwed by
additional fields:

     links          =  link *( LINEBREAK link )

     link           =  ID 
	                /  ID VBAR XTARGET   ; only if TARGET looks like URI
                    /  ID VBAR XLABEL    ; only if LABEL not like URI
					/  ID VBAR LABEL [ VBAR DESCRIPTION ] VBAR [ TARGET ]

     VBAR           =  "|"                ; vertical bar

     DESCRIPTION    =  LINESTRING

     ID             =  *( CHAR - ( LINEBREAK / VBAR ) )

     TARGET         =  *( CHAR - ( LINEBREAK / VBAR ) )

     LABEL          =  *( CHAR - ( LINEBREAK / VBAR ) )

     XTARGET        =  SCHEME ":" LINESTRING

     XLABEL         =  LABEL - XTARGET


## BEACON XML format

A BEACON XML file is a valid XML file conforming to the following schema. The
file SHOULD be encoded in UTF-8 [](#RFC3629). The file MUST:

  * Begin with an opening `<beacon>` tag and end with a closing `</beacon>` tag.
  * Specify the default namespace `http://purl.org/net/example`.
  * Include an empty `<link/>` tag for each link.
  * Include the [link id](#link-fields) as XML attribute
    `id` of each `<link/>` element.

The file MAY further:

  * Specify [meta fields](#meta-fields) as XML attributes to the `<beacon>` tag.
  * Specify link fields `label`, `description`, and/or `target` as attributes to 
    the `<link>` element.

All attributes MUST be given in lowercase. An informal schema of BEACON XML is
given in [](#relax-ng-schema-for-beacon-xml).

To process BEACON XML, a complete and stream-processing XML parser, for
instance the Simple API for XML [](#SAX), is RECOMMENDED, in favor of
parsing with regular expressions or similar methods prone to errors.
Additional XML attributes of `<link>` elements and `<link>` elements without
`id` attribute SHOULD be ignored.

Note that in contrast to BEACON text format, link fields MAY include line
breaks, which are removed by whitespace normalization. Furthermore id field,
label field and target field MAY include a vertical bar, which is encoded as
`%7C` during construction the link.


# Security Considerations

...TODO... 

(URLs MAY be used to inject code and label/description MAY be used to
inject HTML?)

