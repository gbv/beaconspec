REVSHRT = $(shell git log -1 --format="%h" beacon.md)
REVHTML = beacon-$(REVSHRT).html

all: html txt

HTML = beacon.html
TXT  = beacon.txt

html: $(HTML)
txt: $(TXT)

.md.xml:
	pandoc -t docbook -s $< | xsltproc --nonet pandoc2rfc/transform.xsl - > $@

# requires xml2rfc >=2.5.1 (also available via https://pypi.python.org/pypi/xml2rfc/)

$(TXT): beacon.xml appendices.xml mappings.xml security.xml template.xml
	xml2rfc template.xml -o $@ --text
$(HTML): beacon.xml appendices.xml mappings.xml security.xml template.xml
	xml2rfc template.xml -o $@ --html

revision: $(HTML)
	cp $(HTML) $(REVHTML)

website: $(HTML) $(TXT)
	@cp $(HTML) new.html
	@cp $(TXT) new.txt
	git checkout gh-pages
	@cp new.html $(HTML)
	@cp new.txt $(TXT)
	git add $(HTML) $(TXT)
	git commit -m "added revision $(REVSHRT)"
	git checkout master

clean:
	rm -f $(HTML) $(TXT) appendices.xml beacon.xml beacon-*.html new.*

new: clean all

.SUFFIXES: .md .xml
.PHONY: clean all new
