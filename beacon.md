% BEACON link dump format
% Jakob Voß

# Introduction

BEACON was developed as minimalistic format for distribution of large number
of uniform links between information resources. A typical use case is the
expression of a linking tables that map source URLs to target URLs with stable
URL prefix and local identifiers as part of the URL:

    http://example.com/{sourceID} ---> http://example.org/{targetID}

With BEACON one can express these links in a very condense form. Each
link in BEACON text format is a tuple of local identifiers: 

    {sourceID}|{targetID}

If `{sourceID}` and `{targetID}` are equal the link only consists of this id:

    {sourceID}

For easier processing this form can also be mapped to BEACON XML format.


## Notational Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be
interpreted as described in [](#RFC2119).

The formal grammar rules in this document are to be interpreted as described in
[](#RFC4234).


## Overview

A BEACON link dump consists of:

* a set of [links](#links), each derived from a set of 
  [link fields](#link-fields),
* a set of [meta fields](#meta-fields).

A BEACON link dump can be serialized in [BEACON text
format](#beacon-text-format) and in [BEACON XML format](#beacon-xml-format).


# Links

In this specification a link is a typed connection between two resources that
are identified by Internationalised Resource Identifiers (IRIs) [](#RFC3987),
and is compromised of:

* A source IRI,
* a link relation type, 
* a target URI
* optionally, name and description.

Note that in the common case, source IRI and target IRI will also be URIs
[](#RFC3986). A link relation type is either a registered link type from the
IANA link relations registry or an URI that uniquely identifies the relation
type, as defined in [](#RFC5988).

A BEACON link dump is an annotated set of links with identical link type. The
default link type is the URI `http://www.w3.org/2000/01/rdf-schema#seeAlso`.
In the common case, all source IRIs, or all target URIs, or both respectively
begin with a common prefix that is used for abbreviation.

Name and description are Unicode strings that annotate a link. The meaning of
this annotations is not specified in this document but guidelines are given in
[](#interpreting-beacon-links).

# Meta fields

A BEACON dump MAY be annotated with a set of meta fields. Each meta field
is identified by its name, build of lowercase letters `a-z`. Valid fields
are listed in the following. Additional meta fields, not defined in this
specification SHOULD be ignored.

## prefix

The prefix field specifies a prefix that is prepended to [link
ids](#link-fields) to construct link sources.

## target

The target field specifies an URI pattern to construct link targets. The URI
pattern SHOULD include an URI parameter that is either `{ID}` or `{TARGET}`. If
no URI parameter is included, the parameter `{ID}` is appended to the URI
pattern, so the following target fields are equal:

     http://example.org/
	 http://example.org/{ID}

## link

The link field specifies the link type for all links in a BEACON dump. In
[BEACON text format](#beacon-text-format) the link MAY be specified enclosed in
angle brackets if it is an URI, so the following BEACON text link fields are
equal:

    #LINK: http://www.w3.org/2002/07/owl#sameAs
    #LINK: <http://www.w3.org/2002/07/owl#sameAs>

## message

...TODO...

## contact

The contact field contains an email address or similar contact information to
reach the maintainer of the BEACON dump.  The contact SHOULD be a mailbox
address as specified in section 3.4 of [](#RFC5322).

Examples:

    admin@example.com
	Barbara Beacon <b.beacon@example.org>

## description

...TODO... (needed?)

## institution

...TODO... (publishing institution or institution repsonsible for the link targets)...

## feed

The feed field contains an URL, conforming to [](#RFC3986), where to download
the BEACON dump from.

## timestamp

The timestamp field contains the date of last modification of the BEACON dump.
This date MUST conform to the `full-date` or to the `date-time` production rule
in [](#RFC3339). In addition, an uppercase `T` character MUST be used to
separate date and time, and an uppercase `Z` character MUST be present in the
absence of a numeric time zone offset.

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
time they are accessed. The value `never` should be used to describe archived
BEACON dumps.


# Link fields

Each link in a serialized BEACON dump is given in form of up to four fields:

* *id field*,
* optional *label field*,
* optional *description field*,
* optional *target field*.

Form these fields, combined with the BEACON dump's [meta fields](#meta-fields),
the source, target, name, and description of a [link](#links) is derived:

## link source

The link source is the id link field, prepended by the [prefix meta field](#prefix),
if the latter is specified. The resulting link source MUST be a valid IRI.

## link target

The link target is constructed based on

* the id field,
* the target field,
* the [target meta field](#target)

with the following cases:

* If neither target field nor target meta field are specified, then the 
  link target is the id field.
* If target field is specified and target meta field is not specified 
  with `{TARGET}` URI template parameter, then the link target is the target field.
* If target field is specified and target meta field is specified with
  a `{TARGET}` URI template parameter, then the target field is inserted as 
  `{TARGET}` parameter to get the link target.
* If target field is not specified and target meta field is specified,
  then the id field is inserted as `{ID}` parameter to get the link target.

In all cases the resulting link target MUST be a valid IRI. Any other case (no
id field, target meta field with `{TARGET}` parameter but no target field etc.)
is an error. A client MUST ignore such links and SHOULD give a warning.

## link name

...TODO... (based in message meta field?)

## link description

...TODO... (based in message meta field?)


# BEACON serialization

## BEACON text format

A BEACON text file is an UTF-8 encoded file, separated in lines. A line break
is ...TODO...

...additional meta field `#FORMAT: BEACON`...

## BEACON XML format

A BEACON XML file is a valid XML file conforming to the following schema. The
file should be UTF-8 encoded. The file must:

  * Begin with an opening `<beacon>` tag and end with a closing `</beacon>` tag.
  * Specify the namespace `http://example.org/to-be-defined` within the `<beacon>` tag.
  * Include a non-empty `<link>` tag for each link.
  * Include the [link id](#link-fields) as text content in the `<link>` element for each link.

The file may further:

  * Specify meta fields as XML attributes to the `<beacon>` tag.
  * Specify label, description, and/or target of a link as attributes to the `<link>` element.

Meta fields attributes MUST be given in lowercase only. Optional links
attribute names MUST be one of `label`, `description`, and `target` only.

An example of a BEACON XML file (TODO):

    <?xml version="1.0" encoding="UTF-8"?>
	<beacon xmlns="..."
			link="..."
	  		target="..."
			prefix="http://..."
	>
		<link>...</link>
		<link target="">...</link>
	  	<link label="" description="..." target="...">...</link>
	</beacon>

A stream-processing XML parser, such as SAX conforming processor [SAX](), is
RECOMMENDED to process BEACON XML. Applications SHOULD NOT try to parse BEACON
XML with regular expressions or similar methods instead of a full XML parser.

# Security Considerations

...TODO... (URLs may be used to inject code and label/description may be used to
inject HTML?)

