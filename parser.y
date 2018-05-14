%{									/* Qing Zhang(qz761)	CS6413 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <fcntl.h>

#define TYPE_INVALID 0
#define TYPE_INT 1
#define TYPE_FLOAT 2

FILE *fd; // target code file descriptor

// data type format converter (for print use)
char *data_type[3] = {"INVALID", "int", "float"};

/* interface to the lexer */
extern int yylineno;
extern isIF;
extern isWHILE;
extern isELSE;

/* type indicator */
int type[2];
int type_indicator = 0;

/* memory location */
int next_mem_loc = 0;
int bak_mem_loc;

/* label */
int start_label = -1;
int next_label = 0;

/* symbol table */
typedef struct symbol {
	
	char name[50];
	int  val_type;
	int  ret_type;
	bool isGlobal;
	int  lineno;
	int  mem_loc;

	// function only
	bool declared;	
	bool implemented;
	bool called;
	int  decl_lineno;	
	int  def_lineno;

	int  label;
	int  ret_mem_loc;
	double  ret_val;  // if ret_mem_loc == -1, this function returns a constant instead of a memloc

	struct symbol *next;
} sym;

// temporary variables
sym *ltable = NULL;
sym *gtable = NULL;

sym *head = NULL; // head of var_list
sym *tail = NULL; // tail of var_list
sym *temp = NULL;
sym *current_func = NULL;

int t_val;
int t_ret;

/* flags */
bool global = true;
bool found = false;
bool funcAsVar = false;
bool varAsFunc = false;
bool syntax_error = false;
bool isDecl = true;
bool isWhile = false;
bool IFblock = false;

// Stack (for embedded while and if stmt)
int whileStack[100];
int ifStack[100];
int elseStack[100];

// stack pointer
int sp_while = 0;
int sp_if = 0;
int sp_else = 0;

/* AST */
struct ast {
	int nodetype;
	int datatype;
	int mem_loc;
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
	int mem_loc;
	char name[50];
	int decl_lineno;
	int lineno;
};

struct fcall {
	int nodetype;
	int datatype;
	int mem_loc;
	int name[50];
	int decl_lineno;
	int def_lineno;
	int lineno;
};

struct ast * newast(int, struct ast *, struct ast *);
struct ast * newnum(double, int);
struct ast * newid(int, int, char *, int, int);
struct ast * newfcall(sym *, int);

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

%right RPAR KW_ELSE /* resolve if-else shift/reduce conflict */

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

						temp->label = next_label++;			 // allocate label number
						temp->mem_loc = next_mem_loc++;		 // allocate memory location for parameter
						temp->ret_mem_loc = next_mem_loc++;  // allocate memory location for return value
								
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

							if((strcmp(temp->name, $2) == 0) && (temp->declared)) { // found declaration
								
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

							temp->label = next_label++;
							temp->ret_mem_loc = next_mem_loc++;

							// set start label to the label of main function
							if(strcmp($2, "main") == 0) 
								start_label = temp->label;

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
							
							current_func = temp; // record the current function							

							global = false;	// entered local scope

							// ========= TARGET CODE GENERATION =========
							fprintf(fd, "label %d\n", temp->label);
							// ========= TARGET CODE GENERATION =========

							/* ==== add function parameter to local table ==== */
						
							temp = (sym *)malloc(sizeof(sym));
							// ****from now on, temp is a new location for the parameter, not for the function
							strcpy(temp->name, $5);
							temp->val_type = t_val;
							temp->isGlobal = false;
							temp->lineno = yylineno;
							// set memory location
							if(!(current_func->declared)) {
								temp->mem_loc = next_mem_loc++;
								current_func->mem_loc = temp->mem_loc;
							}
							else {
								temp->mem_loc = current_func->mem_loc;
							}

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
						if(strcmp(current_func->name, "main") == 0)
							fprintf(fd, "STOP\n");
					}
				|	kind ID LPAR error RPAR 
					{
						global = false;
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
		;

decl	:	kind var_list SEMICOLON 
			{
				// search for variable redeclaration
				while(head != NULL) { // loop through var_list

					found = false;

					/* search for LOCAL redeclaration */
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

					/* search for GLOBAL redeclaration */
					if(global && gtable != NULL) { 

						temp = gtable;

						while(temp != NULL) { /* loop through global symbol table */

							if(strcmp(temp->name, head->name) == 0) { // redeclaration found

								if(!(temp->declared) && !(temp->implemented)) {
									
									if(temp->val_type == head->val_type) {
										printf("ERROR: Redeclaring global variable %s in line %d.\n", 
																			temp->name, yylineno);
									}
									else {
										printf("ERROR: Redeclaring global variable %s with different type in line %d.\n", 
																								temp->name, yylineno);
									}
								}
								else { /* funcAsVar */
									printf("ERROR: Redeclaring a function as a global variable %s in line %d.\n", 
																						temp->name, yylineno);
								}

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

							// allocate memory location for this variable
							temp->mem_loc = next_mem_loc++;

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

							// allocate memory location for this variable
							temp->mem_loc = next_mem_loc++;

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

stmt			:	LBRACE stmts RBRACE 
				|	expr SEMICOLON 
				|	error SEMICOLON	 
				|	KW_WHILE 
					{
						whileStack[sp_while++] = next_label;
						fprintf(fd, "label %d\n", next_label++);
					} 
					LPAR bool_expr RPAR stmt 
					{
						// TARGET CODE GENERATION
						fprintf(fd, "JUMP %d\n", whileStack[sp_while-2]);
						fprintf(fd, "label %d\n", whileStack[sp_while-1]);
						// pop
						sp_while -= 2;

						isWHILE = false;
					}
				|	KW_READ {isDecl = false;} var_list SEMICOLON
					{
						while(head != NULL) { /* loop for var_list */
							
							funcAsVar = false;
							found = false;

							/* ====================================================================================== */
							
							if(ltable != NULL) {
								temp = ltable;
								while(temp != NULL) { /* loop for local symbol table */
									if(strcmp(head->name, temp->name) == 0) {
										printf("Local %s variable %s declared in line %d used in line %d.\n", 
														data_type[temp->val_type], temp->name, temp->lineno, yylineno);
										
										// ============ TARGET CODE GENERATION =============
										(temp->val_type == TYPE_INT) ? 
											fprintf(fd, "READ %d\n", temp->mem_loc) : fprintf(fd, "READF %d\n", temp->mem_loc);
										// ============ TARGET CODE GENERATION =============
										
										found = true;
										break;
									}
									temp = temp->next;
								}
							}
							if(found == false && gtable != NULL) {
								
								temp = gtable;
								while(temp != NULL) { /* loop for global symbol table */
									
									if(strcmp(head->name, temp->name) == 0) {

										if(!(temp->declared) && !(temp->implemented)) {
											printf("Global %s variable %s declared in line %d used in line %d.\n", 
															data_type[temp->val_type], temp->name, temp->lineno, yylineno);
											
											// ============ TARGET CODE GENERATION =============
											(temp->val_type == TYPE_INT) ? 
												fprintf(fd, "READ %d\n", temp->mem_loc) : fprintf(fd, "READF %d\n", temp->mem_loc);
											// ============ TARGET CODE GENERATION =============
										}
										else {
											funcAsVar = true;
										}

										found = true;
										break;
									}

									temp = temp->next;

								} /* loop for global symbol table */
							}

							if(!found) { // ERROR detected
								if(funcAsVar)
									printf("ERROR line %d: function %s used as a variable.\n", yylineno, head->name);
								else
									printf("ERROR line %d: variable %s not declared.\n", yylineno, head->name);
							}
							
							/* ====================================================================================== */

							temp = head;
							head = head->next;
							free(temp);
		 
						} /* var_list loop */
						head = tail = NULL;
					}
				|	KW_READ error SEMICOLON
				|	KW_WRITE write_expr_list SEMICOLON {fprintf(fd, "NEWLINE\n");}
				|	KW_WRITE error SEMICOLON
				|	KW_RETURN expr SEMICOLON 
					{
						if($2->nodetype == 'N') {
							if($2->datatype == TYPE_INT) {
								fprintf(fd, "COPY #%d %d\n", (int)(((struct numval *)$2)->val), current_func->ret_mem_loc);
							}
							else {
								fprintf(fd, "COPYF #%lf %d\n", ((struct numval *)$2)->val, current_func->ret_mem_loc);
							}
						}
						else {
							if($2->datatype == TYPE_INT) {
								fprintf(fd, "COPY %d %d\n", $2->mem_loc, current_func->ret_mem_loc);
							}
							else {
								fprintf(fd, "COPYF %d %d\n", $2->mem_loc, current_func->ret_mem_loc);
							}
						}
						fprintf(fd, "RETURN\n");
					}
				|	KW_IF LPAR bool_expr RPAR stmt 
					{
						// TARGET CODE GENERATION
						fprintf(fd, "label %d\n", ifStack[--sp_if]);
					}
				|	KW_IF LPAR bool_expr RPAR stmt KW_ELSE 
					{
						// TARGET CODE GENERATION
						
						// push elseStack
						elseStack[sp_else++] = next_label;
						fprintf(fd, "JUMP %d\n", next_label++);
						
						//pop ifStack
						fprintf(fd, "label %d\n", ifStack[--sp_if]);
					} 
					stmt 
					{
						// pop elseStack
						fprintf(fd, "label %d\n", elseStack[--sp_else]);
					}
				;


write_expr_list	:	wlist_unit wlist_rep
				;

wlist_unit 	:	expr
				{
					// TARGET CODE GENERATION
					if($1->datatype == TYPE_INT) {
						fprintf(fd, "WRITE ");
						$1->nodetype == 'N' ? fprintf(fd, "#%d\n", (int)((struct numval *)$1)->val) : fprintf(fd, "%d\n", $1->mem_loc);
					}
					else {
						fprintf(fd, "WRITEF ");
						$1->nodetype == 'N' ? fprintf(fd, "#%d\n", ((struct numval *)$1)->val) : fprintf(fd, "%d\n", $1->mem_loc);
					}
				}
			|	STRING_LIT
				{	
					// TARGET CODE GENERATION
					fprintf(fd, "WRITES \"%s\"\n", $1);
				}
			;

wlist_rep	:	
			|	wlist_rep COMMA wlist_unit
			;

var_list	:	ID 
				{
					if(head == NULL) {
						head = (sym *)malloc(sizeof(sym));

						strcpy(head->name, $1);

						if(isDecl) 
						{
							head->val_type = type[type_indicator];
							head->isGlobal = global;
							head->lineno = yylineno;

							head->declared = false;
							head->implemented = false;
						}

						head->next = NULL;
						tail = head;		
					}
					else { printf("ERROR line %d: head is not NULL.\n", yylineno); }
				} 
				var_list_rep {isDecl = true;}
			;

var_list_rep	:	
				|	var_list_rep COMMA ID 
					{	
						if(tail != NULL) {
							
							tail->next = (sym *)malloc(sizeof(sym));
							tail = tail->next;

							strcpy(tail->name, $3);

							if(isDecl) 
							{
								tail->val_type = type[type_indicator];
								tail->isGlobal = global;
								tail->lineno = yylineno;

								tail->declared = false;
								tail->implemented = false;
							}

							tail->next = NULL;
						}
						else { printf("ERROR line %d: tail is NULL.\n", yylineno); }
					}
				;

bool_expr	:	expr OP_EQ expr
				{
					if($1->datatype != $3->datatype) { // error: MIXED TYPE in logic op
						
						if($1->nodetype == 'I') {
							struct idval *temp = (struct idval *)$1;
							printf("ERROR: Comparing %s \"%s\" (declared on line %d) with ", 
									data_type[temp->datatype], temp->name, temp->decl_lineno);
						}
						else {
							printf("ERROR: Comparing %s value with ", data_type[$1->datatype]);
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
					else if(isWHILE || isIF) {
						
						// TARGET CODE GENERATION

						char operand1[50];
						char operand2[50];
				
						if($1->datatype == TYPE_INT) {
																
							if($1->nodetype == 'N')
								sprintf(operand1, "#%d", (int)((struct numval *)$1)->val);
							else
								sprintf(operand1, "%d", $1->mem_loc);
							
							if($3->nodetype == 'N')
								sprintf(operand2, "#%d", (int)((struct numval *)$3)->val);
							else
								sprintf(operand2, "%d", $3->mem_loc);
							
							if(isWHILE) { 
								// push 
								whileStack[sp_while++] = next_label;
								fprintf(fd, "JNE %s %s %d\n", operand1, operand2, next_label++);
								
								isWHILE = false;
							}
							else if(isIF) {
								//push
								ifStack[sp_if++] = next_label;
								fprintf(fd, "JNE %s %s %d\n", operand1, operand2, next_label++);
								
								isIF = false;
							}
						}
						else { // TYPE_FLOAT

							if($1->nodetype == 'N')
								sprintf(operand1, "#%lf", ((struct numval *)$1)->val);
							else
								sprintf(operand1, "%d", $1->mem_loc);
							
							if($3->nodetype == 'N')
								sprintf(operand2, "#%lf", ((struct numval *)$3)->val);
							else
								sprintf(operand2, "%d", $3->mem_loc);

							if(isWHILE) {
								// push
								whileStack[sp_while++] = next_label;
								fprintf(fd, "JNEF %s %s %d\n", operand1, operand2, next_label++);
								isWHILE = false;
							}
							else if(isIF) {
								// push
								ifStack[sp_if++] = next_label;
								fprintf(fd, "JNEF %s %s %d\n", operand1, operand2, next_label++);
								isIF = false;
							}
						}
					}
						
				}
			|	expr OP_LT expr
				{
					if($1->datatype != $3->datatype) { // error: MIXED TYPE in logic op
						
						if($1->nodetype == 'I') {
							struct idval *temp = (struct idval *)$1;
							printf("ERROR: Comparing %s \"%s\" (declared on line %d) with ", 
									data_type[temp->datatype], temp->name, temp->decl_lineno);
						}
						else {
							printf("ERROR: Comparing %s value with ", data_type[$1->datatype]);
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
					else if(isWHILE || isIF) {
						
						// TARGET CODE GENERATION

						char operand1[50];
						char operand2[50];
				
						if($1->datatype == TYPE_INT) {
																
							if($1->nodetype == 'N')
								sprintf(operand1, "#%d", (int)((struct numval *)$1)->val);
							else
								sprintf(operand1, "%d", $1->mem_loc);
							
							if($3->nodetype == 'N')
								sprintf(operand2, "#%d", (int)((struct numval *)$3)->val);
							else
								sprintf(operand2, "%d", $3->mem_loc);
							
							if(isWHILE) {
								// push
								whileStack[sp_while++] = next_label;
								fprintf(fd, "JGE %s %s %d\n", operand1, operand2, next_label++);
								isWHILE = false;	
							}
							else if(isIF) {
								// push
								ifStack[sp_if++] = next_label;
								fprintf(fd, "JGE %s %s %d\n", operand1, operand2, next_label++);
								isIF = false;
							}
						}
						else { // TYPE_FLOAT

							if($1->nodetype == 'N')
								sprintf(operand1, "#%lf", ((struct numval *)$1)->val);
							else
								sprintf(operand1, "%d", $1->mem_loc);
							
							if($3->nodetype == 'N')
								sprintf(operand2, "#%lf", ((struct numval *)$3)->val);
							else
								sprintf(operand2, "%d", $3->mem_loc);

							if(isWHILE) {
								// push
								whileStack[sp_while++] = next_label;
								fprintf(fd, "JGEF %s %s %d\n", operand1, operand2, next_label++);
								isWHILE = false;
							}
							else if(isIF) {
								// push
								ifStack[sp_if++] = next_label;
								fprintf(fd, "JGEF %s %s %d\n", operand1, operand2, next_label++);
								isIF = false;
							}
						}
					}
						
				}

			|	expr OP_LE expr
				{
					if($1->datatype != $3->datatype) { // error: MIXED TYPE in logic op
						
						if($1->nodetype == 'I') {
							struct idval *temp = (struct idval *)$1;
							printf("ERROR: Comparing %s \"%s\" (declared on line %d) with ", 
									data_type[temp->datatype], temp->name, temp->decl_lineno);
						}
						else {
							printf("ERROR: Comparing %s value with ", data_type[$1->datatype]);
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
					else if(isWHILE || isIF) {
						
						// TARGET CODE GENERATION

						char operand1[50];
						char operand2[50];
				
						if($1->datatype == TYPE_INT) {
																
							if($1->nodetype == 'N')
								sprintf(operand1, "#%d", (int)((struct numval *)$1)->val);
							else
								sprintf(operand1, "%d", $1->mem_loc);
							
							if($3->nodetype == 'N')
								sprintf(operand2, "#%d", (int)((struct numval *)$3)->val);
							else
								sprintf(operand2, "%d", $3->mem_loc);
							
							if(isWHILE) {
								// push
								whileStack[sp_while++] = next_label;
								fprintf(fd, "JGT %s %s %d\n", operand1, operand2, next_label++);
								isWHILE = false;
							}
							else if(isIF) {
								// push
								ifStack[sp_if++] = next_label;
								fprintf(fd, "JGT %s %s %d\n", operand1, operand2, next_label++);
								isIF = false;
							}
						}
						else { // TYPE_FLOAT

							if($1->nodetype == 'N')
								sprintf(operand1, "#%lf", ((struct numval *)$1)->val);
							else
								sprintf(operand1, "%d", $1->mem_loc);
							
							if($3->nodetype == 'N')
								sprintf(operand2, "#%lf", ((struct numval *)$3)->val);
							else
								sprintf(operand2, "%d", $3->mem_loc);

							if(isWHILE) {
								// push
								whileStack[sp_while++] = next_label;
								fprintf(fd, "JGTF %s %s %d\n", operand1, operand2, next_label++);
								isWHILE = false;
							}
							else if(isIF) {
								// push
								ifStack[sp_if++] = next_label;
								fprintf(fd, "JGTF %s %s %d\n", operand1, operand2, next_label++);
								isIF = false;
							}
						}
					}
						
				}

			|	expr OP_GT expr
				{
					if($1->datatype != $3->datatype) { // error: MIXED TYPE in logic op
						
						if($1->nodetype == 'I') {
							struct idval *temp = (struct idval *)$1;
							printf("ERROR: Comparing %s \"%s\" (declared on line %d) with ", 
									data_type[temp->datatype], temp->name, temp->decl_lineno);
						}
						else {
							printf("ERROR: Comparing %s value with ", data_type[$1->datatype]);
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
					else if(isWHILE || isIF) {
						
						// TARGET CODE GENERATION

						char operand1[50];
						char operand2[50];
				
						if($1->datatype == TYPE_INT) {
																
							if($1->nodetype == 'N')
								sprintf(operand1, "#%d", (int)((struct numval *)$1)->val);
							else
								sprintf(operand1, "%d", $1->mem_loc);
							
							if($3->nodetype == 'N')
								sprintf(operand2, "#%d", (int)((struct numval *)$3)->val);
							else
								sprintf(operand2, "%d", $3->mem_loc);
							
							if(isWHILE) {
								// push
								whileStack[sp_while++] = next_label;
								fprintf(fd, "JLE %s %s %d\n", operand1, operand2, next_label++);
								isWHILE = false;
							}
							else if(isIF) {
								// push
								ifStack[sp_if++] = next_label;
								fprintf(fd, "JLE %s %s %d\n", operand1, operand2, next_label++);
								isIF = false;
							}
						}
						else { // TYPE_FLOAT

							if($1->nodetype == 'N')
								sprintf(operand1, "#%lf", ((struct numval *)$1)->val);
							else
								sprintf(operand1, "%d", $1->mem_loc);
							
							if($3->nodetype == 'N')
								sprintf(operand2, "#%lf", ((struct numval *)$3)->val);
							else
								sprintf(operand2, "%d", $3->mem_loc);

							if(isWHILE) {
								// push
								whileStack[sp_while++] = next_label;
								fprintf(fd, "JLEF %s %s %d\n", operand1, operand2, next_label++);
								isWHILE = false;
							}
							else if(isIF) {
								// push
								ifStack[sp_if++] = next_label;
								fprintf(fd, "JLEF %s %s %d\n", operand1, operand2, next_label++);
								isIF = false;
							}
						}
					}
						
				}

			|	expr OP_GE expr
				{
					if($1->datatype != $3->datatype) { // error: MIXED TYPE in logic op
						
						if($1->nodetype == 'I') {
							struct idval *temp = (struct idval *)$1;
							printf("ERROR: Comparing %s \"%s\" (declared on line %d) with ", 
									data_type[temp->datatype], temp->name, temp->decl_lineno);
						}
						else {
							printf("ERROR: Comparing %s value with ", data_type[$1->datatype]);
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
					else if(isWHILE || isIF) {
						
						// TARGET CODE GENERATION

						char operand1[50];
						char operand2[50];
				
						if($1->datatype == TYPE_INT) {
																
							if($1->nodetype == 'N')
								sprintf(operand1, "#%d", (int)((struct numval *)$1)->val);
							else
								sprintf(operand1, "%d", $1->mem_loc);
							
							if($3->nodetype == 'N')
								sprintf(operand2, "#%d", (int)((struct numval *)$3)->val);
							else
								sprintf(operand2, "%d", $3->mem_loc);
							
							if(isWHILE) {
								// push
								whileStack[sp_while++] = next_label;
								fprintf(fd, "JLT %s %s %d\n", operand1, operand2, next_label++);
								isWHILE = false;
							}
							else if(isIF) {
								// push
								ifStack[sp_if++] = next_label;
								fprintf(fd, "JLT %s %s %d\n", operand1, operand2, next_label++);
								isIF = false;
							}
						}
						else { // TYPE_FLOAT

							if($1->nodetype == 'N')
								sprintf(operand1, "#%lf", ((struct numval *)$1)->val);
							else
								sprintf(operand1, "%d", $1->mem_loc);
							
							if($3->nodetype == 'N')
								sprintf(operand2, "#%lf", ((struct numval *)$3)->val);
							else
								sprintf(operand2, "%d", $3->mem_loc);

							if(isWHILE) {
								// push
								whileStack[sp_while++] = next_label;
								fprintf(fd, "JLTF %s %s %d\n", operand1, operand2, next_label++);
								isWHILE = false;
							}
							else if(isIF) {
								// push
								ifStack[sp_if++] = next_label;
								fprintf(fd, "JLTF %s %s %d\n", operand1, operand2, next_label++);
								isIF = false;
							}
						}
					}
						
				}

			|	expr error expr {printf("ERROR: boolean operator is expected. Line: %d\n", yylineno-1);} 
			;


expr		:	ID
				{
					funcAsVar = false;
					found = false;

					if(ltable != NULL) {
						temp = ltable;
						while(temp != NULL) { /* local symbol table */
							if(strcmp(temp->name, $1) == 0) {
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
						while(temp != NULL) { /* global symbol table */
							if(strcmp(temp->name, $1) == 0 && !(temp->declared) && !(temp->implemented)) {
								printf("Global %s variable %s declared in line %d used in line %d.\n", 
									data_type[temp->val_type], temp->name, temp->lineno, yylineno);

								found = true;
								break;
							}
							if(strcmp(temp->name, $1) == 0 && (temp->declared || temp->implemented)) {
								funcAsVar = true;
							}
							temp = temp->next;
						}
					}
					if(!found) {
						if(funcAsVar)
							printf("ERROR line %d: function %s used as a variable.\n", yylineno, $1);
						else {
							printf("ERROR line %d: variable %s not declared.\n", yylineno, $1);
						}
					}
				}
				OP_ASSIGN expr
				{
					funcAsVar = false;
					found = false;

					if(ltable != NULL) {

						temp = ltable;
						while(temp != NULL) { /* local symbol table */

							if(strcmp(temp->name, $1) == 0) { // variable found in local table

								// AST AND TARGET CODE GENERATION ============================================

								if($4->datatype != temp->val_type) {
								
									printf("ERROR: Value of wrong type assigned to %s variable %s. Line: %d.\n",
																		data_type[temp->val_type], temp->name, yylineno);
									$$  = $4;
								}
								else {

									// TARGET CODE GENERATION
									if(temp->val_type == TYPE_INT) {
										fprintf(fd, "COPY ");
										$4->nodetype == 'N' ? fprintf(fd, "#%d ", (int)((struct numval *)$4)->val) : fprintf(fd, "%d ", $4->mem_loc);
										fprintf(fd, "%d\n", temp->mem_loc);
									}
									else {
										fprintf(fd, "COPYF ");
										$4->nodetype == 'N' ? fprintf(fd, "#%lf ", ((struct numval *)$4)->val) : fprintf(fd, "%d ", $4->mem_loc);
										fprintf(fd, "%d\n", temp->mem_loc);
									}
	
									$$ = $4;
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

								// AST AND TARGET CODE GENERATION ============================================

								if($4->datatype != temp->val_type) {
									printf("ERROR: Value of wrong type assigned to %s variable %s. Line: %d.\n",
																		data_type[temp->val_type], temp->name, yylineno);
									$$ = $4;
								}
								else {

									// TARGET CODE GENERATION
									if(temp->val_type == TYPE_INT) {
										fprintf(fd, "COPY ");
										$4->nodetype == 'N' ? fprintf(fd, "#%d ", (int)((struct numval *)$4)->val) : fprintf(fd, "%d ", $4->mem_loc);
										fprintf(fd, "%d\n", temp->mem_loc);
									}
									else {
										fprintf(fd, "COPYF ");
										$4->nodetype == 'N' ? fprintf(fd, "#%lf ", ((struct numval *)$4)->val) : fprintf(fd, "%d ", $4->mem_loc);
										fprintf(fd, "%d\n", temp->mem_loc);
									}
	
									$$ = $4;
								}

								// ===========================================================================

								found = true;
								break;
							}
							if(strcmp(temp->name, $1) == 0 && (temp->declared || temp->implemented)) {
								$$ = NULL;
							}
							temp = temp->next;
						}
					}
					if(!found) { $$ = NULL; }
				}
			|	expr1 { $$ = $1; }
			;

expr1		:	expr1 OP_PLUS expr1 
				{ 
					// AST
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
					else { 
						// TARGET CODE GENERATION
						if($$->datatype == TYPE_INT) {
							fprintf(fd, "ADD ");
							$1->nodetype == 'N' ? fprintf(fd, "#%d ", (int)((struct numval *)$1)->val) : fprintf(fd, "%d ", $1->mem_loc);
							$3->nodetype == 'N' ? fprintf(fd, "#%d ", (int)((struct numval *)$3)->val) : fprintf(fd, "%d ", $3->mem_loc);
						}
						else {
							fprintf(fd, "ADDF ");
							$1->nodetype == 'N' ? fprintf(fd, "#%lf ", ((struct numval *)$1)->val) : fprintf(fd, "%d ", $1->mem_loc);
							$3->nodetype == 'N' ? fprintf(fd, "#%lf ", ((struct numval *)$3)->val) : fprintf(fd, "%d ", $3->mem_loc);
						}
						fprintf(fd, "%d\n", $$->mem_loc);
					}
				}
			|	expr1 OP_MINUS expr1 
				{
					// AST
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
					else { 
						// TARGET CODE GENERATION
						if($$->datatype == TYPE_INT) {
							fprintf(fd, "SUB ");
							$1->nodetype == 'N' ? fprintf(fd, "#%d ", (int)((struct numval *)$1)->val) : fprintf(fd, "%d ", $1->mem_loc);
							$3->nodetype == 'N' ? fprintf(fd, "#%d ", (int)((struct numval *)$3)->val) : fprintf(fd, "%d ", $3->mem_loc);
						}
						else {
							fprintf(fd, "SUBF ");
							$1->nodetype == 'N' ? fprintf(fd, "#%lf ", ((struct numval *)$1)->val) : fprintf(fd, "%d ", $1->mem_loc);
							$3->nodetype == 'N' ? fprintf(fd, "#%lf ", ((struct numval *)$3)->val) : fprintf(fd, "%d ", $3->mem_loc);
						}
						fprintf(fd, "%d\n", $$->mem_loc);
					}
				}
			|	expr1 OP_MULT expr1 
				{
					// AST	
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
					else { 
						// TARGET CODE GENERATION
						if($$->datatype == TYPE_INT) {
							fprintf(fd, "MUL ");
							$1->nodetype == 'N' ? fprintf(fd, "#%d ", (int)((struct numval *)$1)->val) : fprintf(fd, "%d ", $1->mem_loc);
							$3->nodetype == 'N' ? fprintf(fd, "#%d ", (int)((struct numval *)$3)->val) : fprintf(fd, "%d ", $3->mem_loc);
						}
						else {
							fprintf(fd, "MULF ");
							$1->nodetype == 'N' ? fprintf(fd, "#%lf ", ((struct numval *)$1)->val) : fprintf(fd, "%d ", $1->mem_loc);
							$3->nodetype == 'N' ? fprintf(fd, "#%lf ", ((struct numval *)$3)->val) : fprintf(fd, "%d ", $3->mem_loc);
						}
						fprintf(fd, "%d\n", $$->mem_loc);
					}
				}
			|	expr1 OP_DIV expr1 
				{
					// AST
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
					else { 
						// TARGET CODE GENERATION 
						if($$->datatype == TYPE_INT) {
							fprintf(fd, "DIV ");
							$1->nodetype == 'N' ? fprintf(fd, "#%d ", (int)((struct numval *)$1)->val) : fprintf(fd, "%d ", $1->mem_loc);
							$3->nodetype == 'N' ? fprintf(fd, "#%d ", (int)((struct numval *)$3)->val) : fprintf(fd, "%d ", $3->mem_loc);
						}
						else {
							fprintf(fd, "DIVF ");
							$1->nodetype == 'N' ? fprintf(fd, "#%lf ", ((struct numval *)$1)->val) : fprintf(fd, "%d ", $1->mem_loc);
							$3->nodetype == 'N' ? fprintf(fd, "#%lf ", ((struct numval *)$3)->val) : fprintf(fd, "%d ", $3->mem_loc);
						}
						fprintf(fd, "%d\n", $$->mem_loc);
					}
				}
			|	OP_MINUS factor %prec UMINUS 
				{ 
					// AST
					$$ = newast('M', $2, NULL); 

					// TARGET CODE GENERATION
					if($$->datatype == TYPE_INT) {
						fprintf(fd, "NEG ");
						$2->nodetype == 'N' ? fprintf(fd, "#%d ", (int)((struct numval *)$2)->val) : fprintf(fd, "%d ", $2->mem_loc);
					}
					else {
						fprintf(fd, "NEGF ");
						$2->nodetype == 'N' ? fprintf(fd, "#%lf ", ((struct numval *)$2)->val) : fprintf(fd, "%d ", $2->mem_loc);
					}
					fprintf(fd, "%d\n", $$->mem_loc);
				}
			|	factor { $$ = $1; }
			;

factor		:	INT_LIT { $$ = newnum($1, TYPE_INT); } 
			| 	FLOAT_LIT { $$ = newnum($1, TYPE_FLOAT); }
			| 	function_call { $$ = $1; }
			| 	LPAR expr RPAR { $$ = $2; }
			|	ID
				{
					found = false;
					funcAsVar = false;

					if(ltable != NULL) {

						temp = ltable;
						while(temp != NULL) {
							if(strcmp(temp->name, $1) == 0) { // found it in local symbol table
								printf("Local %s variable %s declared in line %d used in line %d.\n", 
												data_type[temp->val_type], $1, temp->lineno, yylineno);
								
								// AST ==============================
								$$ = newid(temp->mem_loc, temp->val_type, $1, temp->lineno, yylineno);

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
								if(!(temp->declared) && !(temp->implemented)) {
									printf("Global %s variable %s declared in line %d used in line %d.\n", 
													data_type[temp->val_type], $1, temp->lineno, yylineno);
									// AST ==============================
									$$ = newid(temp->mem_loc, temp->val_type, $1, temp->lineno, yylineno);
								}
								else {
									funcAsVar = true;
									// AST ==============================
									$$ = newid(-1, TYPE_INVALID, $1, -1, yylineno);
								}
								found = true;
								break;
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

						if(ltable != NULL) { /* check if a variable is used as a function */
							temp = ltable;
							while(temp != NULL) { 
								if(strcmp(temp->name, $1) == 0) {
									printf("ERROR line %d: variable %s used as function.\n", 
																		yylineno, temp->name);

									// AST =============================================================
									$$ = newfcall(NULL, yylineno);

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

										// ========== TARGET CODE GENERATION ==============

										if($3->datatype == TYPE_INT) {
											if($3->nodetype == 'N') {
												fprintf(fd, "COPY #%d %d\n", (int)(((struct numval *)$3)->val), temp->mem_loc);
											}
											else {
												fprintf(fd, "COPY %d %d\n", $3->mem_loc, temp->mem_loc);
											}
										}
										else {
											if($3->nodetype == 'N') {
												fprintf(fd, "COPYF #%lf %d\n", ((struct numval *)$3)->val, temp->mem_loc);
											}
											else {
												fprintf(fd, "COPYF %d %d\n", $3->mem_loc, temp->mem_loc);
											}
										}

										fprintf(fd, "CALL %d\n", temp->label);

										// AST ==================================================================
										$$ = newfcall(temp, yylineno);

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

										// ========== TARGET CODE GENERATION ==============
										
										if($3->datatype == TYPE_INT) {
											if($3->nodetype == 'N') {
												fprintf(fd, "COPY #%d %d\n", (int)(((struct numval *)$3)->val), temp->mem_loc);
											}
											else {
												fprintf(fd, "COPY %d %d\n", $3->mem_loc, temp->mem_loc);
											}
										}
										else {
											if($3->nodetype == 'N') {
												fprintf(fd, "COPYF #%lf %d\n", ((struct numval *)$3)->val, temp->mem_loc);
											}
											else {
												fprintf(fd, "COPYF %d %d\n", $3->mem_loc, temp->mem_loc);
											}
										}

										fprintf(fd, "CALL %d\n", temp->label);

										// AST ==================================================================
										$$ = newfcall(temp, yylineno);
										
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
										//AST =======================================================
										$$ = newfcall(NULL, yylineno);
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
	if((fd = fopen("out.asm", "w+")) < 0) {
		printf("ERROR: failed to open file\n");
		exit(EXIT_FAILURE);
	}

	yyparse();
	while(gtable != NULL && !syntax_error) {
		if(gtable->called && !(gtable->implemented)) {
			printf("ERROR: function %s called but not implemented.\n", gtable->name);
		}
		temp = gtable;
		gtable = gtable->next;
		free(temp);
	}
	
	// print START instruction
	if(start_label != -1) {
		fprintf(fd, "START %d\n", start_label);
	}
	else {
		printf("ERROR: no START label found!\n");
	}

	fclose(fd);

}

yyerror(char *s)
{
	syntax_error = true;
	fprintf(stderr, "ERROR: %s, line: %d\n", s, yylineno);
}

struct ast * newast(int nodetype, struct ast *l, struct ast *r) {
	
	struct ast *a = (struct ast *)malloc(sizeof(struct ast));
	a->nodetype = nodetype;
	
	if(nodetype == 'M') // UMINUS
		a->datatype = l->datatype;
	else
		a->datatype = ( (l->datatype == r->datatype) ? l->datatype : TYPE_INVALID );
	
	a->mem_loc = next_mem_loc++;
		
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

struct ast * newid(int mem, int datatype, char *name, int dln, int ln) {
	struct idval *a = (struct idval *)malloc(sizeof(struct idval));
	a->nodetype = 'I';
	a->datatype = datatype;
	a->mem_loc = mem;
	strcpy(a->name, name);
	a->decl_lineno = dln;
	a->lineno = ln;

	return (struct ast *)a;
}

struct ast * newfcall(sym *s, int ln) {
	struct fcall *a = (struct fcall *)malloc(sizeof(struct fcall));
	a->nodetype = 'F';
	
	if(s != NULL) {
		a->datatype = s->ret_type;
		a->mem_loc = s->ret_mem_loc;
		strcpy(a->name, s->name);
		a->decl_lineno = s->decl_lineno;
		a->def_lineno = s->def_lineno;
		a->lineno = ln;
	}
	else {
		a->datatype = TYPE_INVALID;
	}

	return (struct ast *)a;
}
