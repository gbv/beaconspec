NAME=beacon
CSS=stylesheet.css
GITHUBASE=https://github.com/gbv/beaconspec/
RFC=DISPLAY= sh pandoc2rfc/xml-wrap rfctemplate.xml

MARKDOWN=${NAME}.md
HTML=${NAME}.html
XML=${NAME}.xml
TXT=${NAME}.txt

REVHASH=$(shell git log -1 --format="%H" ${MARKDOWN})
REVDATE=$(shell git log -1 --format="%ai" ${MARKDOWN})
REVSHRT=$(shell git log -1 --format="%h" ${MARKDOWN})

REVHTML=${NAME}-${REVSHRT}.html

html: ${HTML}
xml: ${XML}
txt: ${TXT}

revision: ${HTML}
	cp ${HTML} ${REVHTML}

#website: revision
#	git checkout gh-pages
#	echo '<meta HTTP-EQUIV="REFRESH" content="0; url=${REVHTML}">' > ${HTML}
#	git add ${HTML} ${REVHTML}
#	git commit -m "added revision ${REVSHRT}"
#	git checkout master

middle.xml: ${MARKDOWN} pandoc2rfc/transform.xsl
	pandoc -t docbook -s $< | xsltproc --nonet pandoc2rfc/transform.xsl - > $@

appendices.xml: appendices.md  pandoc2rfc/transform.xsl
	pandoc -t docbook -s $< | xsltproc --nonet pandoc2rfc/transform.xsl - > $@

draft.xml: rfctemplate.xml middle.xml appendices.xml
	perl pandoc2rfc/xml-single rfctemplate.xml > draft.xml


${TXT}: draft.xml rfctemplate.xml
	${RFC} $@

${HTML}: draft.xml rfctemplate.xml
	${RFC} $@

clean:
	rm -f ${HTML} ${NAME}-*.html ${XML} ${TXT} draft.*

all: html txt

new: clean all

.PHONY: clean all new
