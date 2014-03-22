REVSHRT = $(shell git log -1 --format="%h" beacon.md)
REVHTML = beacon-$(REVSHRT).html

all: html txt

HTML = beacon.html
TXT  = beacon.txt

html: $(HTML)
txt: $(TXT)

.md.xml:
	pandoc -t docbook -s $< | xsltproc --nonet pandoc2rfc/transform.xsl - > $@

# requires the "new" python-xml2rfc

$(TXT): beacon.xml appendices.xml template.xml
	xml2rfc template.xml -f $@ --text
$(HTML): beacon.xml appendices.xml template.xml
	xml2rfc template.xml -f $@ --html

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
	rm -f $(HTML) $(TXT) appendices.xml beacon.xml beacon-*.html

new: clean all

.SUFFIXES: .md .xml
.PHONY: clean all new
