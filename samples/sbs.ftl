%top{
#!/usr/bin/tclsh8.4
# this is a comment should go on top
%top}
%init{
    global query_id query_length hit_id score evalue hit position
    set query_id ""
    set query_length 0
    set hit_id ""
    set score -1
    set evalue -1
    set hit 0 ;
    set position -1 ;
%init}
%option buffersize=256
%option nodefault=true
%s QUERY
%s HITS
%%
<*>BLAST[XNP] {
    set hit 0 
    set position $yychar  
    BEGIN QUERY
}
<QUERY>Query=[ ][^ \t\n]+ {
      set query_id [string range $yytext 7 end]
}
<QUERY>([0-9]+[ ]letters) {
    set query_length [string range $yytext 1 end-7]
    dumpPosition
    
}
<QUERY>Sequences[ ]producing[ ]significant[ ]alignments {
    BEGIN HITS
}
<HITS>>[^ \t\n]+ {
   set hit_id [string range $yytext 1 end]

}
<HITS>[ ]Score[ ]=[ ]+[0-9]+ {
    set score [string range $yytext [expr [string last " " $yytext] + 1] end]
}  
<HITS>[ ]Expect[^ ]*[ ]=[ ]+[-\.e0-9]+ {
   set evalue [string range $yytext [expr [string last " " $yytext] + 1] end] 
   if {[string first e $evalue] == 0} {
        set evalue 1$evalue
   }  
   dumpHit
}
<*>(.|\n) { # do nothing }
%%
proc dumpPosition {} {
    global query_id query_length hit_id score evalue hit position
         puts "insert into positions (query_id,query_length,position) values ('$query_id',$query_length,$position);"
}   
proc dumpHit {} {
    global query_id query_length hit_id score evalue hit position
    incr hit
    puts "insert into hits (query_id,hit_id,hit,score,evalue) values ('$query_id','$hit_id',$hit,$score,$evalue);"    
}   
if {[llength $argv] == 0} {
   puts stderr "usage: [info scrip] inputfile"
   exit 0
}
yylex [lindex $argv 0]
