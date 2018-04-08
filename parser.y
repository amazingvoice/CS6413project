%{
#include <stdio.h>
%}

%token	KW_INT KW_FLOAT
%token	KW_IF
%token	KW_ELSE
%token	KW_WHILE
%token	KW_RETURN
%token	KW_READ KW_WRITE
%token	ID
%token	OP_PLUS OP_MINUS
%token	OP_MULT OP_DIV
%token	OP_ASSIGN
%token	OP_EQ OP_LT OP_LE OP_GT OP_GE
%token 	LPAR RPAR
%token 	LBRACE RBRACE
%token 	SEMICOLON
%token 	COMMA
%token 	INT_LIT FLOAT_LIT STRING_LIT
%token 	NL_TOKEN
%token 	WS_TOKEN

%right OP_ASSIGN
%left OP_PLUS OP_MINUS
%left OP_MULT OP_DIV
%left UMINUS

%%

program		:	
		|	program function_def	{printf("program 1 matched\n");}
		|	program decl	{printf("program 2 matched\n");}
		|	program function_decl	{printf("program 3 matched\n");}
		;

function_decl	:	kind ID LPAR kind RPAR SEMICOLON {printf("function_decl matched\n");}
		;

function_def	:	kind ID LPAR kind ID RPAR body {printf("function_def matched\n");}
		;


body		:	LBRACE decls stmts RBRACE {printf("body matched\n");}
		;

decls		:	
		| 	decls decl {printf("decls matched\n");}
		;

stmts		:	
		|	stmts stmt {printf("stmts matched\n");}
		;


decl		:	kind var_list SEMICOLON {printf("decl matched\n");}
		;

kind		:	KW_INT {printf("type int matched\n");}
		|	KW_FLOAT {printf("type float matched\n");}
		;

stmt		:	expr SEMICOLON {printf("expr SEMICOLON => stmt\n");}
		|	KW_IF LPAR bool_expr RPAR stmt opt_else {printf("stmt if matched\n");}
		|	KW_WHILE LPAR bool_expr RPAR stmt {printf("stmt while matched\n");}
		|	KW_WHILE LPAR bool_expr RPAR body
		|	KW_READ var_list SEMICOLON {printf("stmt read maitched\n");}
		|	KW_WRITE write_expr_list SEMICOLON {printf("stmt write matched\n");}
		|	KW_RETURN expr SEMICOLON {printf("stmt return matched\n");}
		;

write_expr_list	:	wlist_unit wlist_rep
		;

wlist_unit 	:	expr
		|	STRING_LIT
		;

wlist_rep	:	
		|	wlist_rep COMMA wlist_unit
		;

var_list	:	ID var_list_rep
		;

var_list_rep	:	
		|	var_list_rep COMMA ID
		;

opt_else	:	
		|	KW_ELSE stmt
		;

bool_expr	:	expr bool_op expr {printf("expr bool_expr expr matched\n");}
		|	ID bool_op expr {printf("ID bool_op expr matched\n");}
		|	ID bool_op ID {printf("ID bool_op ID matched\n");}
		;

bool_op		:	OP_EQ
		|	OP_LT
		|	OP_LE
		|	OP_GT
		|	OP_GE
		;

expr		:	ID OP_ASSIGN expr {printf("assignment expr matched\n");}
		|	expr1	{printf("expr 2 matched\n");}
		;

expr1		:	expr1 OP_PLUS expr1
		|	expr1 OP_MINUS expr1
		|	expr1 OP_MULT expr1
		|	expr1 OP_DIV expr1
		|	OP_MINUS factor %prec UMINUS
		|	factor
		;

factor		:	ID | INT_LIT | FLOAT_LIT | function_call | LPAR expr RPAR
		;

function_call	:	ID LPAR expr RPAR {printf("function_call 1 matched\n");}
		;

%%

main(int argc, char **argv)
{
	yyparse();
}

yyerror(char *s)
{
	fprintf(stderr, "error: %s\n", s);
}
