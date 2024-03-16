%%

[a-z] { puts -nonewline x }

%%


if {[llength $argv] == 0} {
   puts stderr "usage replacer.tcl inputfile"
   exit 0
}
yylex [lindex $argv 0]
