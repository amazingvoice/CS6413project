%{

/*
 * tok.l
 *
 * flex input file to generate SiC scanner
 *
 * Qing Zhang(qz761)
 *
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "parser.tab.h"


int line_no = 1;
char *skip;
int mylength;

char second_to_last_id[50];
char last_id[50];


%}

%option yylineno
%x comment

%%

 /* Code to deal with comments borrowed from GNU flex manual. */
"/*"		BEGIN(comment);
<comment>[^*\n]*	   /* eat anything that's not a '*' */
<comment>"*"+[^*/\n]*   /* eat up '*'s not followed by '/'s */
<comment>\n		   ++line_no;
<comment>"*"+"/"	   BEGIN(INITIAL);

 /* tokens */
"int"			return(KW_INT);
"float"			return(KW_FLOAT);
"if"			return(KW_IF);
"else"			return(KW_ELSE);
"while"			return(KW_WHILE);
"return"		return(KW_RETURN);
"read"			return(KW_READ);
"write"			return(KW_WRITE);
"+"             return(OP_PLUS);
"-"             return(OP_MINUS);
"*"             return(OP_MULT);
"/"             return(OP_DIV);
"="             return(OP_ASSIGN);
"=="            return(OP_EQ); /* equal */
"<"             return(OP_LT); /* less than */
">"             return(OP_GT); /* greater than */
"<="            return(OP_LE); /* less than or equal */
">="            return(OP_GE); /* greater than or equal */
"("             return(LPAR);
")"             return(RPAR);
"{"             return(LBRACE);
"}"             return(RBRACE);
";"             return(SEMICOLON);
","             return(COMMA);

[a-zA-Z_][a-zA-Z_0-9]*  { 
			   				yylval.s = strdup(yytext);
			   				strcpy(second_to_last_id, last_id);
			   				strcpy(last_id, yytext);
			   				return(ID); 
                        }

[0-9]+	{ 
			for (mylength = yyleng, skip = yytext; *skip == '0'; skip++, mylength--);

			if (mylength > 6) {
				fprintf(stderr,
				  "Suspiciously large interger literal %s in line %d. Replacing by 0.\n",
				  skip, line_no);
				yylval.i = 0;
			}
			else {
				yylval.i = (int)atol(skip);
			}
			return (INT_LIT); 
		}

[0-9]+\.[0-9]+	{ 
					yylval.d = atof(yytext);
			  		if (yyleng > 20) {
					  	fprintf(stderr,
						  "Suspiciously long float literal %s in line %d. Replacing by 0.0.\n",
						  skip, line_no);
					  	yylval.d = 0;
					}
					return (FLOAT_LIT);
				}

\"[^\"]*\"	{ /* string literal; not in original language description. */
			   	yytext[yyleng-1] = '\0';
			   	yylval.s = strdup(yytext+1);
			   	return(STRING_LIT);
			}

\n			{ line_no++; }
[\t ]+		{ }  
.			{ 
				fprintf (stderr,
						"Illegal or out of place character '%c (0x%x)' on line %d.\n",
				   		yytext[0], yytext[0], line_no);
			}

%%
int yywrap () {
	return (1);
}
