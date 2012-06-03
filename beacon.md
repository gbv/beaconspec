% BEACON link dump format
% Jakob Voß

# Introduction

## Overview

BEACON is a data interchange format for large numbers of uniform links.  A
BEACON link dump consists of:

* a set of [links](#links), each derived from a set of 
  [link fields](#link-fields),
* a set of [meta fields](#meta-fields).

All links typically share a common URI pattern for source and for target,
respectively. For instance a BEACON dump could consist of links between two
domains that use different local identifier systems:

    http://example.org/{ID1} ---> http://example.com/{ID2}

A special case is the use of the same local identifier that can be used to
construct both, source and target of a link, for instance:

    http://example.org/{ID}  ---> http://example.org/?id={ID}&action=view

A BEACON link dump can be serialized in a condense [BEACON text
format](#beacon-text-format) and in [BEACON XML format](#beacon-xml-format).

## Notational Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be
interpreted as described in [](#RFC2119).

The formal grammar rules in this document are to be interpreted as described in
[](#RFC4234).

## Whitespace Normalization 

A Unicode string is normalized according to this specification, by stripping
leading and trailing whitespace and by replacing sequences of whitespace
characters (`U+0020 | U+0009 | U+000D | U+000A`) by a single space (`U+0020`)
[](#Unicode).

## IRI patterns

An IRI pattern in this specification is a sequence of Unicode characters that
SHOULD contain the expression `{ID}`. To support compatibility with
[](#RFC6570), the expression `{+ID}` MAY be used instead and it MUST be treated
equal to `{ID}`. If the sequence `{ID}` (or `{+ID}`) is not given, the pattern
is processed as if the sequence was appended. For this reason the following IRI
patterns are equal:

     http://example.org/
	 http://example.org/{ID}
	 http://example.org/{+ID}

An IRI pattern MUST allow its conversion to an absolute IRI [](#RFC3987) by
replacing all occurrences of `{ID}` with a selected sequence of Unicode
characters. For instance the string `:{ID}` is not a valid IRI pattern because
it cannot become a valid IRI. Further restrictions MAY be imposed based on
syntax rules of the patterns IRI scheme.

# Links

A link in BEACON is a typed connection between two resources that are
identified by Internationalised Resource Identifiers (IRIs), and
is compromised of:

* a source IRI,
* a link relation type, 
* a target IRI
* an optional label,
* an optional description.

In the common case, source IRI and target IRI will also be URIs [](#RFC3986). A
link relation type is either a registered link type from the IANA link
relations registry or an URI that uniquely identifies the relation type, as
defined in [](#RFC5988). Link label and link description are normalized Unicode
strings that annotate a link [](#Unicode). The meaning of this annotations is
not defined in this specification, but guidelines are given in
[](#interpreting-beacon-links).

A BEACON link dump is an annotated set of links with identical link type. The
default link type is the URI `http://www.w3.org/2000/01/rdf-schema#seeAlso`.

# Meta fields

A BEACON dump MAY be annotated with a set of meta fields. Each meta field
is identified by its name, build of lowercase letters `a-z`. Valid fields
are listed in the following. Additional meta fields, not defined in this
specification SHOULD be ignored. All meta field values MUST be normalized
Unicode strings [](#whitespace-normalization).


## prefix

The prefix field specifies an IRI pattern that is used to construct link
sources. The name `prefix` was choosen to keep backwards compatibility with
existing BEACON dumps.

## target

The target field specifies an IRI pattern to construct link targets. 

## link

The link field specifies the link type for all links in a BEACON dump. In
[BEACON text format](#beacon-text-format) the link MAY be specified enclosed in
angle brackets if it is an URI, so the following BEACON text link fields are
equal:

    #LINK: http://www.w3.org/2002/07/owl#sameAs
    #LINK: <http://www.w3.org/2002/07/owl#sameAs>

## contact

The contact field contains an email address or similar contact information to
reach the maintainer of the BEACON dump.  The contact SHOULD be a mailbox
address as specified in section 3.4 of [](#RFC5322).

Examples:

    admin@example.com
	Barbara Beacon <b.beacon@example.org>


## message

The message meta field is used as template or as default value for [link
labels](#link-label).

## description

The description meta field is used as template or as default value for [link
descriptions](#link-description).

## institution

The institution meta field contains the name of an institution or publisher
responsible for the link targets and/or responsible for the BEACON dump.

## name

The name meta field contains a name or title of the BEACON dump and/or of
all of its targets. For instance if all links point to resources in a database,
the name meta field contains the name of the database.

## feed

The feed field contains an URL, conforming to [](#RFC3986), where to download
the BEACON dump from.

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
the full [link](#links) is derived. All field values MUST be
[normalized](#whitespace-normalization). The full link is derived as following:

## link source

The link source is the id link field, prepended by the [prefix meta field](#prefix),
if the latter is specified. The resulting link source MUST be a valid IRI.

## link target

The link target is constructed based on

* the id field,
* the target field,
* the [target meta field](#target)

with the following cases:

* If the target field is specified, then:

  * If the target meta field is specified then the target field is inserted
    as `{ID}` parameter into the target meta field to get the link target.

  * If the target meta field is not specified, 
    then the link target is the target field.

* If the target field is not specified and the target meta field is specified,
  then the id field is inserted as `{ID}` parameter to get the link target.

* If neither the target field nor the target meta field are specified, 
  then the link target is the id field.

In all cases the resulting link target MUST be a valid IRI. Any other case (no
id field, target meta field with `{TARGET}` parameter but no target field etc.)
is an error. A client MUST ignore such links and SHOULD give a warning.


## link label

The link label is derived from the label field and the [message meta
field](#message) as following:

* If the message meta field contains the substring `{label}` and the label
  field is not the empty string, then the substring `{label}` is replaced by 
  the label field to get the link label.
* If otherwise the labeln field is not the empty string, the link 
  label equals to the label field.
* Otherwise the link label equals to the message meta field.

The resulting string MUST be [normalized](#whitespace-normalization). A missing
link label equals to the empty string. 


## link description

The link description is derived from the description field, from the label field,
and from the [description meta field](#description) as following:

* If the description meta field contains the substring `{label}` and the label
  field is not the empty string, then the substring `{label}` is replaced by 
  the label field to get the link description.
* If otherwise the description field is not the empty string, the link 
  description equals to the description field.
* Otherwise the link description equals to the description meta field.

The resulting string MUST be [normalized](#whitespace-normalization). A missing
link description equals to the empty string. 


# BEACON serialization

## BEACON text format

A BEACON text file is an UTF-8 encoded Unicode file [](#RFC3629), split into
lines by line breaks. A line break is any combination of the characters
`U+000A` and `U+000D`. The file consists of a set of lines with meta fields
(meta lines), followed by a set of lines with links (link lines). An empty line
SHOULD be used to separate meta lines and link lines. The order of meta lines
and the order of link lines is irrelevant.

### Meta lines

...

### Link lines

...

## BEACON XML format

A BEACON XML file is a valid XML file conforming to the following schema. The
file SHOULD be encoded in UTF-8 [](#RFC3629). The file MUST:

  * Begin with an opening `<beacon>` tag and end with a closing `</beacon>` tag.
  * Specify the default namespace `http://purl.org/net/example`.
  * Include an empty `<link/>` tag for each link.
  * Include the [link id](#link-fields) as XML attribute `id` of each `<link/>` 
    element.

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


# Security Considerations

...TODO... 

(URLs MAY be used to inject code and label/description MAY be used to
inject HTML?)

