# Interpreting BEACON links

The interpretation of links in a BEACON dump is not restricted to a specific
format. The most common use cases are HTML links and RDF triples.

## HTML links

A BEACON link can be mapped to a HTML link (`<a>` element) as following:

* The link target corresponds to the `href` attribute.
* The link label corresponds to the textual content.
* The link description corresponds to the `title` attribute.

The link source can be interpreted as the website URL which a HTML link is
included at.

Example:

    ...|example|sample site|http://example.org

    <a href="http://example.org" title="sample site">example</a>

A client may also ignore link label and link description but use the meta
fields ... and ... instead (TODO).


## RDF triples

If link type is an URI, each link in a BEACON dump maps to an RDF triple
with 

* link source as RDF subject,
* link type as RDF property,
* link target as RDF object.

Link label and link description MAY result in additional triples with each of
name and description as literal value RDF object. The final intepretation of
these link annotations, however, is out of the scope of this specification.
