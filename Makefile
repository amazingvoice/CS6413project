myparser:	tok.l parser.y
	bison -vd parser.y
	flex tok.l
	cc -w -o $@ parser.tab.c lex.yy.c -lfl

clean:
	rm lex.yy.c parser.tab.* myparser parser.output
