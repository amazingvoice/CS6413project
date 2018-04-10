%{

/*
 * tok.l
 *
 * flex input file to generate SiC scanner
 *
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "common.h"
#include "parser.tab.h"

/* 
from table 4: I changed some of the token numbers and names
	1:	int:	int
	2:	float:	float
	3:	if:	if
	4:	else:	else
	5:	while:	while
	6:	return:	return
	7:	read:	read
	8:	write:	write
	10:	ID:	[a-zA-Z_][a-zA-Z_0-9]*
	11:	op:	+|-|*|/|=
	15:	LPAR:	(
	16:	RPAR:	)
	19:	LBRACE:	{
	20:	RBRACE:	}
	21:	semi:	;
	22:	comma:	,
	23:	int:	[0-9]+
	24:	float:	[0-9]+\.[0-9]+
	99:	WS:	[ \t]
	100:	newline:\n
	101:	end-of-file:
END from table 4 
*/


char op_name[20];
int line_no = 1;
char *skip;
int mylength;
int data_type = 0;

char str1[50];
char str2[50];

/*
#define save_return(x) {strncpy(op_name,yytext,19); op_name[19]='\0'; yylval.value=x-ADD; return(x);}
*/

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
"int"			{data_type = 1; return(KW_INT);}
"float"			{data_type = 2; return(KW_FLOAT);}
"if"			return(KW_IF);
"else"			return(KW_ELSE);
"while"			return(KW_WHILE);
"return"		return(KW_RETURN);
"read"			return(KW_READ);
"write"			return(KW_WRITE);
"+"                     return(OP_PLUS);
"-"                     return(OP_MINUS);
"*"                     return(OP_MULT);
"/"                     return(OP_DIV);
"="                     return(OP_ASSIGN);
"=="                    return(OP_EQ); /* equal */
"<"                     return(OP_LT); /* less than */
">"                     return(OP_GT); /* greater than */
"<="                    return(OP_LE); /* less than or equal */
">="                    return(OP_GE); /* greater than or equal */
"("                     return(LPAR);
")"                     return(RPAR);
"{"                     return(LBRACE);
"}"                     return(RBRACE);
";"                     return(SEMICOLON);
","                     return(COMMA);

[a-zA-Z_][a-zA-Z_0-9]*  { 
			   yylval.ptr = strdup(yytext);
			   strcpy(str1, str2);
			   strcpy(str2, yytext);
			   return(ID); 
                        }

[0-9]+			{ for (mylength = yyleng, skip = yytext;
			       *skip == '0';
			       skip++, mylength--)
			    ;
			  if (mylength > 6) 
			    {
			      fprintf(stderr,
				      "Suspiciously large interger literal %s in line %d. Replacing by 0.\n",
				      skip, line_no);
			      yylval.value = 0;
			    }
			  else 
			    {
			      yylval.value = (int)atol(skip);
			    }
			  return (INT_LIT); 
			}

[0-9]+\.[0-9]+          { yylval.valuef = atof(yytext);
			  if (yyleng > 20)
			    {
			      fprintf(stderr,
				      "Suspiciously long float literal %s in line %d. Replacing by 0.0.\n",
				      skip, line_no);
			      yylval.value = 0;
			    }
			  return (FLOAT_LIT);
			}

\"[^\"]*\"		{ /* string literal; not in original language description. */
			   yytext[yyleng-1] = '\0';
			   yylval.ptr = strdup(yytext+1);
			   return(STRING_LIT);
			}

\n			{ line_no++; }
[\t ]+			{ }  
.			{ fprintf (stderr,
				   "Illegal or out of place character '%c (0x%x)' on line %d.\n",
				   yytext[0], yytext[0], line_no);
			}

%%
int yywrap ()
{
	return (1);
}
