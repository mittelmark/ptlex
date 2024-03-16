
%{
    global nline nword nchar
    set nline 0
    set nword 0
    set nchar 0
%}

%option buffersize=1024

%%


\n {
    incr nline
    incr nchar
}

[^ \t\n]+ {
    incr nword
    incr nchar [string length $yytext]
}

. {
    incr nchar
}

%%

if {[llength $argv] == 0} {
   puts stderr "usage wc.tcl inputfile"
   exit 0
}
yylex [lindex $argv 0]
puts [format "%7d %7d %7d %s" $nline $nword $nchar [lindex $argv 0]]

