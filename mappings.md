# Mapping to RDF

A link dump can be mapped to an RDF graph as described below.  Note that BEACON
cannot express arbitrary RDF graphs, e.g. language tags and datatypes are not
supported at all. Neither can BEACON express URIs with character sequences
`%7C`, `%0A`, `%0D`, or any other percent-encoded character not included in the
list of allowed characters ([](#allowed-characters)) because the unencoded
characters of this sequences are not allowed in link tokens.

## Naming conventions

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
`:targetset` denotes the URI of the target dataset. Source datatset and target
datatset can also be given an absolute URI with meta fields `SOURCESET` and
`TARGETSET`, respectively ([](#meta-fields-for-datasets)).

## Links in RDF

Links ([](#links)) with syntactically valid URIs as source and target
identifiers and URI relation types can be mapped to at least one RDF triple
with:

* the source identifier used as subject IRI,
* the relation type used as predicate,
* the target identifiers used as object IRI.

As RDF is not defined on URIs but on URI references or IRIs, all URIs MUST be
transformed to an IRI by following the process defined in Section 3.2 of
[](#RFC3987). 

## Link annotations in RDF

Each non-empty link annotation SHOULD result in an additional RDF triple with:

* the target identifier used as subject IRI,
* the `ANNOTATION` meta field used as predicate,
* the link annotation value used as literal object.

Applications MAY use a predefined URI as link annotation or process the link
annotation by other means. For instance annotations could contain additional
information about a link such as its provenience, date, or probability
(reification).

Typical use cases of link annotations include specification of labels and a
"number of hits" at the target dataset. For instance the following file in
BEACON format ([](#beacon-format)):

     #PREFIX: http://example.org/
     #TARGET: http://example.com/
     #RELATION: http://xmlns.com/foaf/0.1/primaryTopic
     #ANNOTATION: http://purl.org/dc/terms/extent

     abc|12|xy

is mapped to the following RDF triples:

     <http://example.org/abc> foaf:primaryTopic <http://example.com/xy> .
     <http://example.com/xy> dcterms:extent "12" .

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
properties of the link dump, referred to as blank node `:dump` in the
following. The following RDF triples are always assumed when mapping link dumps
to RDF:

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

can be mapped to

    :dump dcterms:creator <http://example.org/people/bea> .
    <http://example.org/people/bea> a foaf:Agent .

A field value starting with `http://` or `https://` is interpreted as URI
instead of string. For instance

    #CREATOR: http://example.org/people/bea

can be mapped to

    :dump dcterms:creator "Bea Beacon" .
    :dump dcterms:creator [ a foaf:Agent ; foaf:name "Bea Beacon" ] .

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
`rssynd:updatePeriod` RDF property. For instance a daily update

    #UPDATE: daily

can be mapped to

    :dump rssynd:updatePeriod "daily" .

## Meta fields for datasets in RDF

Meta fields for the datasets ([](#meta-fields-for-datasets)) are mapped to
subjects and objects of RDF triples to describe the source dataset and target
dataset, respectively.

The following triples are always assumed in mappings of link dumps to RDF:

     :sourceset a void:Dataset .
     :targetset a void:Dataset .

The **SOURCESET** meta field ([](#sourceset)) replaces the blank node
`:sourceset`.

The **TARGETSET** meta field ([](#sourceset)) replaces the blank node
`:targetset`.

The **NAME** meta field ([](#name)) is mapped to the RDF property
`dcterms:title` with `:targetset` as RDF subject. For instance the field value
"ACME documents", expressible in BEACON format as

    #NAME: ACME documents

can be mapped to

    :targetset dcterms:title "ACME documents" .

The **INSTITUTION** meta field ([](#institution)) is mapped to the RDF property
`dcterms:publisher`. For instance the field value "ACME", expressible in BEACON
format as

    #INSTITUTION: ACME

can be mapped

    :targetset dcterms:publisher "ACME" .

A field value starting with `http://` or `https://` is interpreted as URI
instead of string. For instance

    #INSTITUTION: http://example.org/acme/

can be mapped

    :targetset dcterms:publisher <http://example.org/acme/> .


