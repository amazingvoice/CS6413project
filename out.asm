label 0
JLE 0 2 1
COPY 2 3
COPY 0 2
COPY 3 0
label 1
label 2
JLE 0 #0 3
DIV 2 0 4
MUL 0 4 5
SUB 2 5 6
COPY 6 3
COPY 0 2
COPY 3 0
JUMP 2
label 3
COPY 2 1
RETURN
label 4
WRITES "I am going to try and compute GCD using Euclid's algorithm. Gimme two integers"
NEWLINE
READ 9
READ 10
JLT #0 9 5
WRITES "I wanted a positive number and you gave me "
WRITE 9
WRITES "!!!!"
NEWLINE
COPY #17 7
RETURN
label 5
JLT #0 10 6
WRITES "I wanted a positive number and you gave me "
WRITE 10
WRITES "!!!!"
NEWLINE
COPY #17 7
RETURN
label 6
WRITES "Will attempt to compute GCD("
WRITE 9
WRITES ","
WRITE 10
WRITES ")"
NEWLINE
COPY 10 0
COPY 9 2
CALL 0
WRITE 1
NEWLINE
COPY #0 7
RETURN
START 4
