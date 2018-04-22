%{									/* Qing Zhang(qz761)	CS6413 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#define TYPE_INVALID -1
#define TYPE_INT 1
#define TYPE_FLOAT 2

/* interface to the lexer */
extern int yylineno;
extern char second_to_last_id[50];
extern char last_id[50];

/* type indicator */
int type[2];
int type_indicator = 0;

/* symbol table */
typedef struct symbol {
	char name[50];
	char val_type[10];
	char ret_type[10];
	bool isGlobal;
	bool declared;
	bool implemented;
	bool called;
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

char *t_val;
char *t_ret;

/* flags */
bool global = true;
bool found = false;
bool funcAsVar = false;
bool varAsFunc = false;
bool syntax_error = false;

/* AST */
struct ast {
	int nodetype;
	int datatype;
	struct ast *l;
	struct ast *r;
};

struct numval {
	int nodetype;
	int datatype;
	double val;
};

struct idval {
	int nodetype;
	int datatype;
	double val;
	char name[50];
	int decl_lineno;
	int lineno;
};

struct ast * newast(int nodetype, struct ast *l, struct ast *r) {
	struct ast *a = (struct ast *)malloc(sizeof(struct ast));
	a->nodetype = nodetype;
	a->datatype = ( (l->datatype == r->datatype) ? l->datatype : TYPE_INVALID );
	a->l = l;
	a->r = r;
	return a;
}

struct ast * newnum(double d, int datatype) {
	struct numval *a = (struct numval *)malloc(sizeof(struct numval));
	a->nodetype = 'N';
	a->datatype = datatype;
	a->val = d;
	return (struct ast *)a;
}

struct ast * newid(double d, int datatype, char *name, int dln, int ln) {
	struct idval *a = (struct idval *)malloc(sizeof(struct idval));
	a->nodetype = 'I';
	a->datatype = datatype;
	a->val = d;
	strcpy(a->name, name);
	a->decl_lineno = dln;
	a->lineno = ln;
	return (struct ast *)a;
}

%}


%union {
	int i;
	double d;
	char *s;
	struct ast *a;
}

/* token decl */
%token	<s> ID
%token	KW_INT KW_FLOAT
%token  <i> INT_LIT 
%token  <d> FLOAT_LIT 
%token	<s> STRING_LIT
%token	KW_IF
%token	KW_ELSE
%token	KW_WHILE
%token	KW_RETURN
%token	KW_READ KW_WRITE
%token 	LPAR RPAR
%token 	LBRACE RBRACE
%token 	SEMICOLON
%token 	COMMA
%token 	NL_TOKEN
%token 	WS_TOKEN

/* precedence decls : the ones declared later have higher precdedence */
%right OP_ASSIGN
%nonassoc OP_EQ OP_LT OP_LE OP_GT OP_GE
%left OP_PLUS OP_MINUS
%left OP_MULT OP_DIV
%nonassoc UMINUS

%type <a> expr expr1 factor function_call

/* allow for more accurate syntax error messages */
%locations	
%define parse.error verbose

%%

program	:	
		|	program function_def
		|	program decl		
		|	program function_decl
		;

function_decl:	kind ID LPAR kind RPAR SEMICOLON 
				{
					bool redeclared = false;

					t_val = ((type[type_indicator++] == 1) ? "int" : "float");
					type_indicator %= 2;
					t_ret = ((type[type_indicator] == 1) ? "int" : "float");
					
					temp = gtable;
					found = false;
					while(temp != NULL) {
						if(strcmp(temp->name, yylval.s) ==  0 && temp->declared) {
							
							if(temp->ret_type != t_ret || temp->val_type != t_val) {

								printf("ERROR: redeclaring %s with different \
									signature in line %d.\n", yylval, yylineno);

								redeclared = true;	
								break;
							}
							found = true;
							break;
						}
						temp = temp->next;
					}
					if(!found && !redeclared) { /* no function redeclaration */
						temp = (sym *)malloc(sizeof(sym));
						strcpy(temp->name, yylval.s);
						strcpy(temp->ret_type, t_ret);
						strcpy(temp->val_type, t_val);
						temp->declared = true;
						temp->implemented = false;
						temp->called = false;
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

					if(!redeclared)
						printf("function %s %s(%s) declared in line %d\n", 
									t_ret, yylval, t_val, yylineno);
				}
			|	error SEMICOLON {yyerrok; }
			;

function_def	:	kind ID LPAR kind ID RPAR 
					{
						bool bad_sig = false;

						t_val = ((type[type_indicator] == 1) ? "int" : "float");
						t_ret = ((type[(type_indicator + 1) % 2] == 1) ? "int" : "float");

						temp = gtable;
						found = false;

						while(temp != NULL) { // check if mismatched with declaration
							if((strcmp(temp->name, second_to_last_id) == 0) && (temp->declared)) {
								if(strcmp(temp->ret_type, t_ret) != 0 || strcmp(temp->val_type, t_val) != 0) {
									printf("ERROR: definition(line: %d) with mismatched \ 
											signature(line %d) \n", yylineno, temp->decl_lineno);
									bad_sig = true;
									break;
								}
								temp->implemented = true;
								found = true;
								break;
							}
							temp = temp->next;
						}

						if(!found) { // no declaration

							temp = (sym *)malloc(sizeof(sym));
							strcpy(temp->name, second_to_last_id); /* function name */
							strcpy(temp->ret_type, t_ret);
							strcpy(temp->val_type, t_val);
							temp->declared = false;
							temp->implemented = true;
							temp->called = false;
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
						
						if(!bad_sig) { // function decl exists and matches the definition
							
							printf("function %s defined in line %d\n", second_to_last_id, yylineno);
							temp->implemented = true;
							temp->def_lineno = yylineno;
							global = false;

							/* add function parameter to local table */
						
							temp = (sym *)malloc(sizeof(sym));
							strcpy(temp->name, yylval.s);

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

body	:	LBRACE decls stmts RBRACE
		;

decls	:	
		|	decls decl
		;

stmts	:	
		|	stmts stmt
		|	LBRACE stmts RBRACE
		;

decl	:	kind var_list SEMICOLON 
			{
				while(head != NULL) {

					found = false;

					/* search for local redeclaration */
					if(!global && ltable != NULL) { 

						temp = ltable;

						while(temp != NULL) { /* loop through local symbol table */

							if(strcmp(temp->name, head->name) == 0) {

								if(strcmp(temp->val_type, head->val_type) == 0) {
									printf("ERROR: Redeclaring local variable %s in line %d.\n", 
																		temp->name, yylineno);
								}
								else {
									printf("ERROR: Redeclaring local variable %s with different \
													type in line %d.\n", temp->name, yylineno);
								}
								found = true;
								break;
							}

							temp = temp->next;
						}
					}
					/* search for global redeclaration */
					if(global && gtable != NULL) { 

						temp = gtable;

						while(temp != NULL) { /* loop for global symbol table */

							if(strcmp(temp->name, head->name) == 0 && !(temp->declared) && !(temp->implemented)) {
								if(strcmp(temp->val_type, head->val_type) == 0) {
									printf("ERROR: Redeclaring global variable %s in line %d.\n", 
																		temp->name, yylineno);
								}
								else {
									printf("ERROR: Redeclaring global variable %s with different \
													type in line %d.\n", temp->name, yylineno);
								}

								found = true;
								break;
							}
							/* funcAsVar*/
							if(strcmp(temp->name, head->name) == 0 && (temp->declared || temp->implemented)) {
								
								printf("ERROR: Redeclaring a function as a global variable %s \
														in line %d.\n", temp->name, yylineno);
								
								found = true;
								break;
							}

							temp = temp->next;
						}
					}

					if(!found) { /* no redeclaration */

						if(head->isGlobal) printf("Global "); 
						else		  printf("Local ");
						printf("%s variable %s declared in line %d.\n", 
										head->val_type, head->name, head->lineno);

						if(global) { /* add to gtable */
							temp = head;
							head = head->next;
							if(gtable != NULL) {
								temp->next = gtable->next;
								gtable->next = temp;
							}
							else {
								temp->next = NULL;
								gtable = temp;
							}
						}
						else { /* add to ltable */
							temp = head;
							head = head->next;
							if(ltable != NULL) {
								temp->next = ltable->next;
								ltable->next = temp;
							}
							else {
								temp->next = NULL;
								ltable = temp;
							}
						}
					}
					else { /* found redeclaration, release memory */
						temp = head;
						head = head->next;
						free(temp);
					}

				} /* while(head != NULL) */
				temp = head = tail = NULL;

			} /* end action for decl */
		;

kind	:	KW_INT 
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

stmt	:	matched_stmt
		|	open_stmt
		;

open_stmt	:	KW_IF LPAR bool_expr RPAR stmt
			|	KW_IF LPAR bool_expr RPAR matched_stmt KW_ELSE open_stmt
			;

matched_stmt	:	expr SEMICOLON 
				|	KW_WHILE LPAR bool_expr RPAR stmt 
				|	KW_WHILE LPAR bool_expr RPAR body
				|	KW_READ var_list SEMICOLON
					{
						while(head != NULL) { /* loop for var_list */
							
							funcAsVar = false;
							found = false;

							if(ltable != NULL) {
								temp = ltable;
								while(temp != NULL) { /* loop for local symbol table */
									if(strcmp(head->name, temp->name) == 0) {
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
								while(temp != NULL) { /* loop for global symbol table */
									if(strcmp(head->name, temp->name) == 0 && !(temp->declared) && !(temp->implemented)) {
										printf("Global %s variable %s declared in line %d used in line %d.\n", 
														temp->val_type, temp->name, temp->lineno, yylineno);
										found = true;
										break;
									}
									if(strcmp(head->name, temp->name) == 0 && (head->declared || head->implemented)) {
										funcAsVar = true;
									}

									temp = temp->next;
								}
							}
							if(!found) {
								if(funcAsVar)
									printf("ERROR line %d: function %s used as a variable.\n", yylineno, yylval);
								else
									printf("ERROR line %d: variable %s not declared.\n", yylineno, yylval);
							}
							
							temp = head;
							head = head->next;
							free(temp);
		 
						} /* var_list loop */
						head = tail = NULL;
					}
				|	KW_WRITE write_expr_list SEMICOLON 
				|	KW_RETURN expr SEMICOLON
				|	KW_IF LPAR bool_expr RPAR matched_stmt KW_ELSE matched_stmt
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

						strcpy(head->name, yylval.s);

						if(type[type_indicator] == 1)	strcpy(head->val_type, "int");
						else				strcpy(head->val_type, "float");
						
						head->isGlobal = global;
						head->lineno = yylineno;

						head->declared = false;
						head->implemented = false;
						head->next = NULL;

						tail = head;		
					}
					else {
						printf("ERROR line %d: head is not NULL.\n", yylineno);
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

							strcpy(tail->name, yylval.s);

							if(type[type_indicator] == 1)	strcpy(tail->val_type, "int");
							else				strcpy(tail->val_type, "float");

							tail->isGlobal = global;
							tail->lineno = yylineno;

							head->declared = false;
							head->implemented = false;
							tail->next = NULL;
						}
						else {
							printf("ERROR line %d: tail is NULL.\n", yylineno);
						}
					}
				;

bool_expr	:	expr bool_op expr 
			;

bool_op		:	OP_EQ
			|	OP_LT
			|	OP_LE
			|	OP_GT
			|	OP_GE
			;

expr		:	ID OP_ASSIGN expr
				{
					funcAsVar = false;
					found = false;

					if(ltable != NULL) {
						temp = ltable;
						while(temp != NULL) { /* local symbol table */
							if(strcmp(temp->name, $1) == 0) {
								printf("Local %s variable %s declared in line %d used in line %d.\n", 
									temp->val_type, temp->name, temp->lineno, yylineno);

								// AST
								$$ = $3;

								found = true;
								break;
							}
							temp = temp->next;
						}
					}
					if(found == false && gtable != NULL) {
						temp = gtable;
						while(temp != NULL) { /* global symbol table */
							if(strcmp(temp->name, $1) == 0 && !(temp->declared) && !(temp->implemented)) {
								printf("Global %s variable %s declared in line %d used in line %d.\n", 
									temp->val_type, temp->name, temp->lineno, yylineno);

								// AST
								$$ = $3;

								found = true;
								break;
							}
							if(strcmp(temp->name, $1) == 0 && (temp->declared || temp->implemented)) {
								funcAsVar = true;
								$$ = NULL;
							}
							temp = temp->next;
						}
					}
					if(!found) {
						if(funcAsVar)
							printf("ERROR line %d: function %s used as a variable.\n", yylineno, yylval);
						else {
							printf("ERROR line %d: variable %s not declared.\n", yylineno, yylval);
							// AST
							$$ = NULL;
						}
					}
				} 
			|	expr1
			;

expr1		:	expr1 OP_PLUS expr1 { $$ = newast('+', $1, $3); }
			|	expr1 OP_MINUS expr1 { $$ = newast('-', $1, $3); }
			|	expr1 OP_MULT expr1 { $$ = newast('*', $1, $3); }
			|	expr1 OP_DIV expr1 { $$ = newast('/', $1, $3); }
			|	OP_MINUS factor %prec UMINUS { $$ = newast('M', $2, NULL); }
			|	factor
			;

factor		:	INT_LIT { $$ = newnum($1, TYPE_INT); } 
			| 	FLOAT_LIT { $$ = newnum($1, TYPE_FLOAT); }
			| 	function_call 
			| 	LPAR expr RPAR { $$ = $2; }
			|	ID
				{
					found = false;
					funcAsVar = false;

					if(ltable != NULL) {
						temp = ltable;
						while(temp != NULL) {
							if(strcmp(temp->name, yylval.s) == 0) {
								printf("Local %s variable %s declared in line %d used in line %d.\n", 
												temp->val_type, temp->name, temp->lineno, yylineno);
								
								// AST TODO: temporary ID value
								$$ = newid(0.0, (strcmp(temp->val_type, "int") ? TYPE_FLOAT : TYPE_INT), 
																temp->name, temp->lineno, yylineno);

								found = true;
								break;
							}
							temp = temp->next;
						}
					}
					if(found == false && gtable != NULL) {
						temp = gtable;
						while(temp != NULL) {
							if(strcmp(temp->name, yylval.s) == 0 && !(temp->declared) && !(temp->implemented)) {
								printf("Global %s variable %s declared in line %d used in line %d.\n", 
												temp->val_type, temp->name, temp->lineno, yylineno);
								
								// AST TODO: temporary ID value
								$$ = newid(0.0, (strcmp(temp->val_type, "int") ? TYPE_FLOAT : TYPE_INT), 
																temp->name, temp->lineno, yylineno);

								found = true;
								break;
							}
							if(strcmp(temp->name, yylval.s) == 0 && (temp->declared || temp->implemented)) {
								funcAsVar = true;
								// AST
								$$ = NULL;
							}
							temp = temp->next;
						}
					}
					if(!found) {
						if(funcAsVar)
							printf("ERROR line %d: function %s used as a variable.\n", yylineno, yylval);
						else {
							printf("ERROR line %d: variable %s not declared.\n", yylineno, yylval);
							// AST
							$$ = NULL;
						}
					}
				} /* action for ID */
			;

function_call	:	ID LPAR expr RPAR 
					{
						varAsFunc = false;
						found = false;

						if(ltable != NULL) {
							temp = ltable;
							while(temp != NULL) { /* check if a variable is used as a function */
								if(strcmp(temp->name, $1) == 0) {
									printf("ERROR line %d: variable %s used as function.\n", 
																		yylineno, temp->name);

									// AST
									$$ = NULL;

									found = true;
									break;
								}
								temp = temp->next;
							}
						}
						if(found == false && gtable != NULL) {
							temp = gtable;
							while(temp != NULL) {
								if(strcmp(temp->name, $1) == 0) {
									if(temp->implemented) {
										temp->called = true;
										printf("Function %s defined in line %d used in line %d.\n", 
															temp->name, temp->def_lineno, yylineno);
										// AST ==================================================================
										$$ = newnum(0.0, (strcmp(temp->ret_type, "int") ? TYPE_FLOAT : TYPE_INT));

										if( ($3->datatype == TYPE_INT && !strcmp(temp->val_type, "float")) || 
												($3->datatype == TYPE_FLOAT && !strcmp(temp->val_type, "int")) ) {
											printf("ERROR: Function %s called with wrong parameter type. Line: %d.\n",
																						temp->name, yylineno);
										}
										// ======================================================================
										found = true;
										break;
									}
									else if(temp->declared) {
										temp->called = true;
										printf("Function %s declared in line %d used in line %d.\n", 
															temp->name, temp->decl_lineno, yylineno);
										// AST ==================================================================
										$$ = newnum(0.0, (strcmp(temp->ret_type, "int") ? TYPE_FLOAT : TYPE_INT));
										
										if( ($3->datatype == TYPE_INT && !strcmp(temp->val_type, "float")) || 
												($3->datatype == TYPE_FLOAT && !strcmp(temp->val_type, "int")) ) {
											printf("ERROR: Function %s called with wrong parameter type. Line: %d.\n",
																						temp->name, yylineno);
										}
										// ======================================================================
										found = true;
										break;
									}
									else {
										varAsFunc = true;
										//AST
										$$ = NULL;
									}
								}
								temp = temp->next;
							}
							if(!found) {
								if(varAsFunc)
									printf("ERROR line %d: variable %s used as a function.\n", yylineno, yylval);
								else {
									printf("ERROR line %d: function %s is not declared.\n", yylineno, yylval);
									// AST
									$$ = NULL;
								}
							}
						}
					} /* action for function_call */
				;

%%

main(int argc, char **argv)
{
	yyparse();
	while(gtable != NULL && !syntax_error) {
		if(gtable->called && !(gtable->implemented)) {
			printf("ERROR: function %s called but not implemented.\n", gtable->name);
		}
		temp = gtable;
		gtable = gtable->next;
		free(temp);
	}
}

yyerror(char *s)
{
	syntax_error = true;
	fprintf(stderr, "ERROR: %s, line: %d\n", s, yylineno);
}
