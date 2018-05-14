label 1
WRITES "Enter an integer in decimal number system\n"
NEWLINE
READ 5
WRITES "in binary number system is:\n"
WRITE 5
NEWLINE
COPY #31 2
label 2
JLE 2 #0 3
COPY 2 0
CALL 0
DIV 5 1 9
COPY 9 6
JLE 6 #0 4
WRITES "1"
NEWLINE
JUMP 5
label 4
WRITES "0"
NEWLINE
label 5
SUB 2 #1 10
COPY 10 2
JUMP 2
label 3
WRITES "\n"
NEWLINE
COPY #0 3
RETURN
STOP
label 0
JGE 0 #0 6
WRITES "Do not know how to compute negative powers, was given "
WRITE 0
NEWLINE
label 6
COPY #0 11
COPY #1 12
label 7
JGE 11 2 8
MUL 12 #2 13
COPY 13 12
ADD 11 #1 14
COPY 14 11
JUMP 7
label 8
COPY 12 1
RETURN
START 1
