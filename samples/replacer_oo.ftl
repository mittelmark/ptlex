%top{
#!/usr/bin/tclsh8.4
%top}

%option buffersize=1024
%option class=replacer
%%
[a-z]        { puts -nonewline x }

%%
if {[llength $argv] == 0} {
   puts stderr "usage replacer_oo.tcl <inputfile>"
   exit 0
}

set sc [replacer #auto]
$sc yylex [lindex $argv 0]
