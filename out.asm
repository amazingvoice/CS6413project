label 1
ADD 1 2 7
SUB 7 3 8
MULF 4 5 9
DIVF 9 6 10
SUB 1 2 11
JLE 11 #4 2
READ 1
JUMP 3
label 2
MULF 4 5 12
JLT 12 6 4
DIV 2 3 13
COPY 13 1
JUMP 5
label 4
MUL 2 3 14
COPY 14 1
label 5
label 6
JLE 6 #0 7
WRITES "this is in the while loop"
READF 6
JUMP 6
label 7
SUB 1 2 15
ADD 15 3 16
CALL 0
label 3
RETURN
label 0
WRITES "entered func"
MUL 17 #2 18
RETURN
START 1
