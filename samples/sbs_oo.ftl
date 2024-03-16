%top{
#!/usr/bin/tclsh8.4
# this is a comment should go on top
%top}
%init{
    variable query_id ""
    variable query_length 0
    variable hit_id ""
    variable score -1
    variable evalue -1
    variable hit 0 ;
    variable position -1 ;
    method dumpHit {} {}
    method dumpPosition {} {}
%init}
%option buffersize=256
%option nodefault=true
%option class=sbs
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
itcl::body sbs::dumpPosition {} {
    puts "insert into positions (query_id,query_length,position) values ('$query_id',$query_length,$position);"
}   
itcl::body sbs::dumpHit {} {
    incr hit
    puts "insert into hits (query_id,hit_id,hit,score,evalue) values ('$query_id','$hit_id',$hit,$score,$evalue);"    
}   
if {[llength $argv] == 0} {
   puts stderr "usage: [info scrip] inputfile"
   exit 0
}
set sc [sbs #auto]
$sc yylex [lindex $argv 0]
