# Simple awk script to convert N-Triples to BEACON
# USAGE: awk -f YOURFILE.nt -vprefix=YOURPREFIX -vtarget=YOURTARGET
# or     awk -f YOURFILE.nt -vprefix=YOURPREFIX -vtargetprefix=YOURTARGETPRFIX

BEGIN {
    if (!prefix) {
        print "Missing argument '-vprefix=http://...'" > "/dev/stderr"
        exit
    }
    print "#PREFIX: " prefix
    if (target) {
        print "#TARGET: " target
    } else if (targetprefix) {
        print "#TARGETPREFIX: " targetprefix
    }
}
substr($1,2,length(prefix)) == prefix && substr($3,2,length(target)) == target {
    gsub(/^<|>$/,"",$1)
    gsub(/^<|>$/,"",$2)
    gsub(/^<|>$/,"",$3)
    if (!link) { # use first triple to get predicate
        link = $2
        print "#LINK: " link
        print ""
    }
    if ($2 == link) { # ignore all triples with different predicate
        s = substr($1,length(prefix)+1)
        if ( target && substr($3,length(target)+1) == s ) {
            print s  # one common identifier
        } else if (targetprefix) {
            if ( substr($3,1,length(targetprefix)) == targetprefix ) {
                t = substr($3,length(targetprefix)+1)
                print s "|" t
            }
        } else {
            print s "|" $3 # explicit URL
        }
    }
}
{ } # ignore the rest
