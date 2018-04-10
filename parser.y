%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

extern int yylineno;

int type[2];
int type_indicator = 0;

extern char str1[50];
extern char str2[50];

bool global = true;
char func_def[50];

typedef struct symbol {
	char name[50];
	char val_type[10];
	char ret_type[10];
	bool isGlobal;
	bool declared;
	bool implemented;
	int lineno;
	int decl_lineno;
	int def_lineno;
	struct symbol *next;
} sym;

sym *ltable = NULL;
sym *gtable = NULL;

sym *head = NULL;
sym *tail = NULL;
sym *temp = NULL;

bool found = false;
bool funcAsVar = false;

int lid = 0;
int gid = 0;

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

%locations

%%

program		:	
		|	program function_def
		|	program decl		
		|	program function_decl	
		;

function_decl	:	kind ID LPAR kind RPAR SEMICOLON 
			{
				char *param1 = ((type[type_indicator++] == 1) ? "int" : "float");
				type_indicator %= 2;
				char *param2 = ((type[type_indicator] == 1) ? "int" : "float");
				
				temp = gtable;
				found = false;
				while(temp != NULL) {
					if(strcmp(temp->name, yylval) ==  0 && temp->declared) {
						found = true;
						break;
					}
					temp = temp->next;
				}
				if(!found) {	
					temp = (sym *)malloc(sizeof(sym));
					strcpy(temp->name, yylval);
					strcpy(temp->ret_type, param2);
					strcpy(temp->val_type, param1);
					temp->declared = true;
					temp->implemented = false;
					temp->decl_lineno = yylineno;
	
					/* add to the head of the gtable list */
					if(gtable != NULL) {
						temp->next = gtable->next;
						gtable->next = temp;
					}
					else {
						temp->next = NULL;
						gtable = temp;
					}
				}

				found = false;

				printf("function %s %s(%s) declared in line %d\n", param2, yylval, param1, yylineno);
			}
		;

function_def	:	kind ID LPAR kind ID RPAR 
			{
				temp = gtable;
				found = false;
				while(temp != NULL) {
					if(strcmp(temp->name, yylval) ==  0 && temp->declared) {
						temp->implemented = true;
						found = true;
						break;
					}
					temp = temp->next;
				}
				if(!found) {
					temp = (sym *)malloc(sizeof(sym));
					strcpy(temp->name, yylval);
					temp->declared = false;
					temp->implemented = true;
					temp->def_lineno = yylineno;

					/* add to the head of the gtable list */
					if(gtable != NULL) {
						temp->next = gtable->next;
						gtable->next = temp;
					}
					else {
						temp->next = NULL;
						gtable = temp;
					}
				}
				found = false;
				printf("function %s defined in line %d\n", str1, yylineno);

				global = false;
				strcpy(func_def, str1);	

				/* function parameter */
				
				temp = (sym *)malloc(sizeof(sym));
				strcpy(temp->name, yylval);

				if(type[type_indicator] == 1)
					strcpy(temp->val_type, "int");
				else
					strcpy(temp->val_type, "float");

				temp->isGlobal = false;
				temp->lineno = yylineno;
				
				temp->declared = false;
				temp->implemented = false;
				temp->next = NULL;

				ltable = temp;

				(global) ? printf("Global ") : printf("Local ");
				(type[type_indicator] == 1) ? printf("int variable ") : printf("float variable ");
				printf("%s declared in line %d\n", yylval, yylineno);
			}
			body
			{
				global = true;
				
				/* free up memory */
				while(ltable != NULL) {
					temp = ltable;
					ltable = ltable->next;
					free(temp);
				}
			}	
		;

body		:	LBRACE decls stmts RBRACE
		;

decls		:	
		| 	decls decl
		;

stmts		:	
		|	stmts stmt
		;

decl		:	kind var_list SEMICOLON 
			{
				temp = head;	
				while(temp != NULL) {
					if(temp->isGlobal) printf("Global "); 
					else		  printf("Local ");
					printf("%s variable %s declared in line %d.\n", 
						temp->val_type, temp->name, temp->lineno);
					temp = temp->next; 
				}
				temp = NULL;

				/* add varlist to local/global symbol table*/
				if(global) {
					tail->next = gtable;
					gtable = head;
				}
				else {
					tail->next = ltable;
					ltable = head;
				}
				head = tail = NULL;
			}
		;

kind		:	KW_INT 
			{	 
				type_indicator++;
				type_indicator %= 2;	
				type[type_indicator] = 1; 
			}
		|	KW_FLOAT 
			{
				type_indicator++;
				type_indicator %= 2;	
				type[type_indicator] = 2;
			}
		;

stmt		:	expr SEMICOLON 
		|	KW_IF LPAR bool_expr RPAR stmt opt_else 
		|	KW_WHILE LPAR bool_expr RPAR stmt 
		|	KW_WHILE LPAR bool_expr RPAR body
		|	KW_READ var_list SEMICOLON 
		|	KW_WRITE write_expr_list SEMICOLON 
		|	KW_RETURN expr SEMICOLON 
		;

write_expr_list	:	wlist_unit wlist_rep
		;

wlist_unit 	:	expr
		|	STRING_LIT
		;

wlist_rep	:	
		|	wlist_rep COMMA wlist_unit
		;

var_list	:	ID 
			{
				if(head == NULL) {
					head = (sym *)malloc(sizeof(sym));

					strcpy(head->name, yylval);

					if(type[type_indicator] == 1)	strcpy(head->val_type, "int");
					else				strcpy(head->val_type, "float");
					
					head->isGlobal = global;
					head->lineno = yylineno;

					head->declared = false;
					head->implemented = false;
					head->next = NULL;

					tail = head;		
				}	
				
			} 
			var_list_rep
		;

var_list_rep	:	
		|	var_list_rep COMMA ID 
			{	
				if(tail != NULL) {
					tail->next = (sym *)malloc(sizeof(sym));
					tail = tail->next;

					strcpy(tail->name, yylval);

					if(type[type_indicator] == 1)	strcpy(tail->val_type, "int");
					else				strcpy(tail->val_type, "float");

					tail->isGlobal = global;
					tail->lineno = yylineno;

					head->declared = false;
					head->implemented = false;
					tail->next = NULL;
				}
			}
		;

opt_else	:	
		|	KW_ELSE stmt
		;

bool_expr	:	expr bool_op expr 
		;

bool_op		:	OP_EQ
		|	OP_LT
		|	OP_LE
		|	OP_GT
		|	OP_GE
		;

expr		:	ID 
			{
				funcAsVar = false;
				found = false;

				if(ltable != NULL) {
					temp = ltable;
					while(temp != NULL) {
						if(strcmp(temp->name, yylval) == 0 && !(temp->declared) && !(temp->implemented)) {
							printf("Local %s variable %s declared in line %d used in line %d.\n", 
								temp->val_type, temp->name, temp->lineno, yylineno);
							found = true;
							break;
						}
						temp = temp->next;
					}
				}
				if(found == false && gtable != NULL) {
					temp = gtable;
					while(temp != NULL) {
						if(strcmp(temp->name, yylval) == 0 && !(temp->declared) && !(temp->implemented)) {
							printf("Global %s variable %s declared in line %d used in line %d.\n", 
								temp->val_type, temp->name, temp->lineno, yylineno);
							found = true;
							break;
						}
						if(strcmp(temp->name, yylval) == 0 && (temp->declared || temp->implemented)) {
							funcAsVar = true;
						}
						temp = temp->next;
					}
				}
				if(!found) {
					if(funcAsVar)
						printf("ERROR line %d: function %s used as a variable.\n", yylineno, yylval);
					else
						printf("ERROR line %d: variable %s not declared.\n", yylval);
				}
			} 
			OP_ASSIGN expr 
		|	expr1	
		;

expr1		:	expr1 OP_PLUS expr1
		|	expr1 OP_MINUS expr1
		|	expr1 OP_MULT expr1
		|	expr1 OP_DIV expr1
		|	OP_MINUS factor %prec UMINUS
		|	factor
		;

factor		:	INT_LIT 
		| 	FLOAT_LIT 
		| 	function_call 
		| 	LPAR expr RPAR
		|	ID
			{
				found = false;
				if(ltable != NULL) {
					temp = ltable;
					while(temp != NULL) {
						if(strcmp(temp->name, yylval) == 0 && !(temp->declared) && !(temp->implemented)) {
							printf("Local %s variable %s declared in line %d used in line %d.\n", 
								temp->val_type, temp->name, temp->lineno, yylineno);
							found = true;
							break;
						}
						temp = temp->next;
					}
				}
				if(found == false && gtable != NULL) {
					temp = gtable;
					while(temp != NULL) {
						if(strcmp(temp->name, yylval) == 0 && !(temp->declared) && !(temp->implemented)) {
							printf("Global %s variable %s declared in line %d used in line %d.\n", 
								temp->val_type, temp->name, temp->lineno, yylineno);
							found = true;
							break;
						}
						temp = temp->next;
					}
				}
				if(!found)
					printf("Variable %s not declared.\n", yylval);
			} 
		;

function_call	:	ID 
			{
				found = false;
				if(ltable != NULL) {
					temp = ltable;
					while(temp != NULL) {
						if(strcmp(temp->name, yylval) == 0 && !(temp->declared) && !(temp->implemented)) {
							printf("ERROR line %d: variable %s used as function.\n", yylineno, temp->name);
							found = true;
							break;
						}
						temp = temp->next;
					}
				}
				if(found == false && gtable != NULL) {
					temp = gtable;
					while(temp != NULL) {
						if(strcmp(temp->name, yylval) == 0) {
							if(temp->implemented) {
								printf("Function %s defined in line %d used in line %d.\n", temp->name, temp->lineno, yylineno);
								found = true;
								break;
							}
							else {
								printf("ERROR line %d: no definition for function %s.\n", yylineno, yylval);
								found = true;
								break;

							}
						}
						temp = temp->next;
					}
				}
			}
			LPAR expr RPAR 
		;

%%

main(int argc, char **argv)
{
	yyparse();
}

yyerror(char *s)
{
	fprintf(stderr, "error: %s, line: %d\n", s, yylineno);
}
