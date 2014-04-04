# Mappings

An important use-case of BEACON is the creation of HTML links as described in
section [](#mapping-to-html). A link dump can also be mapped to an RDF graph
([](#mapping-to-rdf)) so BEACON provides a RDF serialization format for a
subset of RDF graphs with uniform links. 

## Mapping to RDF

The following namespace prefixes are used to refer to RDF properties and
classes from the RDF and RDFS vocabularies [](#RDF), the DCMI Metadata Terms
[](#DCTERMS), the FOAF vocabulary [](#FOAF), the VoID vocabulary [](#VOID), and
the RSS 1.0 Syndication Module [](#RSSSYND):

     rdf:     <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
     rdfs:    <http://www.w3.org/2000/01/rdf-schema#>
     dcterms: <http://purl.org/dc/terms/extent>
     foaf:    <http://xmlns.com/foaf/0.1/>
     void:    <http://rdfs.org/ns/void#>
     rssynd:  <http://web.resource.org/rss/1.0/modules/syndication/>

The blank node `:dump` denotes the URI of the link dump, the blank node
`:sourceset` denotes the URI of the source dataset, and the blank node
`:targetset` denotes the URI of the target dataset.

Note that literal values with language tags or datatypes are not supported when
mapping BEACON to RDF.

### Mapping links to RDF

Links with URI source and target identifiers can be mapped to at least one RDF
triple with:

* the source identifier used as subject IRI,
* the relation type used as predicate,
* the target identifiers used as object IRI.

As RDF is not defined on URIs but on URI references or IRIs, all URIs MUST be
transformed to an IRI by following the process defined in Section 3.2 of
[](#RFC3987). Applications MAY reject mapping link dumps with relation type
from the IANA link relations registry, in lack of official URIs. Another
valid solution is to extend the RDF model by using blank nodes as predicates.

### Mapping link annotations to RDF

Each link annotation SHOULD result in an additional RDF triple, unless its
value equals to the empty string. The additional triple is mapped with: 

* the target identifier used as subject IRI,
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

### Mapping link construction meta fields to RDF

Link construction meta fields ([](#link-construction-meta-fields)) are
primarily required for link construction ([](#link-construction)). Some of
these fields can further be mapped to RDF triples.

The **PREFIX** meta field ([](#prefix)) MAY be mapped to the RDF property
`void:uriSpace` or `void:uriRegexPattern` with `:sourceset` as RDF subject.

The **TARGET** meta field ([](#target) MAY be mapped to the RDF property
`void:uriSpace` or `void:uriRegexPattern` with `:targetset` as RDF subject.

The **RELATION** meta field ([](#relation)) is mapped to the RDF property
`void:linkPredicate` with `:dump` as RDF subject, if its value contains an URI.
Some examples of relation types and their mapping to RDF triples:

     #RELATION: http://www.w3.org/2002/07/owl#sameAs
     #RELATION: http://xmlns.com/foaf/0.1/isPrimaryTopicOf
     #RELATION: http://purl.org/spar/cito/cites
     #RELATION: describedby
     #RELATION: replies

     :dump void:linkPredicate <http://www.w3.org/2002/07/owl#sameAs> .
     :dump void:linkPredicate foaf:isPrimaryTopicOf .
     :dump void:linkPredicate <http://purl.org/spar/cito/cites> .

The **ANNOTATION** meta field ([](#annotation)), if given, contains an RDF
property for RDF triples between link target and link annotation. To give an
example, the following BEACON file

    #ANNOTATION: http://purl.org/dc/elements/1.1/format

    http://example.org/apples|sphere|http://example.org/oranges

implies the following RDF triple

    <http://example.org/oranges> dc:format "sphere" .

### Mapping link dump meta fields to RDF

Link dump meta fields ([](#link-dump-meta-fields)) describe properties of the
link dump, referred to as blank node `:dump` in the following. The following
RDF triples are always assumed when mapping link dumps to RDF:

     :dump a void:Linkset ; 
         void:subjectsTarget :sourceset ;
         void:objectsTarget :targetset .

The **DESCRIPTION** meta field is mapped to the `dcterms:description` RDF
property.  For instance 

    #DESCRIPTION: Mapping from ids to documents

can be mapped to

    :dump dcterms:description "Mapping from ids to documents" .

The **CREATOR** meta field is mapped to the `dcterms:creator` RDF property. The
creator is an instace of the class `foaf:Agent`. For instance

    #CREATOR: Bea Beacon

and

    #CREATOR: http://example.org/people/bea

can be mapped the the following RDF triples, respectively:

    :dump dcterms:creator "Bea Beacon" .
    :dump dcterms:creator [ a foaf:Agent ; foaf:name "Bea Beacon" ] .

    :dump dcterms:creator <http://example.org/people/bea> .
    <http://example.org/people/bea> a foaf:Agent .

The **CONTACT** meta field ([](#contact)) is mapped to the `foaf:mbox` and to
the `foaf:name` RDF properties.  For instance

     #CONTACT: admin@example.com

can be mapped to

     :dump dcterms:creator [
         foaf:mbox <mailto:admin@example.com>
     ] .

and
   
     #CONTACT: Bea Beacon <bea@example.org>

can be mapped to

     :dump dcterms:creator [
         foaf:name "Bea Beacon" ;
         foaf:mbox <mailto:bea@example.org>
     ] .

The **HOMEPAGE** meta field ([](#homepage)) is mapped to the `foaf:homepage`
RDF property. For instance 

    #HOMEPAGE: http://example.org/about.html

can be mapped to

    :dump foaf:homepage <http://example.org/about.html> .

The **FEED** meta field ([](#feed)) corresponds to the `void:dataDump` RDF
property. For instance

    #FEED: http://example.com/beacon.txt

can be mapped to 

    :dump void:dataDump <http://example.com/beacon.txt> .

The **TIMESTAMP** meta field ([](#timestamp) corresponds to the
`dcterms:modified` RDF property.  For instance the following valid timestamps

     #TIMESTAMP: 2012-05-30
     #TIMESTAMP: 2012-05-30T15:17:36+02:00
     #TIMESTAMP: 2012-05-30T13:17:36Z

can be mapped to the following RDF triples, respectively:

     :dump dcterms:modified "2012-05-30"
     :dump dcterms:modified "2012-05-30T15:17:36+02:00"
     :dump dcterms:modified "2012-05-30T13:17:36Z"

The **UPDATE** meta field ([](#update)) corresponds to the
`rssynd:updatePeriod` RDF property. For instance this field

    #UPDATE: daily

specifies a daily update, expressible in RDF as

    :dump rssynd:updatePeriod "daily" .

### Mapping dataset meta fields to RDF

Dataset meta fields ([](#dataset-meta-fields)) are mapped to subjects and
objects of RDF triples to describe the source dataset and target dataset,
respectively.

The following triples are always assumed in mappings of link dumps to RDF:

     :sourceset a void:Dataset .
     :targetset a void:Dataset .

The **SOURCESET** meta field ([](#sourceset)) replaces the blank node
`:sourceset`, if given.

The **TARGETSET** meta field ([](#sourceset)) replaces the blank node
`:targetset`, if given.

The **NAME** meta field ([](#name)) is mapped to the RDF property
`dcterms:title` with `:targetset` as RDF subject. For instance the field value
"ACME documents", expressible in BEACON format as

    #NAME: ACME documents

can be mapped to this RDF triple:

    :targetset dcterms:title "ACME documents" .

The **INSTITUTION** meta field ([](#institution)) is mapped to the RDF property
`dcterms:publisher`. For instance the field value "ACME", expressible in BEACON
format as

    #INSTITUTION: ACME

can be mapped to this RDF triple:

    :targetset dcterms:publisher "ACME" .

A field value starting with `http://` or `https://` is interpreted as URI
instead of string. For instance

    #INSTITUTION: http://example.org/acme/

can be mapped to this RDF triple:

    :targetset dcterms:publisher <http://example.org/acme/> .

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


