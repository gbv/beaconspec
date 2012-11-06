# Simple awk script to convert BEACON format to N-Triples
# First published at https://gist.github.com/gists/1438869
# hereby put into public domain
BEGIN {
    FS     = "|"
    link   = "http://www.w3.org/2000/01/rdf-schema#seeAlso"
    header = 1
}
{
    if (header && $1 ~ /^(\xef\xbb\xbf)?[ \t]*#/) { # may contain UTF-8 BOM!
        sub(/^[ \t]*#/,"",$1)
        key = $1
        value = $1
        gsub(/^[^:]+:[ \t]*|[ \t\n\r]+$/,"",value)
        if (key ~ /^LINK:/)
            link = value
        else if (key ~ /^PREFIX:/)
            prefix = value
        else if (key ~ /^TARGET:/) {
            target = value
            if (targetprefix) {
                print "Cannot set both TARGET and TARGETPREFIX!" > "/dev/stderr"
                exit
            }
            if (target !~ /{ID}/)
                target = target "{ID}"
        } else if (key ~ /^TARGETPREFIX:/) {
            targetprefix = value
            if (target) {
                print "Cannot set both TARGET and TARGETPREFIX!" > "/dev/stderr"
                exit
            }
        }
    } else if ($1 !~ /^[ \t\n\r]*$/) { # ignore empty source fields
        header = 0
        source = $1
        gsub(/^[ \t]+|[ \t\n\r]+$/,"",source) # trim
        if (NF > 1 && (targetprefix || $NF ~ /^[ \t]*[a-zA-Z][a-zA-Z+.-]*:.+/)) {
            # use last field if more than one field and last field looks like an URI or targetprefix set
            t = $NF
        } else if (target) {
            t = target
            sub(/{ID}/,source,t)
        } else {
            t = ""
        }
        if (t) {
            gsub(/^[ \t]+|[ \t\n\r]+$/,"",t) # trim target URI
            print "<" prefix source "> <" link "> <" targetprefix t "> ."
        }
    }
}