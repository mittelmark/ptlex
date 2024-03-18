##############################################################################
#
#  Copyright     : 2009-2024 Detlef Groth
#                  2009      Stefan Müller  
#  Object Name   : $RCSfile: ptlex2.tcl,v $
#  Author        : Detlef Groth
#  Created       : Thu May 28 10:02:08 2009
#  Last Modified : <240318.0916>
#
#  Description	 : Scanner generator for Tcl, Python, Perl and Ruby
#
#  History:       2024-03-16
#                 Support for Python 3
#                 Building app with tpack
#                 Project moved from Sourceforge to Github
#  History:       $Log: ptlex2.tcl,v $
#  History:       Revision 1.26  2009/08/25 09:02:04  dgroth
#  History:       addingb license information and revision information
#  History:
#  History:       Revision 1.25  2009/06/12 09:14:37  dgroth
#  History:       support for starkit packageing added and fix for no arguments
#  History:
#  History:       Revision 1.24  2009/06/12 09:02:05  dgroth
#  History:       more fixes for python-oo mode
#  History:
#  History:       Revision 1.23  2009/06/12 08:32:03  dgroth
#  History:       python oo support added for wc tested and ok
#  History:
#  History:       Revision 1.22  2009/06/11 14:20:35  dgroth
#  History:       support for python-oo not working yet
#  History:
#  History:       Revision 1.21  2009/06/11 13:30:13  dgroth
#  History:       fixing state issues with python
#  History:
#  History:       Revision 1.20  2009/06/11 13:09:11  dgroth
#  History:       fixes for print with newline for python and re.IGNORECASE
#  History:
#  History:       Revision 1.19  2009/06/11 12:53:37  dgroth
#  History:       inital python support procedural
#  History:
#  History:       Revision 1.18  2009/06/11 10:20:47  dgroth
#  History:       initial perl support
#  History:
#  History:       Revision 1.17  2009/06/10 14:11:02  dgroth
#  History:       fixing tcl issues with matchin part, adjusting sbs templates with init
#  History:
#  History:       Revision 1.16  2009/06/10 13:48:49  dgroth
#  History:       ruby implementation, no oo yet
#  History:
#  History:       Revision 1.15  2009/06/10 08:02:50  dgroth
#  History:       better formatting for default action
#  History:
#  History:       Revision 1.14  2009/06/10 07:59:28  dgroth
#  History:       implementing caseinsensitve option
#  History:
#  History:       Revision 1.13  2009/06/10 07:48:46  dgroth
#  History:       implementing prefix option
#  History:
#  History:       Revision 1.12  2009/06/10 07:36:03  dgroth
#  History:       file generation message added
#  History:
#  History:       Revision 1.11  2009/06/10 07:31:28  dgroth
#  History:       indenting adjusted for oo and non-oo
#  History:
#  History:       Revision 1.10  2009/06/06 06:00:09  dgroth
#  History:       fixing version problems
#  History:
#  History:       Revision 1.9  2009/06/06 05:55:10  dgroth
#  History:       implementing getopt options to overwrite flexfile settings
#  History:
#  History:       Revision 1.8  2009/06/05 15:19:30  dgroth
#  History:       switch to elseif in action part as well sbs.ftl is working
#  History:
#  History:       Revision 1.7  2009/06/05 15:06:12  dgroth
#  History:       fixes for sbs, part with states switches became elseif
#  History:
#  History:       Revision 1.6  2009/06/05 13:31:58  dgroth
#  History:       fixes for replacer and oo, buffer adjustment if not matched
#  History:
#  History:       Revision 1.5  2009/06/05 13:07:36  dgroth
#  History:       wc_oo working
#  History:
#  History:       Revision 1.4  2009/06/05 12:42:55  dgroth
#  History:       wc sample now working from switch back to elseif
#  History:
#  History:       Revision 1.3  2009/06/04 13:57:48  dgroth
#  History:       code is running still not correct
#  History:
#  History:       Revision 1.2  2009/06/04 12:38:21  dgroth
#  History:       some naming changes, function calls written
#  History:
#	
##############################################################################
#
#  Copyright (c) 2009-2024 Detlef Groth, 2009 Stefan Müller
#  License:      BSD-3 (see below)
# 
##############################################################################
package provide app-ptlex 2.0.0
set version 2.0.0
regsub Date: $version "" version
regsub -all {\$} $version "" version
array set options [list]
array set cdlarg [list license 0] ;# command line args will overwrite options from flexfile
set options(caseinsensitive) false ;    
set options(lang) tcl            ;# programming language tcl (, perl, ruby later)
set options(buffersize) 128;     #defines buffersize
set options(oo) 0;               #if true scanners is object oriented
set options(nodefault) false;    #uses no default action if set
set options(main) 1;             #uses default main routine if set
set options(outfile) "";
set options(skeleton_file) "";
set options(flexfile) "";             
set options(prefix) yy;       #uses prefix instead of 'yy'
set options(class) ""
array set regions [list init "" top "" usercode "" patterns "" main "" verbatim ""]
set sstates [list INITIAL]
set xstates [list]
set regexes [list]
set mstates [list]
set mactions [list]

proc debug {txt} {
    if {0} {
        puts $txt
    }
}
proc readFile {filename} {
    global regions options sstates xstates pnr
    set lnr 0
    set pnr 0
    set region 0
    set state verbatim
    if [catch {open $filename r} infh] {
        puts stderr "ERROR: Cannot open flexfile $filename: $infh"
        exit 0
    } else {
        while {[gets $infh line] >= 0} {
            incr lnr ;  incr pnr
            if {[regexp {^%%} $line]} {
                incr region
                continue
            }
            if {[regexp {^%(top|init)\{} $line -> state]} {
                    continue
            }
            if {[regexp {^%\{} $line]} {
                set state usercode ; continue
            }
            if {[regexp {^%(top|init|)\}} $line]} {
                set state verbatim
                continue
            }
            if {[regexp {^%option +([^\s]+)=([^\s]+)} $line -> key val]} {
                set options($key) $val
                debug "option=$key value=$val"
                continue
            }
            if {[regexp {^%s +(.+)} $line -> states]} {
                debug "states= $states"
                set tstates [split [string trim $states] " "]
                set sstates [concat $sstates $tstates]
                debug "sstates= $sstates"
                continue
            }
            if {[regexp {^%x +(.+)} $line -> states]} {
                set tstates [split [string trim $states] " "]
                set sstates [concat $xstates $tstates]
                debug "xstates= $xstates"
                continue
            }
            if {$region == 0} {
                append regions($state) "$line\n"
                continue
            }
            if {$region == 1} {
                incr pnr -1
                append regions(patterns) "$line\n"
                continue
            }
            if {$region == 2} {
                incr pnr -1
                if {[regexp {^\s*$} $line]} {
                    continue
                }
                append regions(main) "$line\n"
                continue
            }
        }
        close $infh
    }
}
proc getStates {c lnum} {
    global sstates xstates
    set res [list]
    if {$c eq "*"} {
        set res $xstates
        foreach s $sstates {
            lappend res $s
        }
        lappend res INITIAL
    } else {
        set res [split [regsub -all " " $c ""] ","]
        foreach currstate $res {
            if {[lsearch [concat $sstates $xstates] $currstate] < 0} {
                puts "Error: state $currstate is not defined line $lnum\n";
                exit 0
            }
        }  
    }
    return $res
}
proc parsePatterns {pcode pnr} {
    global regexes mstates mactions sstates
    set isaction false
    set actions ""
    foreach line [split $pcode "\n"] {
        if {[regexp {^\s*$} $line]} {
            continue
        }
        incr pnr
        set x [llength $regexes]
        if {$isaction} {
            if {[regexp {^\}} $line]} {
                set isaction false; 
                lappend mactions $actions
                set actions ""
            } else {
                append actions "$line\n"
            }
        } else {
            if {[regexp {^<([^>]+)>(.+?)\s+\{(.+)\}\s*$} $line -> c re ac]} {
                # in-line action with state
                lappend mstates [getStates $c $pnr]
                lappend regexes $re
                lappend mactions $ac
            } elseif {[regexp {^<([^>]+)>(.+?).\{\s*$} $line -> c re]} {
                # multi-line action with state
                lappend mstates [getStates $c $pnr] 
                lappend regexes $re
                set isaction true
            } elseif {[regexp {^(.+?)\s+{(.+)}\s*$} $line -> re ac]} {
                # in-line action no states
                lappend mstates $sstates
                lappend regexes $re
                lappend mactions $ac
            } elseif {[regexp {^(.+?)\s+\{\s*$} $line -> re]} {
                    # multi-line action no states
                lappend mstates $sstates
                lappend regexes $re
                set isaction true
            }
        }
    }
}
proc createRegexesTcl {} {
    global regexes options
    set indent 4
    if {$options(oo)} {
        incr indent 4
    }

    set res ""
    set x 0
    foreach reg $regexes {
        append res [string repeat " " $indent]
        append res "set reg[incr x] {\\A$reg}\n"
    }
    return $res
}
proc createRegexes {} {
    global regexes options
    set indent 4
    if {$options(oo)} {
        incr indent 4
    }
    set nocase ""
    if {$options(lang) == "r"} {
        set nocase "FALSE"
    }
    if {$options(caseinsensitive)} {
        set nocase "i"
        if {$options(lang) eq "python"} {
            set nocase ", re.IGNORECASE"
        } 
        if {$options(lang) eq "r"} {
            set nocase "TRUE"
        }
    }

    set res ""
    set x 0
    foreach reg $regexes {
        append res [string repeat " " $indent]
        if {$options(lang) eq "perl"} {
            append res "my \$reg[incr x] = qr/^$reg/$nocase;\n"
        } elseif {$options(lang) eq "r"} {
            append res "reg[incr x] = c('^$reg',$nocase)\n"
        } elseif {$options(lang) eq "ruby"} {
            append res "\$reg[incr x] = /\\A$reg/$nocase;\n"
        } elseif {$options(lang) eq "python"} {
            append res "reg[incr x] = re.compile('$reg'$nocase)\n"
        }
    }
    return $res
}

proc createMatchingTcl {} {
    global sstates mstates regexes
    global xstates
    global options
    set nocase ""
    if {$options(caseinsensitive)} {
        set nocase "-nocase "
    }
    set indent 8
    if {$options(oo)} {
        incr indent 4
    }
    set x 0
    array set rgx [list]
    set res ""
    set tmpl {  
        if {\[string length \$match\]>\$lbuffer} {
            set yy_rule $reg
            set lbuffer \[string length \$match\]
            set yytext \$match
        }
 }
    set tmpl [string range $tmpl 0 end-1]
    foreach state $mstates {
        incr x
        foreach st $state {
            if {[info exists rgx($st)]} {
                lappend rgx($st) $x
            } else {
                set rgx($st) [list $x]
            }
        }
    }
    if {[llength $sstates] > 1 || [llength $xstates] > 0} {
        set y 0
        set tmpl [regsub -all {\n } $tmpl "\n[string repeat { } $indent]"]
        array set done [list]
        foreach state [concat $sstates $xstates] {
            if {[incr y] == 1} {
                append res [string repeat " " $indent]
            } else {
                append res " else"
            }
            append res "if {\$yystate eq \"$state\"} {\n"
            if {[llength $rgx($state)] > 0} {
                set x 0
                incr indent 4
                foreach reg $rgx($state) {
                    if {[info exists done($reg,$state)]} {
                        continue
                    } else {
                        set done($reg,$state) 1
                    }
                    append res "\n[string repeat { } $indent]if {\[regexp ${nocase}-- \$reg$reg \$buffer match\]} {"
                    append res [subst $tmpl] 
                    append res [string repeat " " $indent]
                    append res "}"
                }
                incr indent -4
                append res "[string repeat { } $indent]\n" 
                
            }
            append res "[string repeat { } $indent]}"
        }
        append res "[string repeat { } $indent]\n" 
    } else {
        # no states
        #incr indent -4
        set x 0
        set tmpl [regsub -all {\n } $tmpl "\n[string repeat { } $indent]"]
        foreach reg $rgx(INITIAL) {
            append res "\n[string repeat { } $indent]if {\[regexp ${nocase}-- \$reg$reg \$buffer match\]} {"
            append res [subst $tmpl]
            append res "[string repeat { } $indent]}"
        }          
        append res "[string repeat { } $indent]\n" 
        
    }
}
proc createMatchingRuby {} {
    global sstates mstates regexes
    global xstates
    global options
    set indent 8
    if {$options(oo)} {
        incr indent 4
    }
    set x 0
    array set rgx [list]
    set res ""
    set tmpl {  
        if \$&.length>lbuffer
            yy_rule = $reg;
            \$yytext = $&;
            lbuffer = $&.length;
        end
 }
    set tmpl [string range $tmpl 0 end-1]
    foreach state $mstates {
        incr x
        foreach st $state {
            if {[info exists rgx($st)]} {
                lappend rgx($st) $x
            } else {
                set rgx($st) [list $x]
            }
        }
    }
    if {[llength $sstates] > 1 || [llength $xstates] > 0} {
        set y 0
        set tmpl [regsub -all {\n } $tmpl "\n[string repeat { } $indent]"]
        array set done [list]
        # array required for initial states
        foreach state [concat $sstates $xstates] {
            append res "\n[string repeat { } $indent]"
            if {[incr y] > 1} {
                append res "els"
            } 
            append res "if \$yystate == \"$state\""
            if {[llength $rgx($state)] > 0} {
                set x 0
                incr indent 4
  
                foreach reg $rgx($state) {
                    if {[info exists done($state,$reg)]} {
                        continue
                    } else {
                        set done($state,$reg) 1
                    }
                    append res "\n[string repeat { } $indent]"
                    append res "if \$reg${reg}.match(\$buffer)"
                    append res [subst $tmpl]
                    append res "\n[string repeat { } $indent]end"
                }
                incr indent -4
#                append res "[string repeat { } $indent]\n" 
                
            }
#            append res "[string repeat { } $indent]end"
        }
        append res "\n[string repeat { } $indent]end\n" 
    } else {
        # no states
        set x 0
        set tmpl [regsub -all {\n } $tmpl "\n     "]
        foreach reg $rgx(INITIAL) {
            append res "\n[string repeat { } $indent]"
            append res "if \$reg${reg}.match(\$buffer)"
            append res [subst $tmpl]
            append res "\n[string repeat { } $indent]end"
        }          
        #append res "\n[string repeat { } $indent]end" 
        
    }
    return $res
}
proc createMatchingPython {} {
    global sstates mstates regexes
    global xstates
    global options
    set indent 12
    if {$options(oo)} {
        incr indent 4
    }
    set x 0
    array set rgx [list]
    set res ""
    set tmpl {  
        if (regres.group().__len__()>lbuffer):
            yy_rule = $reg;
            ${self}yytext = regres.group();
            lbuffer = regres.group().__len__();
 }
    set tmpl [string range $tmpl 0 end-1]
    if {$options(oo)} {
        set self "self."
    } else {
        set self ""
    }
    foreach state $mstates {
        incr x
        foreach st $state {
            if {[info exists rgx($st)]} {
                lappend rgx($st) $x
            } else {
                set rgx($st) [list $x]
            }
        }
    }
    if {[llength $sstates] > 1 || [llength $xstates] > 0} {
        set y 0
        set tmpl [regsub -all {\n } $tmpl "\n[string repeat { } $indent]"]
        array set done [list]
        # array required for initial states
        foreach state [concat $sstates $xstates] {
            append res "\n[string repeat { } $indent]"
            if {[incr y] > 1} {
                append res "el"
            } 
            append res "if (${self}yystate == \"$state\"):"
            if {[llength $rgx($state)] > 0} {
                set x 0
                incr indent 4
  
                foreach reg $rgx($state) {
                    if {[info exists done($state,$reg)]} {
                        continue
                    } else {
                        set done($state,$reg) 1
                    }
                    append res "\n[string repeat { } $indent]"
                    if {$options(oo)} {
                        append res "regres=reg${reg}.match(self.buffer)"
                    } else {
                        append res "regres=reg${reg}.match(buffer)"
                    }
                    append res "\n[string repeat { } $indent]" 
                    append res "if (regres):"
                    append res [subst $tmpl]
                    append res "\n[string repeat { } $indent]"
                }
                incr indent -4
#                append res "[string repeat { } $indent]\n" 
                
            }
#            append res "[string repeat { } $indent]end"
        }
        append res "\n[string repeat { } $indent]\n" 
    } else {
        # no states
        set x 0
        set tmpl [regsub -all {\n } $tmpl "\n[string repeat { } [expr {$indent-4}]]"]
        foreach reg $rgx(INITIAL) {
            append res "\n[string repeat { } $indent]"
            if {$options(oo)} {
                append res "regres=reg${reg}.match(self.buffer)"
            } else {
                append res "regres=reg${reg}.match(buffer)"
            }
            append res "\n[string repeat { } $indent]"
            append res "if (regres):"
            append res [subst $tmpl]
            append res "\n[string repeat { } $indent]"
        }          
        #append res "\n[string repeat { } $indent]end" 
        
    }
    return $res
}

proc createMatchingPerl {} {
    global sstates mstates regexes
    global xstates
    global options
    set indent 8
    if {$options(oo)} {
        incr indent 4
    }
    set x 0
    array set rgx [list]
    set res ""
    set tmpl {  
        if(length(\$&)>\$lbuffer) {
           \$yy_rule = $reg;
           \$yytext = \$&;
           \$lbuffer = length(\$yytext);
        }
 }
    set tmpl [string range $tmpl 0 end-1]
    foreach state $mstates {
        incr x
        foreach st $state {
            if {[info exists rgx($st)]} {
                lappend rgx($st) $x
            } else {
                set rgx($st) [list $x]
            }
        }
    }
    if {[llength $sstates] > 1 || [llength $xstates] > 0} {
        set y 0
        set tmpl [regsub -all {\n } $tmpl "\n[string repeat { } $indent]"]
        array set done [list]
        foreach state [concat $sstates $xstates] {
            if {[incr y] == 1} {
                append res [string repeat " " $indent]
            } else {
                append res " els"
            }
            append res "if (\$yystate eq \"$state\") {\n"
            if {[llength $rgx($state)] > 0} {
                set x 0
                incr indent 4
                foreach reg $rgx($state) {
                    if {[info exists done($reg,$state)]} {
                        continue
                    } else {
                        set done($reg,$state) 1
                    }
                    append res "\n[string repeat { } $indent]if (\$buffer =~ \$reg$reg) {"
                    append res [subst $tmpl] 
                    append res [string repeat " " $indent]
                    append res "}"
                }
                incr indent -4
                append res "[string repeat { } $indent]\n" 
                
            }
            append res "[string repeat { } $indent]}"
        }
        append res "[string repeat { } $indent]\n" 
    } else {
        # no states
        #incr indent -4
        set x 0
        set tmpl [regsub -all {\n } $tmpl "\n[string repeat { } $indent]"]
        foreach reg $rgx(INITIAL) {
            append res "[string repeat { } $indent]if (\$buffer =~ \$reg$reg) {"
            append res [subst $tmpl]
            append res "[string repeat { } $indent]}"
        }          
        append res "[string repeat { } $indent]\n" 
        
    }
}

proc createMatchingR {} {
    global sstates mstates regexes
    global xstates
    global options
    set indent 8
    if {$options(oo)} {
        incr indent 4
    }
    set x 0
    array set rgx [list]
    set res ""
    set tmpl {  
        rx=regexpr(reg$reg[1],buffer,ignore.case=$reg[2])
        match=substr(buffer,rx[[1]],rx[[1]]+attr(rx,'match.length')-1)
        if(length(match)>lbuffer) {
           yy_rule = $reg;
           yytext = match;
           lbuffer = length(yytext);
        }
 }
    set tmpl [string range $tmpl 0 end-1]
    foreach state $mstates {
        incr x
        foreach st $state {
            if {[info exists rgx($st)]} {
                lappend rgx($st) $x
            } else {
                set rgx($st) [list $x]
            }
        }
    }
    if {[llength $sstates] > 1 || [llength $xstates] > 0} {
        set y 0
        set tmpl [regsub -all {\n } $tmpl "\n[string repeat { } $indent]"]
        array set done [list]
        foreach state [concat $sstates $xstates] {
            if {[incr y] == 1} {
                append res [string repeat " " $indent]
            } else {
                append res " else "
            }
            append res "if (yystate eq \"state\") {\n"
            if {[llength $rgx($state)] > 0} {
                set x 0
                incr indent 4
                foreach reg $rgx($state) {
                    if {[info exists done($reg,$state)]} {
                        continue
                    } else {
                        set done($reg,$state) 1
                    }
                    ## TODO: 
                    append res "\n[string repeat { } $indent]if (grepl(reg$reg\[1\],x=buffer,ignore.case=reg\$reg\[2\])) {"
                    append res [subst -nocommands $tmpl] 
                    append res [string repeat " " $indent]
                    append res "}"
                }
                incr indent -4
                append res "[string repeat { } $indent]\n" 
                
            }
            append res "[string repeat { } $indent]}\n"
        }
        append res "[string repeat { } $indent]\n" 
    } else {
        # no states
        #incr indent -4
        set x 0
        set tmpl [regsub -all {\n } $tmpl "\n[string repeat { } $indent]"]
        foreach reg $rgx(INITIAL) {
            append res "[string repeat { } $indent]if (grepl(reg$reg\[1\],x=buffer,ignore.case=reg$reg\[2\])) {"
            append res [subst -nocommands $tmpl]
            append res "[string repeat { } $indent]}\n"
        }          
        append res "[string repeat { } $indent]\n" 
        
    }
}

proc createActions {actions} {
    global options
    set indent 8
    set res "" ;#[string repeat " " $indent]
    set x 0
    if {$options(oo)} {
        incr indent 4
    }
    if {$options(lang) eq "python"} {
        incr indent 4
    }
    foreach action $actions {
        if {[incr x] == 1} {
            append res [string repeat " " $indent]
        } else {
            if {$options(lang) eq "python"} {
                append res "el"
            } elseif {$options(lang) eq "r"} {
                append res "else "
            } else {
                append res "els"
            }
        }
        if {$options(lang) eq "ruby"} {
            append res "if yy_rule == $x\n"
        } elseif {$options(lang) eq "python"} {
            append res "if (yy_rule == $x):\n"
        } elseif {$options(lang) eq "perl"} {
            append res "if (\$yy_rule == $x) \{\n"
        } elseif {$options(lang) eq "r"} {
            append res "if (yy_rule == $x) \{\n"
        }
        foreach line [split $action "\n"] {
            append res [string repeat " " $indent]
            append res "$line\n"
        }
        append res "[string repeat { } $indent]"
        if {$options(lang) eq "perl"} {
            append res "\} "
        } elseif {$options(lang) eq "r"} {
            append res "\} "
        }

    }
    if {!$options(nodefault)} {
        if {$options(lang) eq "ruby"} {
            append res "else\n"
            append res "[string repeat { } $indent]    print \$yytext ;\n"
        } elseif {$options(lang) eq "python"} {
            append res "else:\n"
            if {$options(oo)} {
                append res "[string repeat { } $indent]    sys.stdout.write(self.yytext) ;\n"
            } else {
                append res "[string repeat { } $indent]    sys.stdout.write(yytext) ;\n"
            }
        } elseif {$options(lang) eq "perl"} {
            append res "else { print \$yytext ; }\n"
        } elseif {$options(lang) eq "r"} {
            append res "else { cat(yytext) ; }\n"
        } 
    }
    if {$options(lang) eq "ruby"} {
        append res "[string repeat { } $indent]end"
    }
    return $res
}
proc createActionsTcl {actions} {
    global options
    set indent 8
    set res "" ;#[string repeat " " $indent]
    set x 0
    if {$options(oo)} {
        incr indent 4
    }
    foreach action $actions {
        if {[incr x] == 1} {
            append res [string repeat " " $indent]
        } else {
            append res " else"
        }
        append res "if {\$yy_rule == $x} {\n"
        #append res [string repeat " " $indent]
        foreach line [split $action "\n"] {
            append res [string repeat " " $indent]
            append res "$line\n"
        }
        append res "[string repeat { } $indent]}"
    }
    if {!$options(nodefault)} {
        append res " else { puts -nonewline \$yytext ; }\n"
    }
    return $res
}

proc readTemplate {filename} {
    global regions options
    set res $regions(top)
    if {[catch {open $filename r} infh]} {
        puts stderr "Cannot open $filename: $infh"
        exit
    } else {
     
        while {[gets $infh line] >= 0} {
            regsub {__CLASSNAME__} $line $options(class) line
            regsub {__BSIZE__} $line $options(buffersize) line
            # Process line
            if {[regexp {^__VERBATIM__} $line]} {
                append res $regions(verbatim)
            } elseif {[regexp {^__INIT__} $line]} {
                append res $regions(init)
            } elseif {[regexp {^__REGEXES__} $line]} {
                append res $regions(regexes)
            } elseif {[regexp {^__MATCHES__} $line]} {
                append res $regions(matches)
            }  elseif {[regexp {^__ACTIONS__} $line]} {
                append res $regions(actions)
            } elseif {[regexp {^__USERCODE__} $line]} {
                append res $regions(usercode)
            } elseif {[regexp {^__MAIN__} $line]} {
                if {$regions(main) eq ""} {
                    continue
                } else {
                    append res $regions(main)
                    break
                }
            } else {
                append res $line
            }
            append res "\n"
        }
        close $infh
    }
    return $res
}
proc License {} {
puts {
    
    Copyright (c) 2009 Dr. Detlef Groth (University of Potsdam) and 
    Stefan Mueller (Free University Berlin)
    
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this
list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

Neither the name of the University Potsdam nor the names of its contributors may
be used to endorse or promote products derived from this software without
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  }
}
proc HelpMessage {} {
    puts {
ptlex - Tcl based flexlike scanner generator for Tcl, Python, Perl and Ruby.

Version 2.0.0

How to use ptlex:

ptlex [options] FLEXFILE OUTFILE
    
Valid options are:

-+                   Object Oriented scanner (Tcl, Perl and Python)
--buffersize num     Set buffersize of scanner to num
--flexfile file      Set flexfile
--help, -h           Get help
-i                   Scanner with caseinsensivity
--lang               tcl|ruby|perl|python
-o         file      Set outfile
--outfile  file      Set outfile 
-P         pref      Set prefix for functions, variables, objects (default yy)
--prefix   pref      Set prefix for functions, variables, objects (default yy)
-s                   No default action if nothing matches
-S              file Set skeleton_file for creating the scanner
--skeleton_file file Set skeleton_file for creating the scanner    

                     Sets the programming language of the flexfile
-v, -V, --version    Returns the ptlex version and exits
--license            Display license, is a BSD-license http://www.opensource.org/licenses/bsd-license.php
  }
}

source [file join [file dirname [info script]] getopt.tcl]
set cdlarg(outfile) ""
set cdlarg(flexfile) ""
getopt flag arg $argv {
    -V - -v - --version { puts "$version" ; exit 0 }
    -h? - --help { HelpMessage ; exit 0 ; }
    -+ - --oo { set cdlarg(oo) 1 }
    --buffersize: { set cdlarg($flag) $arg }
    -P: - --prefix: { set cdlarg(prefix) $arg }
    -i - --caseinsensitive { set cdlarg(caseinsensitive) 1 }
    -o: - --outfile: { set cdlarg(outfile) $arg }
    --flexfile: { set cdlarg(flexfile) $arg }
    -S: - --skeleton_file: { set cdlarg(skeleton_file) $arg }
    -s { set cdlarg(nodefault) 1 }
    --lang: - -l: { set cdlarg(lang) $arg }
    --license { set cdlarg(license) 1 }
    missing {
        puts stderr "option requires argument: $arg"
        HelpMessage ;
        exit 2
    }
    unknown {
        puts stderr "unknown or ambiguous option: $arg"
        HelpMessage ;
        exit 2
    }
    arglist {
        if {[llength $arg] == 2} {
            set cdlarg(flexfile) [lindex $arg 0]
            set cdlarg(outfile)  [lindex $arg 1]
        } elseif {[llength $arg] == 1} {
            set cdlarg(flexfile) [lindex $arg 0]
        }
    }
                 
}
if {$cdlarg(license)} {
    License
    exit 0
}
if {$cdlarg(flexfile) eq ""} {
    HelpMessage
    exit 0 ;
}
if {[llength $argv] == 0} {
    HelpMessage ; exit 0;
} else {
    if {$options(oo) && $options(lang) eq "ruby"} {
        puts stderr "Error: option --oo for ruby not yet implemented!"
        exit 0
    }
    array set options [array get cdlarg]
    set options(lang) [string tolower $options(lang)]
    if {$options(outfile) eq ""} {
        if {$options(lang) eq "tcl"} {
            set options(outfile) "[file rootname $options(flexfile)].tcl"
        } elseif {$options(lang) eq "ruby"} {
            set options(outfile) "[file rootname $options(flexfile)].rb"
        } elseif {$options(lang) eq "perl"} {
            set options(outfile) "[file rootname $options(flexfile)].pl"
        } elseif {$options(lang) eq "python"} {
            set options(outfile) "[file rootname $options(flexfile)].py"
        } elseif {$options(lang) eq "r"} {
            set options(outfile) "[file rootname $options(flexfile)].r"
        } else {
            puts stderr "ERROR: language $options(lang) not implemented!\n"
            exit 0
        }
    }
    readFile $cdlarg(flexfile)
    # overwrite filefile options with command line ones

    parsePatterns $regions(patterns) $pnr
    if {$options(lang) eq "tcl"} {
        set regions(regexes) [createRegexesTcl]
        set regions(matches) [createMatchingTcl]
        set regions(actions) [createActionsTcl $mactions]
    } elseif {$options(lang) eq "ruby"} {
        set regions(regexes) [createRegexes]
        set regions(matches) [createMatchingRuby]
        set regions(actions) [createActions $mactions]
    } elseif {$options(lang) eq "perl"} {
        set regions(regexes) [createRegexes]
        set regions(matches) [createMatchingPerl]
        set regions(actions) [createActions $mactions]
    } elseif {$options(lang) eq "python"} {
        set regions(regexes) [createRegexes]
        set regions(matches) [createMatchingPython]
        set regions(actions) [createActions $mactions]
    } elseif {$options(lang) eq "r"} {
        set regions(regexes) [createRegexes]
        set regions(matches) [createMatchingR]
        set regions(actions) [createActions $mactions]
    } 
    if {$options(skeleton_file) eq ""} {
        set options(skeleton_file) "[file join [file dirname [info script]] $options(lang).tmpl]"
        if {$options(oo)} {
            regsub .tmpl $options(skeleton_file) _oo.tmpl options(skeleton_file)
        }
    }
    if {$options(class) eq ""} {
        set options(class) [file tail [file rootname $options(flexfile)]]
        regsub -all {[^a-zA-Z0-9]} $options(class) "" options(class)
    }
    set scanner [readTemplate $options(skeleton_file)]
    if {$options(lang) eq "ruby" || $options(lang) eq "perl" || $options(lang) eq "python"} {
        regsub -all {(\W)BEGIN(\W)} $scanner "\\1yybegin\\2" scanner
    }
    if {$options(prefix) ne "yy"} {
        regsub -all {(\W)yy([a-z_]{2})} $scanner "\\1$options(prefix)\\2" scanner
    }
    set out [open $options(outfile) w 0600]
    puts $out "$scanner"
    close $out
    puts "Success: Language=$options(lang)  Script-file=$options(outfile) generated!"
}
