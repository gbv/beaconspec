# Mapping to RDF

A link dump can be mapped to an RDF graph as described in this section. The
mapping excludes all links with one of source identifier, target identifier,
relation type not being a valid URI.

All URIs MUST be transformed to IRIs as defined in Section 3.2 of [](#RFC3987).

Examples link dumps mapped to RDF is given in [](#mapping-examples).

## Naming conventions

The following namespace prefixes are used to refer to RDF properties and
classes from the RDF and RDFS vocabularies [](#RDF), the DCMI Metadata Terms
[](#DCTERMS), the FOAF vocabulary [](#FOAF), the VoID vocabulary [](#VOID), and
the Hydra Core Vocabulary [](#Hydra), the RSS 1.0 Syndication Module
[](#RSSSYND):

     rdf:     <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
     rdfs:    <http://www.w3.org/2000/01/rdf-schema#>
     dcterms: <http://purl.org/dc/terms/extent>
     foaf:    <http://xmlns.com/foaf/0.1/>
     void:    <http://rdfs.org/ns/void#>
     hydra:   <http://www.w3.org/ns/hydra/core#>
     rssynd:  <http://web.resource.org/rss/1.0/modules/syndication/>

The blank node `:dump` denotes the the link dump, the blank node `:sourceset`
denotes the the source dataset, and the blank node `:targetset` denotes the the
target dataset. Source datatset and target datatset can also be given an
absolute IRI with meta fields `SOURCESET` and `TARGETSET`, respectively
([](#meta-fields-for-datasets)).

The following RDF triples can always be assumed when mapping link dumps to RDF:

     :dump a void:Linkset, hydra:Collection ;
         void:subjectsTarget :sourceset ;
         void:objectsTarget :targetset .

     :sourceset a void:Dataset .
     :targetset a void:Dataset .

## Links in RDF

Links ([](#links)) with source identifier, target identifier, and relation type
being valid URIs can be mapped to at least one RDF triple with:

* the source identifier used as subject IRI,
* the relation type used as predicate,
* the target identifiers used as object IRI.

The total number of mappable links in a link dump SHOULD result in an
additional RDF triple whith `COUNT` being the number of links:

     :dump a hydra:totalItems COUNT .

## Link annotations in RDF

Each non-empty link annotation SHOULD result in an additional RDF triple with:

* the target identifier used as subject IRI,
* the `ANNOTATION` meta field used as predicate,
* the link annotation value used as literal object.

Applications MAY use a predefined IRI as link annotation or process the link
annotation by other means, for instance for provenience and versioning of
links. Applications MAY assign a default language tag or datatype to all
literal objects derived from link annotations.

Typical use cases of link annotations include specification of labels and a
"number of hits" at the target dataset. For instance the following file in
BEACON format ([](#beacon-format)):

     #PREFIX: http://example.org/
     #TARGET: http://example.com/
     #RELATION: http://xmlns.com/foaf/0.1/primaryTopic
     #ANNOTATION: http://purl.org/dc/terms/extent

     abc|12|xy

can be mapped to

     <http://example.org/abc> foaf:primaryTopic <http://example.com/xy> .
     <http://example.com/xy> dcterms:extent "12" .

The total number of mappable links and link annotations in a link dump SHOULD
result in an additional RDF triple whith `TRIPLES` being the sum of both
numbers:

     :dump a void:triples TRIPLES .


## Meta fields for link construction in RDF

All meta fields for link construction ([](#meta-fields-for-link-construction))
except for **MESSAGE** can be mapped to RDF triples.

The **PREFIX** meta field ([](#prefix)) MAY be mapped to the RDF property
`void:uriSpace` or `void:uriRegexPattern` with `:sourceset` as RDF subject.

The **TARGET** meta field ([](#target) MAY be mapped to the RDF property
`void:uriSpace` or `void:uriRegexPattern` with `:targetset` as RDF subject.

The **RELATION** meta field ([](#relation)), if its value contains an URI, is
mapped to the RDF property `void:linkPredicate` with `:dump` as RDF subject.

The **ANNOTATION** meta field ([](#annotation)) is used to map link annotations
to RDF ([](#link-annotations-in-rdf)) unless the **RELATION** meta field
contains an URI template.

## Meta fields for link dumps in RDF

Meta fields for link dumps ([](#meta-fields-for-link-dumps)) describe
properties of the link dump.

The **DESCRIPTION** meta field corresponds to the `dcterms:description` RDF
property.  For instance

    #DESCRIPTION: Mapping from ids to documents

can be mapped to

    :dump dcterms:description "Mapping from ids to documents" .

The **CREATOR** meta field corresponds to the `dcterms:creator` RDF property.
The creator can be given as string or as instace of the class `foaf:Agent`. For
instance

    #CREATOR: Bea Beacon

can be mapped to

    :dump dcterms:creator "Bea Beacon" .
    :dump dcterms:creator [ a foaf:Agent ; foaf:name "Bea Beacon" ] .

A field value starting with `http://` or `https://` is interpreted as URI
instead of string. For instance

    #CREATOR: http://example.org/people/bea

can be mapped to

    :dump dcterms:creator <http://example.org/people/bea> .
    <http://example.org/people/bea> a foaf:Agent .

The **CONTACT** meta field ([](#contact)) corresponds to the `foaf:mbox` and
`foaf:name` RDF properties.  For instance

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

The **HOMEPAGE** meta field ([](#homepage)) corresponds to the `foaf:homepage`
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
`rssynd:updatePeriod` RDF property. For instance a daily update

    #UPDATE: daily

can be mapped to

    :dump rssynd:updatePeriod "daily" .

## Meta fields for datasets in RDF

Meta fields for the datasets ([](#meta-fields-for-datasets)) are mapped to
subjects and objects of RDF triples to describe the source dataset and target
dataset, respectively.

The **SOURCESET** meta field ([](#sourceset)) replaces the blank node
`:sourceset`.

The **TARGETSET** meta field ([](#sourceset)) replaces the blank node
`:targetset`.

The **NAME** meta field ([](#name)) is mapped to the RDF property
`dcterms:title` with `:targetset` as RDF subject. For instance the field value
"Wikipedia", expressible in BEACON format as

    #NAME: Wikipedia

can be mapped to

    :targetset dcterms:title "Wikipedia" .

The **INSTITUTION** meta field ([](#institution)) corresponds to the RDF
property `dcterms:publisher`. For instance the field value "Wikimedia
Foundation", expressible in BEACON format as

    #INSTITUTION: Wikimedia Foundation

can be mapped

    :targetset dcterms:publisher "Wikimedia Foundation" .

A field value starting with `http://` or `https://` is interpreted as URI
instead of string. For instance

    #INSTITUTION: http://viaf.org/viaf/137022054/

can be mapped to

    :targetset dcterms:publisher http://viaf.org/viaf/137022054/ .

## Limitations and applications

BEACON format ([](#beacon-format)) can be used as serialization format for RDF
graphs where all parts of RDF triples are IRIs and IRIs do not contain the
character sequences `%7C`, `%0A`, `%0D`, or any other percent-encoded character
not included in the list of allowed characters ([](#allowed-characters)). This
limitation applies because the disallowed character sequences would need to
result from characters not allowed in link tokens of BEACON format.

BEACON link dumps in particular can be used to express Linked Data Fragments
[](#LDF) which also consist of a set of links sharing a common pattern, and
additional metadata.
