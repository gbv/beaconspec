REVSHRT = $(shell git log -1 --format="%h" beacon.md)
REVHTML = beacon-$(REVSHRT).html

all: html txt

HTML = beacon.html
TXT	 = beacon.txt

html: $(HTML)
txt: $(TXT)

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

appendices.xml: appendices.md
	pandoc -t docbook -s $< | xsltproc --nonet pandoc2rfc/transform.xsl - > $@

beacon.txt: beacon.md appendices.xml
	./pandoc2rfc/pandoc2rfc -x pandoc2rfc/transform.xsl -T $<
	mv draft.txt $@

beacon.html: beacon.md appendices.xml
	./pandoc2rfc/pandoc2rfc -x pandoc2rfc/transform.xsl -H $<
	mv draft.html $@

clean:
	rm -f $(HTML) $(TXT) appendices.xml beacon-*.html draft.xml

new: clean all

.PHONY: clean all new
