# Security Considerations

Programs should be prepared for malformed and malicious content when parsing
BEACON files, when constructing links from link tokens, and when mapping links
to RDF or HTML. Possible attacks of parsing contain broken UTF-8 and buffer
overflows. Link construction can result in unexpectedly long strings and
character sequences that may be harmless when analyzed as parts. Most notably,
BEACON data may store strings containing HTML and JavaScript code to be used
for cross-site scripting attacks on the site displaying BEACON links.
Applications should therefore escape or filter accordingly all content with
established libraries, such as Apache Escape Utils.
