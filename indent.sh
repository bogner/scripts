#!/bin/bash

/usr/bin/indent -nbad -bap -nbbb -nbbo -nbc -bli0 -br -brs -c33 -cbi0 -cd33 \
    -ncdb -cdw -ce -ci4 -cli0 -cp33 -ncs -d0 -nbfda -nbfde -di1 -fc1 -nfca \
    -nhnl -i4 -ip0 -l80 -lc80 -lp -nlps -npcs -pi1 -nprs -psl -saf -sai -saw \
    -sbi0 -nsc -nsob -nss -ts4 -nut "$@"

exit $?

-nbad
    Force blank lines after the declarations.
-bap
    Force blank lines after procedure bodies.
-nbbb
    Force blank lines before block comments.
-nbbo
    Prefer to break long lines before boolean operators.
-nbc
    Force newline after comma in declaration.
-bli0
    Indent braces n spaces.
-br
    Put braces on line with if, etc.
-brs
    Put braces on struct declaration line.
-c33
    Put comments to the right of code in column n.
-cbi0
    Indent braces after a case label N spaces.
-cd33
    Put comments to the right of the declarations in column n.
-ncdb
    Put comment delimiters on blank lines.
-cdw
    Cuddle while of do {} while; and preceeding ‘}’.
-ce
    Cuddle else and preceeding ‘}’.
-ci4
    Continuation indent of n spaces.
-cli0
    Case label indent of n spaces.
-cp33
    Put comments to the right of #else and #endif statements in column n.
-ncs
    Put a space after a cast operator.
-d0
    Set indentation of comments not to the right of code to n spaces.
-nbfda
    Break the line before all arguments in a declaration.
-nbfde
    Break the line after the last argument in a declaration.
-di1
    Put variables in column n.
-fc1
    Format comments in the first column.
-nfca
    Do not disable all formatting of comments.
-nhnl
    Prefer  to  break  long  lines  at  the position of newlines in the input.
-i4
    Set indentation level to n spaces.
-ip0
    Indent parameter types  in  old-style  function  definitions  by n spaces.
-l80
    Set maximum line length for non-comment lines to n.
-lc80
    Set maximum line length for comment formatting to n.
-lp
    Line up continued lines at parentheses.
-nlps
    Leave space between ‘#’ and preprocessor directive.
-npcs
    Insert a space between the name of the procedure being  called  and the ‘(’.
-pi1
    Specify  the  extra  indentation  per  open  parentheses ’(’ when a statement is broken.
-nprs
    Put a space after every ’(’ and before every ’)’.
-psl
    Put the type of a procedure on the line before its name.
-saf
    Put a space after each for.
-sai
    Put a space after each if.
-saw
    Put a space after each while.
-sbi0
    Indent braces of a struct, union or enum N spaces.
-nsc
    Put the ‘*’ character at the left of comments.
-nsob
    Swallow optional blank lines.
-nss
    On one-line for and while statments, force a blank before the semicolon.
-ts4
    Set tab size to n spaces.
-nut
    Use tabs. This is the default.
