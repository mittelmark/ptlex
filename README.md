# ptlex

## NAME

__ptlex__: Lexer generator written in Tcl for Tcl, Python, Perl, R and Ruby

## SYNOPSIS

```
ptlex --lang LANGUAGE ?-+? FLEXFILE OUTFILE
```

Reads the input FLEXFILE and creates a Script OUTFILE for the given  language.
The option `-+` allows you to create an object oriented  scanner for the given
language.  Possible  languages are currently Tcl, Perl, Python, Ruby. For Tcl,
Perl and Python as well object oriented lexers can be generated.

## DESCRIPTION

Parsing of various input file formats is a challenging  part for  programmers.
Lexers simplify this process by providing a simplified file format to generate
a full  program  using the lexer  generator.  Here an example for a wc-program
using the ptlex program first for Tcl:


```
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
```

This flex-like input file can be translated into a program with the following programm call:

```
ptlex --lang Tcl wc.ftl wc.tcl
```

If you would like to have a scanner  which does not write to stdout you should
remove the  commandline  parsing at the bottom and just  source this file into
your  application.  There you then have to call  yylex with the file which you
would like to use.


For more examples see the folder  [samples](samples). You can see the commands
to   convert   these    flex-like   input   files   into   programs   in   the
[Makefile](Makefile).

## INSTALLATION

On Unix systems or on Windows with Msys: 

- download the file `ptlex.tapp`
- make it executable  using `chmod`
- copy it to a folder belonging to your `PATH` variable

## SUPPORTED LANGUAGES

Scanner generation is done using the Tcl programming language. Scanners can be
generated for the programming languages Tcl, Perl, Python, R and Ruby. For the
first three as well in an OO-style. See the following summary table.

| Programming Language | Functional-Style | OO-style   | Samples      |
|:--------------------:|:----------------:|:----------:|:------------:|
| Perl                 | yes              | yes        | wc, rep, sbs |
| Python 3             | yes              | yes        | wc, rep, sbs |
| R                    | yes              | no         | wc, rep      |
| Ruby                 | yes              | no         | wc, rep, sbs |
| Tcl                  | yes              | yes (itcl) | wc, rep, sbs |

## OTHER LEXERS

| Lexer                | Programming Language | Link                                  |
|:---------------------|:---------------------|:--------------------------------------|
| Flex                 | C/C++                | https://github.com/westes/flex        |
| Gplex                | C#                   | https://github.com/k-john-gough/gplex | 
| Jflex                | Java                 | https://github.com/jflex-de/jflex     |
| Tply                 | Pascal               | https://github.com/martok/fpc-tply    |
| Fickle               | Tcl                  | https://github.com/devnull42/fickle   |
| Yeti                 | Tcl                  | https://github.com/mittelmark/yeti    |

## LICENSE

```
BSD 3-Clause License

Copyright (c) 2009-2024, Detlef Groth, University of Potsdam, Germany

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```
