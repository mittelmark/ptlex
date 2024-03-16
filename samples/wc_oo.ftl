%top{
#!/usr/bin/tclsh8.4
%top}
%init{
public variable nline 0
public variable nword 0
public variable nchar 0
%init}
%option buffersize=1024
%option class=wc
%%
\n        { incr nline; incr nchar ; }
[^ \t\n]+ { incr nword; incr nchar $yyleng ;}
.         { incr nchar;}
%%
if {[llength $argv] == 0} {
   puts stderr "usage wc.tcl inputfile"
   exit 0
}
set sc [wc #auto]
$sc yylex [lindex $argv 0]
puts [format "%7d %7d %7d %s" [$sc cget -nline] [$sc cget -nword] [$sc cget -nchar] [lindex $argv 0]]
