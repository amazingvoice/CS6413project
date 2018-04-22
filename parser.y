%{									/* Qing Zhang(qz761)	CS6413 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#define TYPE_INVALID 0
#define TYPE_INT 1
#define TYPE_FLOAT 2

char *data_type[3] = {"INVALID", "int", "float"};

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
	int  val_type;
	int  ret_type;
	bool isGlobal;
	int  lineno;

	// function only
	bool declared;	
	bool implemented;
	bool called;
	int  decl_lineno;	
	int  def_lineno;

	struct symbol *next;
} sym;

sym *ltable = NULL;
sym *gtable = NULL;

sym *head = NULL; // head of var_list
sym *tail = NULL; // tail of var_list
sym *temp = NULL;

int t_val;
int t_ret;

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

struct ast * newast(int, struct ast *, struct ast *);
struct ast * newnum(double, int);
struct ast * newid(double, int, char *, int, int);

%}

/* ==========================================================  */

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

					t_val = type[type_indicator++];
					type_indicator %= 2;
					t_ret = type[type_indicator];
					
					temp = gtable;
					found = false;
					
					// check for function redeclaration
					while(temp != NULL) {	// search in the global table

						if(strcmp(temp->name, $2) == 0) {
							
							found = true; // found the same name in global table

							if(temp->declared) {
								if(temp->ret_type != t_ret || temp->val_type != t_val) {
									redeclared = true;
									printf("ERROR: redeclaring %s with different signature in line %d.\n", 
																							$2, yylineno);
								}
							}
							else {
								redeclared = true;
								printf("ERROR: redeclaring variable %s as a function in line %d.\n", 
																					$2, yylineno);
							}
							break;
						}

						temp = temp->next;
					}

					if(!found) {	/* function is not redeclared */

						temp = (sym *)malloc(sizeof(sym));
						
						strcpy(temp->name, $2);
						temp->ret_type = t_ret;
						temp->val_type = t_val;
						temp->declared = true;
						temp->implemented = false;
						temp->called = false;
						temp->decl_lineno = yylineno;
						
								
						/* add to the head of the gtable list */
						/* CAUTION**: test if gtable is empty */
						if(gtable != NULL) {
							temp->next = gtable->next;
							gtable->next = temp;
						}
						else {
							temp->next = NULL;
							gtable = temp;
						}
					}
					
					if(!redeclared) {
						printf("function %s %s(%s) declared in line %d\n", 
									data_type[t_ret], $2, data_type[t_val], yylineno);
					}
				}
			|	error SEMICOLON {yyerrok; }
			;

function_def	:	kind ID LPAR kind ID RPAR 
					{
						bool mismatched = false;
						
						t_val = type[type_indicator++];
						type_indicator %= 2;
						t_ret = type[type_indicator];

						temp = gtable;
						found = false;

						// check if function definition mismatched with declaration
						while(temp != NULL) {	// search for function decl in global table

							if((strcmp(temp->name, $2) == 0) && (temp->declared)) {
								
								found = true; // function decl found

								if(temp->ret_type != t_ret || temp->val_type != t_val) {	
									// mismatched with decl
									
									mismatched = true;
									printf("ERROR: definition(line: %d) with mismatched signature(line %d) \n", 
																				yylineno, temp->decl_lineno);
									break;
								}
								
								break;
							} //declaration found

							temp = temp->next;
						}

						if(!found) { // no declaration

							temp = (sym *)malloc(sizeof(sym));

							strcpy(temp->name, $2);
							temp->ret_type = t_ret;
							temp->val_type = t_val;
							temp->declared = false;
							temp->implemented = true;
							temp->called = false;
							temp->def_lineno = yylineno;

							/* add to the head of the gtable list */
							/* CAUTION**: test if gtable is empty */
							if(gtable != NULL) {
								temp->next = gtable->next;
								gtable->next = temp;
							}
							else {
								temp->next = NULL;
								gtable = temp;
							}
						}

						if(!mismatched) {

							printf("function %s defined in line %d\n", $2, yylineno);
							temp->implemented = true;
							temp->def_lineno = yylineno;

							global = false;	// entered local scope

							/* ==== add function parameter to local table ==== */
						
							temp = (sym *)malloc(sizeof(sym));

							strcpy(temp->name, $5);
							temp->val_type = t_val;
							temp->isGlobal = false;
							temp->lineno = yylineno;
						
							temp->declared = false;
							temp->implemented = false;
							temp->next = NULL;

							ltable = temp;

							printf("Local %s variable %s declared in line %d\n", 
												data_type[t_val], $5, yylineno);
						}
					}
					body
					{
						global = true; // local scope ended
						
						/* free up memory for local table */
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
				// search for variable redeclaration
				while(head != NULL) { // head of var_list is not null

					found = false;

					/* search for local redeclaration */
					if(!global && ltable != NULL) { 

						temp = ltable;

						while(temp != NULL) { /* loop through local symbol table */

							if(strcmp(temp->name, head->name) == 0) { // redeclaration found

								if(temp->val_type == head->val_type) {
									printf("ERROR: Redeclaring local variable %s in line %d.\n", 
																		temp->name, yylineno);
								}
								else {
									printf("ERROR: Redeclaring local variable %s with different type in line %d.\n", 
																							temp->name, yylineno);
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

							if(strcmp(temp->name, head->name) == 0 && 
									!(temp->declared) && !(temp->implemented)) {
								if(temp->val_type == head->val_type) {
									printf("ERROR: Redeclaring global variable %s in line %d.\n", 
																		temp->name, yylineno);
								}
								else {
									printf("ERROR: Redeclaring global variable %s with different type in line %d.\n", 
																							temp->name, yylineno);
								}

								found = true;
								break;
							}
							/* funcAsVar*/
							if(strcmp(temp->name, head->name) == 0 && 
									(temp->declared || temp->implemented)) {
								
								printf("ERROR: Redeclaring a function as a global variable %s in line %d.\n", 
																						temp->name, yylineno);
								
								found = true;
								break;
							}

							temp = temp->next;
						}
					}

					if(!found) { /* no redeclaration */

						global ? printf("Global ") : printf("Local ");
						printf("%s variable %s declared in line %d.\n", 
										data_type[head->val_type], head->name, head->lineno);
						
						// add to corresponding table
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
					else { /* found redeclaration, release memory for this variable */
						temp = head;
						head = head->next;
						free(temp);
					}

				} /* while(head != NULL) */
				temp = head = tail = NULL;

			} /* end action for decl */
		|	kind error SEMICOLON 
			{
				while(head != NULL) {
					temp = head;
					head = head->next;
					free(temp);
				}
				yyerrok;
			}
		;

kind	:	KW_INT 
			{	 
				type_indicator++;
				type_indicator %= 2;	
				type[type_indicator] = TYPE_INT; 
			}
		|	KW_FLOAT 
			{
				type_indicator++;
				type_indicator %= 2;	
				type[type_indicator] = TYPE_FLOAT;
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
														data_type[temp->val_type], temp->name, temp->lineno, yylineno);
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
														data_type[temp->val_type], temp->name, temp->lineno, yylineno);
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
									printf("ERROR line %d: function %s used as a variable.\n", yylineno, head->name);
								else
									printf("ERROR line %d: variable %s not declared.\n", yylineno, head->name);
							}
							
							temp = head;
							head = head->next;
							free(temp);
		 
						} /* var_list loop */
						head = tail = NULL;
					}
				|	KW_READ error SEMICOLON
				|	KW_WRITE write_expr_list SEMICOLON 
				|	KW_WRITE error SEMICOLON
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

						strcpy(head->name, $1);

						head->val_type = type[type_indicator];
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

							strcpy(tail->name, $3);

							tail->val_type = type[type_indicator];
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
										data_type[temp->val_type], temp->name, temp->lineno, yylineno);

								// AST =======================================================================

								if($3->datatype != temp->val_type) {
								
									printf("ERROR: Value of wrong type assigned to %s variable %s. Line: %d.\n",
																		data_type[temp->val_type], temp->name, yylineno);
									$$ = NULL;
								}
								else {
									$$ = $3;
								}
								// ===========================================================================

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

								// AST =======================================================================

								if($3->datatype != temp->val_type) {
									
									printf("ERROR: Value of wrong type assigned to %s variable %s. Line: %d.\n",
																		temp->val_type, temp->name, yylineno);
									$$ = NULL;
								}
								else {
									$$ = $3;
								}
								// ===========================================================================

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
							printf("ERROR line %d: function %s used as a variable.\n", yylineno, $1);
						else {
							printf("ERROR line %d: variable %s not declared.\n", yylineno, $1);
							// AST
							$$ = NULL;
						}
					}
				} 
			|	expr1
			;

expr1		:	expr1 OP_PLUS expr1 
				{ 
					$$ = newast('+', $1, $3);

					if($1->datatype != $3->datatype) { // error: mixed types in arithmetic op
						
						if($1->nodetype == 'I') {
							struct idval *temp = (struct idval *)$1;
							printf("ERROR: Adding %s \"%s\" (declared on line %d) to ", 
									data_type[temp->datatype], temp->name, temp->decl_lineno);
						}
						else {
							printf("ERROR: Adding %s value to ", data_type[$1->datatype]);
						}

						if($3->nodetype == 'I') {
							struct idval *temp = (struct idval *)$3;
							printf("%s \"%s\" (declared on line %d). Line: %d\n", 
									data_type[temp->datatype], temp->name, temp->decl_lineno, yylineno);
						}
						else {
							printf("%s value. Line: %d\n", data_type[$3->datatype], yylineno);
						}
					}
				}
			|	expr1 OP_MINUS expr1 
				{
					$$ = newast('-', $1, $3);

					if($1->datatype != $3->datatype) { // error: mixed types in arithmetic op

						if($1->nodetype == 'I') {
							struct idval *temp = (struct idval *)$1;
							printf("ERROR: From %s \"%s\" (declared on line %d) ", 
									data_type[temp->datatype], temp->name, temp->decl_lineno);
						}
						else {
							printf("ERROR: From %s value ", data_type[$1->datatype]);
						}

						if($3->nodetype == 'I') {
							struct idval *temp = (struct idval *)$3;
							printf("subtract %s \"%s\" (declared on line %d). Line: %d\n", 
									data_type[temp->datatype], temp->name, temp->decl_lineno, yylineno);
						}
						else {
							printf("subtract %s value. Line: %d\n", data_type[$3->datatype], yylineno);
						}

					}
				}
			|	expr1 OP_MULT expr1 
				{
					$$ = newast('*', $1, $3);

 					if($1->datatype != $3->datatype) { // error: mixed types in arithmetic op

						if($1->nodetype == 'I') {
							struct idval *temp = (struct idval *)$1;
							printf("ERROR: Multiplying %s \"%s\" (declared on line %d) by ", 
									data_type[temp->datatype], temp->name, temp->decl_lineno);
						}
						else {
							printf("ERROR: Multiplying %s value by ", data_type[$1->datatype]);
						}

						if($3->nodetype == 'I') {
							struct idval *temp = (struct idval *)$3;
							printf("%s \"%s\" (declared on line %d). Line: %d\n", 
									data_type[temp->datatype], temp->name, temp->decl_lineno, yylineno);
						}
						else {
							printf("%s value. Line: %d\n", data_type[$3->datatype], yylineno);
						}

					}
				}
			|	expr1 OP_DIV expr1 
				{
					$$ = newast('/', $1, $3);

					if($1->datatype != $3->datatype) { // error: mixed types in arithmetic op

						if($1->nodetype == 'I') {
							struct idval *temp = (struct idval *)$1;
							printf("ERROR: dividing %s \"%s\" (declared on line %d) by ", 
									data_type[temp->datatype], temp->name, temp->decl_lineno);
						}
						else {
							printf("ERROR: dividing %s value by ", data_type[$1->datatype]);
						}

						if($3->nodetype == 'I') {
							struct idval *temp = (struct idval *)$3;
							printf("%s \"%s\" (declared on line %d). Line: %d\n", 
								data_type[temp->datatype], temp->name, temp->decl_lineno, yylineno);
						}
						else {
							printf("%s value. Line: %d\n", data_type[$3->datatype], yylineno);
						}
					}
				}
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
							if(strcmp(temp->name, $1) == 0) {
								printf("Local %s variable %s declared in line %d used in line %d.\n", 
												data_type[temp->val_type], temp->name, temp->lineno, yylineno);
								
								// AST TODO: temporary ID value
								$$ = newid(0.0, temp->val_type, temp->name, temp->lineno, yylineno);

								found = true;
								break;
							}
							temp = temp->next;
						}
					}
					if(found == false && gtable != NULL) {
						temp = gtable;
						while(temp != NULL) {
							if(strcmp(temp->name, $1) == 0 && !(temp->declared) && !(temp->implemented)) {
								printf("Global %s variable %s declared in line %d used in line %d.\n", 
												data_type[temp->val_type], temp->name, temp->lineno, yylineno);
								
								// AST TODO: temporary ID value
								$$ = newid(0.0, temp->val_type, temp->name, temp->lineno, yylineno);

								found = true;
								break;
							}
							if(strcmp(temp->name, $1) == 0 && (temp->declared || temp->implemented)) {
								funcAsVar = true;
								// AST
								$$ = newid(0.0, TYPE_INVALID, $1, 0, yylineno);
							}
							temp = temp->next;
						}
					}
					if(!found) {
						if(funcAsVar)
							printf("ERROR line %d: function %s used as a variable.\n", yylineno, $1);
						else {
							printf("ERROR line %d: variable %s not declared.\n", yylineno, $1);
							// AST
							$$ = newid(0.0, TYPE_INVALID, $1, 0, yylineno);
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
									$$ = newnum(0.0, TYPE_INVALID);

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
										$$ = newnum(0.0, temp->ret_type);

										if($3->datatype != temp->val_type) {
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
										$$ = newnum(0.0, temp->ret_type);
										
										if($3->datatype != temp->val_type) {
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
										$$ = newnum(0.0, TYPE_INVALID);
									}
								}
								temp = temp->next;
							}
							if(!found) {
								if(varAsFunc)
									printf("ERROR line %d: variable %s used as a function.\n", yylineno, $1);
								else {
									printf("ERROR line %d: function %s is not declared.\n", yylineno, $1);
									// AST
									$$ = newnum(0.0, TYPE_INVALID);
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

struct ast * newast(int nodetype, struct ast *l, struct ast *r) {
	struct ast *a = (struct ast *)malloc(sizeof(struct ast));
	a->nodetype = nodetype;
	if(nodetype == 'M')
		a->datatype = l->datatype;
	else
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

