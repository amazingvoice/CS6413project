/*
 *	Qing Zhang(qz761)	CS6413
 */


extern int line_no;
extern char op_name[20];

#define YYSTYPE token_type

typedef union {
  int value;
  float valuef;
  char *ptr;
} token_type;

int yylex (void);
int yyparse (void);
int yyerror (char*);
