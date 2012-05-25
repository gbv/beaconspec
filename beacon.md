% BEACON link dump format
% Jakob Voß

# Introduction

## Motivation

...TODO...

## Overview

A BEACON link dump consists of:

* A set of [links](#links), each derived from a set of [link fields](#link-fields).
* a set of [meta fields](#meta-fields).

The link dump can be serialized in [BEACON text format](#beacon-text-format)
and in [BEACON XML format](#beacon-xml-format).

## Notational Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in [](#RFC2119).

The formal grammar rules in this document are to be interpreted as described in
[](#RFC4234).


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

Name and description are Unicode strings that annotate a link, as described
in [](#link-annotation).


# Meta fields

...TODO...

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

## feed

...TODO...

## contact

...TODO...

The contact SHOULD be a mailbox address as specified in section 3.4 of [](#RFC2882).

## description

...TODO... (needed?)

## institution

...TODO... (publishing institution or institution repsonsible for the link targets)...

## ISIL

...TODO... (should be dropped)

## timestamp

...TODO...

## update

...TODO...

## revisit

...TODO... (needed?)


# Link fields

Each link in a serialized BEACON dump is given in form of up to four fields:

* id field,
* optional label field,
* optional description field,
* optional target field.

Source, target, name, and description of a [link](#links) are derived from
these fields combined with the BEACON dump's [meta fields](#meta-fields):

## Link annotation

...(TODO)...

In HTML, `label` corresponds to the textual content and `description`
corresponds to the `title` attribute an HTML link.

In RDF...


# BEACON text format

A BEACON text file is an UTF-8 encoded file, separated in lines. A line break
is ...TODO...


# BEACON XML format

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
	>
		<link>...</link>
		<link target="">...</link>
	  	<link label="" description="..." target="...">...</link>
	</beacon>

A stream-processing XML parser, such as SAX conforming processor [SAX](), is
RECOMMENDED to process BEACON XML. Applications SHOULD NOT try to parse BEACON
XML with regular expressions or similar methods instead of a full XML parser.

