/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison implementation for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Bison version.  */
#define YYBISON_VERSION "3.0.4"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1




/* Copy the first part of user declarations.  */
#line 1 "parser.y" /* yacc.c:339  */
									/* Qing Zhang(qz761)	CS6413 */

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


#line 153 "parser.tab.c" /* yacc.c:339  */

# ifndef YY_NULLPTR
#  if defined __cplusplus && 201103L <= __cplusplus
#   define YY_NULLPTR nullptr
#  else
#   define YY_NULLPTR 0
#  endif
# endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 1
#endif

/* In a future release of Bison, this section will be replaced
   by #include "parser.tab.h".  */
#ifndef YY_YY_PARSER_TAB_H_INCLUDED
# define YY_YY_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    ID = 258,
    KW_INT = 259,
    KW_FLOAT = 260,
    INT_LIT = 261,
    FLOAT_LIT = 262,
    STRING_LIT = 263,
    KW_IF = 264,
    KW_ELSE = 265,
    KW_WHILE = 266,
    KW_RETURN = 267,
    KW_READ = 268,
    KW_WRITE = 269,
    LPAR = 270,
    RPAR = 271,
    LBRACE = 272,
    RBRACE = 273,
    SEMICOLON = 274,
    COMMA = 275,
    NL_TOKEN = 276,
    WS_TOKEN = 277,
    OP_ASSIGN = 278,
    OP_EQ = 279,
    OP_LT = 280,
    OP_LE = 281,
    OP_GT = 282,
    OP_GE = 283,
    OP_PLUS = 284,
    OP_MINUS = 285,
    OP_MULT = 286,
    OP_DIV = 287,
    UMINUS = 288
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 90 "parser.y" /* yacc.c:355  */

	int i;
	double d;
	char *s;
	struct ast *a;

#line 234 "parser.tab.c" /* yacc.c:355  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif

/* Location type.  */
#if ! defined YYLTYPE && ! defined YYLTYPE_IS_DECLARED
typedef struct YYLTYPE YYLTYPE;
struct YYLTYPE
{
  int first_line;
  int first_column;
  int last_line;
  int last_column;
};
# define YYLTYPE_IS_DECLARED 1
# define YYLTYPE_IS_TRIVIAL 1
#endif


extern YYSTYPE yylval;
extern YYLTYPE yylloc;
int yyparse (void);

#endif /* !YY_YY_PARSER_TAB_H_INCLUDED  */

/* Copy the second part of user declarations.  */

#line 265 "parser.tab.c" /* yacc.c:358  */

#ifdef short
# undef short
#endif

#ifdef YYTYPE_UINT8
typedef YYTYPE_UINT8 yytype_uint8;
#else
typedef unsigned char yytype_uint8;
#endif

#ifdef YYTYPE_INT8
typedef YYTYPE_INT8 yytype_int8;
#else
typedef signed char yytype_int8;
#endif

#ifdef YYTYPE_UINT16
typedef YYTYPE_UINT16 yytype_uint16;
#else
typedef unsigned short int yytype_uint16;
#endif

#ifdef YYTYPE_INT16
typedef YYTYPE_INT16 yytype_int16;
#else
typedef short int yytype_int16;
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif ! defined YYSIZE_T
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned int
# endif
#endif

#define YYSIZE_MAXIMUM ((YYSIZE_T) -1)

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(Msgid) dgettext ("bison-runtime", Msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(Msgid) Msgid
# endif
#endif

#ifndef YY_ATTRIBUTE
# if (defined __GNUC__                                               \
      && (2 < __GNUC__ || (__GNUC__ == 2 && 96 <= __GNUC_MINOR__)))  \
     || defined __SUNPRO_C && 0x5110 <= __SUNPRO_C
#  define YY_ATTRIBUTE(Spec) __attribute__(Spec)
# else
#  define YY_ATTRIBUTE(Spec) /* empty */
# endif
#endif

#ifndef YY_ATTRIBUTE_PURE
# define YY_ATTRIBUTE_PURE   YY_ATTRIBUTE ((__pure__))
#endif

#ifndef YY_ATTRIBUTE_UNUSED
# define YY_ATTRIBUTE_UNUSED YY_ATTRIBUTE ((__unused__))
#endif

#if !defined _Noreturn \
     && (!defined __STDC_VERSION__ || __STDC_VERSION__ < 201112)
# if defined _MSC_VER && 1200 <= _MSC_VER
#  define _Noreturn __declspec (noreturn)
# else
#  define _Noreturn YY_ATTRIBUTE ((__noreturn__))
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YYUSE(E) ((void) (E))
#else
# define YYUSE(E) /* empty */
#endif

#if defined __GNUC__ && 407 <= __GNUC__ * 100 + __GNUC_MINOR__
/* Suppress an incorrect diagnostic about yylval being uninitialized.  */
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN \
    _Pragma ("GCC diagnostic push") \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")\
    _Pragma ("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
# define YY_IGNORE_MAYBE_UNINITIALIZED_END \
    _Pragma ("GCC diagnostic pop")
#else
# define YY_INITIAL_VALUE(Value) Value
#endif
#ifndef YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_END
#endif
#ifndef YY_INITIAL_VALUE
# define YY_INITIAL_VALUE(Value) /* Nothing. */
#endif


#if ! defined yyoverflow || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined EXIT_SUCCESS
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
      /* Use EXIT_SUCCESS as a witness for stdlib.h.  */
#     ifndef EXIT_SUCCESS
#      define EXIT_SUCCESS 0
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's 'empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined EXIT_SUCCESS \
       && ! ((defined YYMALLOC || defined malloc) \
             && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef EXIT_SUCCESS
#    define EXIT_SUCCESS 0
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined EXIT_SUCCESS
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined EXIT_SUCCESS
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* ! defined yyoverflow || YYERROR_VERBOSE */


#if (! defined yyoverflow \
     && (! defined __cplusplus \
         || (defined YYLTYPE_IS_TRIVIAL && YYLTYPE_IS_TRIVIAL \
             && defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yytype_int16 yyss_alloc;
  YYSTYPE yyvs_alloc;
  YYLTYPE yyls_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (yytype_int16) + sizeof (YYSTYPE) + sizeof (YYLTYPE)) \
      + 2 * YYSTACK_GAP_MAXIMUM)

# define YYCOPY_NEEDED 1

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)                           \
    do                                                                  \
      {                                                                 \
        YYSIZE_T yynewbytes;                                            \
        YYCOPY (&yyptr->Stack_alloc, Stack, yysize);                    \
        Stack = &yyptr->Stack_alloc;                                    \
        yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAXIMUM; \
        yyptr += yynewbytes / sizeof (*yyptr);                          \
      }                                                                 \
    while (0)

#endif

#if defined YYCOPY_NEEDED && YYCOPY_NEEDED
/* Copy COUNT objects from SRC to DST.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(Dst, Src, Count) \
      __builtin_memcpy (Dst, Src, (Count) * sizeof (*(Src)))
#  else
#   define YYCOPY(Dst, Src, Count)              \
      do                                        \
        {                                       \
          YYSIZE_T yyi;                         \
          for (yyi = 0; yyi < (Count); yyi++)   \
            (Dst)[yyi] = (Src)[yyi];            \
        }                                       \
      while (0)
#  endif
# endif
#endif /* !YYCOPY_NEEDED */

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  2
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   152

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  34
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  25
/* YYNRULES -- Number of rules.  */
#define YYNRULES  61
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  110

/* YYTRANSLATE[YYX] -- Symbol number corresponding to YYX as returned
   by yylex, with out-of-bounds checking.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   288

#define YYTRANSLATE(YYX)                                                \
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[TOKEN-NUM] -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, without out-of-bounds checking.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33
};

#if YYDEBUG
  /* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_uint16 yyrline[] =
{
       0,   130,   130,   131,   132,   133,   136,   202,   206,   205,
     302,   305,   306,   309,   310,   311,   314,   421,   432,   438,
     446,   447,   450,   451,   454,   455,   456,   457,   506,   507,
     508,   509,   510,   513,   516,   517,   520,   521,   525,   524,
     548,   549,   571,   574,   575,   576,   577,   578,   581,   652,
     655,   680,   706,   732,   757,   758,   761,   762,   763,   764,
     765,   819
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || 1
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "ID", "KW_INT", "KW_FLOAT", "INT_LIT",
  "FLOAT_LIT", "STRING_LIT", "KW_IF", "KW_ELSE", "KW_WHILE", "KW_RETURN",
  "KW_READ", "KW_WRITE", "LPAR", "RPAR", "LBRACE", "RBRACE", "SEMICOLON",
  "COMMA", "NL_TOKEN", "WS_TOKEN", "OP_ASSIGN", "OP_EQ", "OP_LT", "OP_LE",
  "OP_GT", "OP_GE", "OP_PLUS", "OP_MINUS", "OP_MULT", "OP_DIV", "UMINUS",
  "$accept", "program", "function_decl", "function_def", "$@1", "body",
  "decls", "stmts", "decl", "kind", "stmt", "open_stmt", "matched_stmt",
  "write_expr_list", "wlist_unit", "wlist_rep", "var_list", "$@2",
  "var_list_rep", "bool_expr", "bool_op", "expr", "expr1", "factor",
  "function_call", YY_NULLPTR
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[NUM] -- (External) token number corresponding to the
   (internal) symbol number NUM (which must be that of a token).  */
static const yytype_uint16 yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   278,   279,   280,   281,   282,   283,   284,
     285,   286,   287,   288
};
# endif

#define YYPACT_NINF -87

#define yypact_value_is_default(Yystate) \
  (!!((Yystate) == (-87)))

#define YYTABLE_NINF -1

#define yytable_value_is_error(Yytable_value) \
  0

  /* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
     STATE-NUM.  */
static const yytype_int16 yypact[] =
{
     -87,   107,   -87,   -15,   -87,   -87,   -87,   -87,   -87,    24,
     -87,   -10,    39,    -6,   -87,    34,   -87,   -87,    -2,    43,
      48,    40,    74,   -87,   -87,   -87,    73,   -87,   -87,    52,
      78,    17,   -87,    79,    37,    38,   -87,   -87,    81,    84,
      91,   132,     4,    91,   -87,    30,   -87,   -87,   -87,    90,
      93,   -87,   -87,   -87,   -87,    91,    91,    91,    91,    95,
     108,   115,   117,   -87,   118,   -87,   -87,   110,   123,   -87,
     -87,    98,    98,    98,    98,   124,   -87,   125,    92,   126,
     -87,   -87,   -87,   -87,   -87,   119,   -87,    10,    10,   -87,
     -87,   -87,    72,   -87,   -87,   -87,   -87,   -87,    91,    59,
      85,   -87,   133,   -87,   -87,   -87,   -87,    72,   -87,   -87
};

  /* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
     Performed when YYTABLE does not specify something else to do.  Zero
     means the default is an error.  */
static const yytype_uint8 yydefact[] =
{
       2,     0,     1,     0,    18,    19,     5,     3,     4,     0,
       7,     0,    38,     0,    17,     0,    40,    16,     0,    39,
       0,     0,     0,     8,     6,    41,     0,    11,     9,    13,
      13,     0,    12,     0,     0,    60,    56,    57,     0,     0,
       0,     0,     0,     0,    10,     0,    14,    21,    20,     0,
      49,    55,    58,    38,    15,     0,     0,     0,     0,     0,
       0,     0,     0,    35,     0,    36,    34,     0,    60,    54,
      24,     0,     0,     0,     0,     0,    48,     0,     0,     0,
      31,    28,    27,    30,    29,    33,    59,    50,    51,    52,
      53,    61,     0,    43,    44,    45,    46,    47,     0,     0,
       0,    22,    20,    42,    26,    25,    37,     0,    23,    32
};

  /* YYPGOTO[NTERM-NUM].  */
static const yytype_int8 yypgoto[] =
{
     -87,   -87,   -87,   -87,   -87,    45,   -87,   116,   120,    -7,
      11,    41,   -86,   -87,    47,   -87,   104,   -87,   -87,    94,
     -87,   -40,    58,   105,   -87
};

  /* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int8 yydefgoto[] =
{
      -1,     1,     6,     7,    26,    28,    29,    31,     8,     9,
      46,    47,    48,    64,    65,    85,    13,    16,    19,    77,
      98,    49,    50,    51,    52
};

  /* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
     positive, shift that token.  If negative, reduce the rule whose
     number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_uint8 yytable[] =
{
      59,    20,    66,    67,    10,    62,   102,    35,    18,    14,
      36,    37,    63,    17,    21,    75,    76,    78,    78,    43,
      35,   109,    33,    36,    37,    11,    38,    12,    39,    40,
      41,    42,    43,    68,    45,    44,    36,    37,     4,     5,
      35,    73,    74,    36,    37,    43,    38,    45,    39,    40,
      41,    42,    43,    55,    15,    54,     4,     5,   103,    24,
      66,    56,    35,    22,    23,    36,    37,    45,    38,    30,
      39,    40,    41,    42,    43,    35,    27,    25,    36,    37,
      11,    38,    53,    39,    40,    41,    42,    43,    35,    45,
      27,    36,    37,    63,    35,    30,    57,    36,    37,    58,
      43,    68,    45,   101,    36,    37,    43,     2,     3,    70,
     105,     4,     5,    43,    80,    45,    93,    94,    95,    96,
      97,    45,    71,    72,    73,    74,    86,    81,    45,    87,
      88,    89,    90,    60,    82,    53,    83,    84,    55,   100,
      91,    92,    99,   107,   104,    61,    34,   106,   108,    32,
      69,     0,    79
};

static const yytype_int8 yycheck[] =
{
      40,     3,    42,    43,    19,     1,    92,     3,    15,    19,
       6,     7,     8,    19,    16,    55,    56,    57,    58,    15,
       3,   107,    29,     6,     7,     1,     9,     3,    11,    12,
      13,    14,    15,     3,    30,    18,     6,     7,     4,     5,
       3,    31,    32,     6,     7,    15,     9,    30,    11,    12,
      13,    14,    15,    15,    15,    18,     4,     5,    98,    19,
     100,    23,     3,    20,    16,     6,     7,    30,     9,    17,
      11,    12,    13,    14,    15,     3,    17,     3,     6,     7,
       1,     9,     3,    11,    12,    13,    14,    15,     3,    30,
      17,     6,     7,     8,     3,    17,    15,     6,     7,    15,
      15,     3,    30,    92,     6,     7,    15,     0,     1,    19,
      99,     4,     5,    15,    19,    30,    24,    25,    26,    27,
      28,    30,    29,    30,    31,    32,    16,    19,    30,    71,
      72,    73,    74,     1,    19,     3,    19,    19,    15,    20,
      16,    16,    16,    10,    99,    41,    30,   100,   107,    29,
      45,    -1,    58
};

  /* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
     symbol of state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,    35,     0,     1,     4,     5,    36,    37,    42,    43,
      19,     1,     3,    50,    19,    15,    51,    19,    43,    52,
       3,    16,    20,    16,    19,     3,    38,    17,    39,    40,
      17,    41,    42,    43,    41,     3,     6,     7,     9,    11,
      12,    13,    14,    15,    18,    30,    44,    45,    46,    55,
      56,    57,    58,     3,    18,    15,    23,    15,    15,    55,
       1,    50,     1,     8,    47,    48,    55,    55,     3,    57,
      19,    29,    30,    31,    32,    55,    55,    53,    55,    53,
      19,    19,    19,    19,    19,    49,    16,    56,    56,    56,
      56,    16,    16,    24,    25,    26,    27,    28,    54,    16,
      20,    44,    46,    55,    39,    44,    48,    10,    45,    46
};

  /* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_uint8 yyr1[] =
{
       0,    34,    35,    35,    35,    35,    36,    36,    38,    37,
      39,    40,    40,    41,    41,    41,    42,    42,    43,    43,
      44,    44,    45,    45,    46,    46,    46,    46,    46,    46,
      46,    46,    46,    47,    48,    48,    49,    49,    51,    50,
      52,    52,    53,    54,    54,    54,    54,    54,    55,    55,
      56,    56,    56,    56,    56,    56,    57,    57,    57,    57,
      57,    58
};

  /* YYR2[YYN] -- Number of symbols on the right hand side of rule YYN.  */
static const yytype_uint8 yyr2[] =
{
       0,     2,     0,     2,     2,     2,     6,     2,     0,     8,
       4,     0,     2,     0,     2,     3,     3,     3,     1,     1,
       1,     1,     5,     7,     2,     5,     5,     3,     3,     3,
       3,     3,     7,     2,     1,     1,     0,     3,     0,     3,
       0,     3,     3,     1,     1,     1,     1,     1,     3,     1,
       3,     3,     3,     3,     2,     1,     1,     1,     1,     3,
       1,     4
};


#define yyerrok         (yyerrstatus = 0)
#define yyclearin       (yychar = YYEMPTY)
#define YYEMPTY         (-2)
#define YYEOF           0

#define YYACCEPT        goto yyacceptlab
#define YYABORT         goto yyabortlab
#define YYERROR         goto yyerrorlab


#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)                                  \
do                                                              \
  if (yychar == YYEMPTY)                                        \
    {                                                           \
      yychar = (Token);                                         \
      yylval = (Value);                                         \
      YYPOPSTACK (yylen);                                       \
      yystate = *yyssp;                                         \
      goto yybackup;                                            \
    }                                                           \
  else                                                          \
    {                                                           \
      yyerror (YY_("syntax error: cannot back up")); \
      YYERROR;                                                  \
    }                                                           \
while (0)

/* Error token number */
#define YYTERROR        1
#define YYERRCODE       256


/* YYLLOC_DEFAULT -- Set CURRENT to span from RHS[1] to RHS[N].
   If N is 0, then set CURRENT to the empty location which ends
   the previous symbol: RHS[0] (always defined).  */

#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)                                \
    do                                                                  \
      if (N)                                                            \
        {                                                               \
          (Current).first_line   = YYRHSLOC (Rhs, 1).first_line;        \
          (Current).first_column = YYRHSLOC (Rhs, 1).first_column;      \
          (Current).last_line    = YYRHSLOC (Rhs, N).last_line;         \
          (Current).last_column  = YYRHSLOC (Rhs, N).last_column;       \
        }                                                               \
      else                                                              \
        {                                                               \
          (Current).first_line   = (Current).last_line   =              \
            YYRHSLOC (Rhs, 0).last_line;                                \
          (Current).first_column = (Current).last_column =              \
            YYRHSLOC (Rhs, 0).last_column;                              \
        }                                                               \
    while (0)
#endif

#define YYRHSLOC(Rhs, K) ((Rhs)[K])


/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)                        \
do {                                            \
  if (yydebug)                                  \
    YYFPRINTF Args;                             \
} while (0)


/* YY_LOCATION_PRINT -- Print the location on the stream.
   This macro was not mandated originally: define only if we know
   we won't break user code: when these are the locations we know.  */

#ifndef YY_LOCATION_PRINT
# if defined YYLTYPE_IS_TRIVIAL && YYLTYPE_IS_TRIVIAL

/* Print *YYLOCP on YYO.  Private, do not rely on its existence. */

YY_ATTRIBUTE_UNUSED
static unsigned
yy_location_print_ (FILE *yyo, YYLTYPE const * const yylocp)
{
  unsigned res = 0;
  int end_col = 0 != yylocp->last_column ? yylocp->last_column - 1 : 0;
  if (0 <= yylocp->first_line)
    {
      res += YYFPRINTF (yyo, "%d", yylocp->first_line);
      if (0 <= yylocp->first_column)
        res += YYFPRINTF (yyo, ".%d", yylocp->first_column);
    }
  if (0 <= yylocp->last_line)
    {
      if (yylocp->first_line < yylocp->last_line)
        {
          res += YYFPRINTF (yyo, "-%d", yylocp->last_line);
          if (0 <= end_col)
            res += YYFPRINTF (yyo, ".%d", end_col);
        }
      else if (0 <= end_col && yylocp->first_column < end_col)
        res += YYFPRINTF (yyo, "-%d", end_col);
    }
  return res;
 }

#  define YY_LOCATION_PRINT(File, Loc)          \
  yy_location_print_ (File, &(Loc))

# else
#  define YY_LOCATION_PRINT(File, Loc) ((void) 0)
# endif
#endif


# define YY_SYMBOL_PRINT(Title, Type, Value, Location)                    \
do {                                                                      \
  if (yydebug)                                                            \
    {                                                                     \
      YYFPRINTF (stderr, "%s ", Title);                                   \
      yy_symbol_print (stderr,                                            \
                  Type, Value, Location); \
      YYFPRINTF (stderr, "\n");                                           \
    }                                                                     \
} while (0)


/*----------------------------------------.
| Print this symbol's value on YYOUTPUT.  |
`----------------------------------------*/

static void
yy_symbol_value_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep, YYLTYPE const * const yylocationp)
{
  FILE *yyo = yyoutput;
  YYUSE (yyo);
  YYUSE (yylocationp);
  if (!yyvaluep)
    return;
# ifdef YYPRINT
  if (yytype < YYNTOKENS)
    YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# endif
  YYUSE (yytype);
}


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

static void
yy_symbol_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep, YYLTYPE const * const yylocationp)
{
  YYFPRINTF (yyoutput, "%s %s (",
             yytype < YYNTOKENS ? "token" : "nterm", yytname[yytype]);

  YY_LOCATION_PRINT (yyoutput, *yylocationp);
  YYFPRINTF (yyoutput, ": ");
  yy_symbol_value_print (yyoutput, yytype, yyvaluep, yylocationp);
  YYFPRINTF (yyoutput, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

static void
yy_stack_print (yytype_int16 *yybottom, yytype_int16 *yytop)
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)                            \
do {                                                            \
  if (yydebug)                                                  \
    yy_stack_print ((Bottom), (Top));                           \
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

static void
yy_reduce_print (yytype_int16 *yyssp, YYSTYPE *yyvsp, YYLTYPE *yylsp, int yyrule)
{
  unsigned long int yylno = yyrline[yyrule];
  int yynrhs = yyr2[yyrule];
  int yyi;
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %lu):\n",
             yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr,
                       yystos[yyssp[yyi + 1 - yynrhs]],
                       &(yyvsp[(yyi + 1) - (yynrhs)])
                       , &(yylsp[(yyi + 1) - (yynrhs)])                       );
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)          \
do {                                    \
  if (yydebug)                          \
    yy_reduce_print (yyssp, yyvsp, yylsp, Rule); \
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YY_SYMBOL_PRINT(Title, Type, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif


#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined __GLIBC__ && defined _STRING_H
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
static YYSIZE_T
yystrlen (const char *yystr)
{
  YYSIZE_T yylen;
  for (yylen = 0; yystr[yylen]; yylen++)
    continue;
  return yylen;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined __GLIBC__ && defined _STRING_H && defined _GNU_SOURCE
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
static char *
yystpcpy (char *yydest, const char *yysrc)
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

# ifndef yytnamerr
/* Copy to YYRES the contents of YYSTR after stripping away unnecessary
   quotes and backslashes, so that it's suitable for yyerror.  The
   heuristic is that double-quoting is unnecessary unless the string
   contains an apostrophe, a comma, or backslash (other than
   backslash-backslash).  YYSTR is taken from yytname.  If YYRES is
   null, do not copy; instead, return the length of what the result
   would have been.  */
static YYSIZE_T
yytnamerr (char *yyres, const char *yystr)
{
  if (*yystr == '"')
    {
      YYSIZE_T yyn = 0;
      char const *yyp = yystr;

      for (;;)
        switch (*++yyp)
          {
          case '\'':
          case ',':
            goto do_not_strip_quotes;

          case '\\':
            if (*++yyp != '\\')
              goto do_not_strip_quotes;
            /* Fall through.  */
          default:
            if (yyres)
              yyres[yyn] = *yyp;
            yyn++;
            break;

          case '"':
            if (yyres)
              yyres[yyn] = '\0';
            return yyn;
          }
    do_not_strip_quotes: ;
    }

  if (! yyres)
    return yystrlen (yystr);

  return yystpcpy (yyres, yystr) - yyres;
}
# endif

/* Copy into *YYMSG, which is of size *YYMSG_ALLOC, an error message
   about the unexpected token YYTOKEN for the state stack whose top is
   YYSSP.

   Return 0 if *YYMSG was successfully written.  Return 1 if *YYMSG is
   not large enough to hold the message.  In that case, also set
   *YYMSG_ALLOC to the required number of bytes.  Return 2 if the
   required number of bytes is too large to store.  */
static int
yysyntax_error (YYSIZE_T *yymsg_alloc, char **yymsg,
                yytype_int16 *yyssp, int yytoken)
{
  YYSIZE_T yysize0 = yytnamerr (YY_NULLPTR, yytname[yytoken]);
  YYSIZE_T yysize = yysize0;
  enum { YYERROR_VERBOSE_ARGS_MAXIMUM = 5 };
  /* Internationalized format string. */
  const char *yyformat = YY_NULLPTR;
  /* Arguments of yyformat. */
  char const *yyarg[YYERROR_VERBOSE_ARGS_MAXIMUM];
  /* Number of reported tokens (one for the "unexpected", one per
     "expected"). */
  int yycount = 0;

  /* There are many possibilities here to consider:
     - If this state is a consistent state with a default action, then
       the only way this function was invoked is if the default action
       is an error action.  In that case, don't check for expected
       tokens because there are none.
     - The only way there can be no lookahead present (in yychar) is if
       this state is a consistent state with a default action.  Thus,
       detecting the absence of a lookahead is sufficient to determine
       that there is no unexpected or expected token to report.  In that
       case, just report a simple "syntax error".
     - Don't assume there isn't a lookahead just because this state is a
       consistent state with a default action.  There might have been a
       previous inconsistent state, consistent state with a non-default
       action, or user semantic action that manipulated yychar.
     - Of course, the expected token list depends on states to have
       correct lookahead information, and it depends on the parser not
       to perform extra reductions after fetching a lookahead from the
       scanner and before detecting a syntax error.  Thus, state merging
       (from LALR or IELR) and default reductions corrupt the expected
       token list.  However, the list is correct for canonical LR with
       one exception: it will still contain any token that will not be
       accepted due to an error action in a later state.
  */
  if (yytoken != YYEMPTY)
    {
      int yyn = yypact[*yyssp];
      yyarg[yycount++] = yytname[yytoken];
      if (!yypact_value_is_default (yyn))
        {
          /* Start YYX at -YYN if negative to avoid negative indexes in
             YYCHECK.  In other words, skip the first -YYN actions for
             this state because they are default actions.  */
          int yyxbegin = yyn < 0 ? -yyn : 0;
          /* Stay within bounds of both yycheck and yytname.  */
          int yychecklim = YYLAST - yyn + 1;
          int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
          int yyx;

          for (yyx = yyxbegin; yyx < yyxend; ++yyx)
            if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR
                && !yytable_value_is_error (yytable[yyx + yyn]))
              {
                if (yycount == YYERROR_VERBOSE_ARGS_MAXIMUM)
                  {
                    yycount = 1;
                    yysize = yysize0;
                    break;
                  }
                yyarg[yycount++] = yytname[yyx];
                {
                  YYSIZE_T yysize1 = yysize + yytnamerr (YY_NULLPTR, yytname[yyx]);
                  if (! (yysize <= yysize1
                         && yysize1 <= YYSTACK_ALLOC_MAXIMUM))
                    return 2;
                  yysize = yysize1;
                }
              }
        }
    }

  switch (yycount)
    {
# define YYCASE_(N, S)                      \
      case N:                               \
        yyformat = S;                       \
      break
      YYCASE_(0, YY_("syntax error"));
      YYCASE_(1, YY_("syntax error, unexpected %s"));
      YYCASE_(2, YY_("syntax error, unexpected %s, expecting %s"));
      YYCASE_(3, YY_("syntax error, unexpected %s, expecting %s or %s"));
      YYCASE_(4, YY_("syntax error, unexpected %s, expecting %s or %s or %s"));
      YYCASE_(5, YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s"));
# undef YYCASE_
    }

  {
    YYSIZE_T yysize1 = yysize + yystrlen (yyformat);
    if (! (yysize <= yysize1 && yysize1 <= YYSTACK_ALLOC_MAXIMUM))
      return 2;
    yysize = yysize1;
  }

  if (*yymsg_alloc < yysize)
    {
      *yymsg_alloc = 2 * yysize;
      if (! (yysize <= *yymsg_alloc
             && *yymsg_alloc <= YYSTACK_ALLOC_MAXIMUM))
        *yymsg_alloc = YYSTACK_ALLOC_MAXIMUM;
      return 1;
    }

  /* Avoid sprintf, as that infringes on the user's name space.
     Don't have undefined behavior even if the translation
     produced a string with the wrong number of "%s"s.  */
  {
    char *yyp = *yymsg;
    int yyi = 0;
    while ((*yyp = *yyformat) != '\0')
      if (*yyp == '%' && yyformat[1] == 's' && yyi < yycount)
        {
          yyp += yytnamerr (yyp, yyarg[yyi++]);
          yyformat += 2;
        }
      else
        {
          yyp++;
          yyformat++;
        }
  }
  return 0;
}
#endif /* YYERROR_VERBOSE */

/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

static void
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep, YYLTYPE *yylocationp)
{
  YYUSE (yyvaluep);
  YYUSE (yylocationp);
  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yytype, yyvaluep, yylocationp);

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YYUSE (yytype);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}




/* The lookahead symbol.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;
/* Location data for the lookahead symbol.  */
YYLTYPE yylloc
# if defined YYLTYPE_IS_TRIVIAL && YYLTYPE_IS_TRIVIAL
  = { 1, 1, 1, 1 }
# endif
;
/* Number of syntax errors so far.  */
int yynerrs;


/*----------.
| yyparse.  |
`----------*/

int
yyparse (void)
{
    int yystate;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus;

    /* The stacks and their tools:
       'yyss': related to states.
       'yyvs': related to semantic values.
       'yyls': related to locations.

       Refer to the stacks through separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* The state stack.  */
    yytype_int16 yyssa[YYINITDEPTH];
    yytype_int16 *yyss;
    yytype_int16 *yyssp;

    /* The semantic value stack.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs;
    YYSTYPE *yyvsp;

    /* The location stack.  */
    YYLTYPE yylsa[YYINITDEPTH];
    YYLTYPE *yyls;
    YYLTYPE *yylsp;

    /* The locations where the error started and ended.  */
    YYLTYPE yyerror_range[3];

    YYSIZE_T yystacksize;

  int yyn;
  int yyresult;
  /* Lookahead token as an internal (translated) token number.  */
  int yytoken = 0;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;
  YYLTYPE yyloc;

#if YYERROR_VERBOSE
  /* Buffer for error messages, and its allocated size.  */
  char yymsgbuf[128];
  char *yymsg = yymsgbuf;
  YYSIZE_T yymsg_alloc = sizeof yymsgbuf;
#endif

#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N), yylsp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  yyssp = yyss = yyssa;
  yyvsp = yyvs = yyvsa;
  yylsp = yyls = yylsa;
  yystacksize = YYINITDEPTH;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY; /* Cause a token to be read.  */
  yylsp[0] = yylloc;
  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyss + yystacksize - 1 <= yyssp)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
        /* Give user a chance to reallocate the stack.  Use copies of
           these so that the &'s don't force the real ones into
           memory.  */
        YYSTYPE *yyvs1 = yyvs;
        yytype_int16 *yyss1 = yyss;
        YYLTYPE *yyls1 = yyls;

        /* Each stack pointer address is followed by the size of the
           data in use in that stack, in bytes.  This used to be a
           conditional around just the two extra args, but that might
           be undefined if yyoverflow is a macro.  */
        yyoverflow (YY_("memory exhausted"),
                    &yyss1, yysize * sizeof (*yyssp),
                    &yyvs1, yysize * sizeof (*yyvsp),
                    &yyls1, yysize * sizeof (*yylsp),
                    &yystacksize);

        yyls = yyls1;
        yyss = yyss1;
        yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyexhaustedlab;
# else
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
        goto yyexhaustedlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
        yystacksize = YYMAXDEPTH;

      {
        yytype_int16 *yyss1 = yyss;
        union yyalloc *yyptr =
          (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
        if (! yyptr)
          goto yyexhaustedlab;
        YYSTACK_RELOCATE (yyss_alloc, yyss);
        YYSTACK_RELOCATE (yyvs_alloc, yyvs);
        YYSTACK_RELOCATE (yyls_alloc, yyls);
#  undef YYSTACK_RELOCATE
        if (yyss1 != yyssa)
          YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;
      yylsp = yyls + yysize - 1;

      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
                  (unsigned long int) yystacksize));

      if (yyss + yystacksize - 1 <= yyssp)
        YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  if (yystate == YYFINAL)
    YYACCEPT;

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

  /* Do appropriate processing given the current state.  Read a
     lookahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to lookahead token.  */
  yyn = yypact[yystate];
  if (yypact_value_is_default (yyn))
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid lookahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = yylex ();
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yytable_value_is_error (yyn))
        goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the lookahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);

  /* Discard the shifted token.  */
  yychar = YYEMPTY;

  yystate = yyn;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END
  *++yylsp = yylloc;
  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     '$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];

  /* Default location.  */
  YYLLOC_DEFAULT (yyloc, (yylsp - yylen), yylen);
  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 6:
#line 137 "parser.y" /* yacc.c:1646  */
    {
					bool redeclared = false;

					t_val = type[type_indicator++];
					type_indicator %= 2;
					t_ret = type[type_indicator];
					
					temp = gtable;
					found = false;
					
					// check for function redeclaration
					while(temp != NULL) {	// search in the global table

						if(strcmp(temp->name, (yyvsp[-4].s)) == 0) {
							
							found = true; // found the same name in global table

							if(temp->declared) {
								if(temp->ret_type != t_ret || temp->val_type != t_val) {
									redeclared = true;
									printf("ERROR: redeclaring %s with different signature in line %d.\n", 
																							(yyvsp[-4].s), yylineno);
								}
							}
							else {
								redeclared = true;
								printf("ERROR: redeclaring variable %s as a function in line %d.\n", 
																					(yyvsp[-4].s), yylineno);
							}
							break;
						}

						temp = temp->next;
					}

					if(!found) {	/* function is not redeclared */

						temp = (sym *)malloc(sizeof(sym));
						
						strcpy(temp->name, (yyvsp[-4].s));
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
									data_type[t_ret], (yyvsp[-4].s), data_type[t_val], yylineno);
					}
				}
#line 1585 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 7:
#line 202 "parser.y" /* yacc.c:1646  */
    {yyerrok; }
#line 1591 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 8:
#line 206 "parser.y" /* yacc.c:1646  */
    {
						bool mismatched = false;
						
						t_val = type[type_indicator++];
						type_indicator %= 2;
						t_ret = type[type_indicator];

						temp = gtable;
						found = false;

						// check if function definition mismatched with declaration
						while(temp != NULL) {	// search for function decl in global table

							if((strcmp(temp->name, (yyvsp[-4].s)) == 0) && (temp->declared)) {
								
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

							strcpy(temp->name, (yyvsp[-4].s));
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

							printf("function %s defined in line %d\n", (yyvsp[-4].s), yylineno);
							temp->implemented = true;
							temp->def_lineno = yylineno;

							global = false;	// entered local scope

							/* ==== add function parameter to local table ==== */
						
							temp = (sym *)malloc(sizeof(sym));

							strcpy(temp->name, (yyvsp[-1].s));
							temp->val_type = t_val;
							temp->isGlobal = false;
							temp->lineno = yylineno;
						
							temp->declared = false;
							temp->implemented = false;
							temp->next = NULL;

							ltable = temp;

							printf("Local %s variable %s declared in line %d\n", 
												data_type[t_val], (yyvsp[-1].s), yylineno);
						}
					}
#line 1679 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 9:
#line 290 "parser.y" /* yacc.c:1646  */
    {
						global = true; // local scope ended
						
						/* free up memory for local table */
						while(ltable != NULL) {
							temp = ltable;
							ltable = ltable->next;
							free(temp);
						}
					}
#line 1694 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 16:
#line 315 "parser.y" /* yacc.c:1646  */
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

			}
#line 1805 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 17:
#line 422 "parser.y" /* yacc.c:1646  */
    {
				while(head != NULL) {
					temp = head;
					head = head->next;
					free(temp);
				}
				yyerrok;
			}
#line 1818 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 18:
#line 433 "parser.y" /* yacc.c:1646  */
    {	 
				type_indicator++;
				type_indicator %= 2;	
				type[type_indicator] = TYPE_INT; 
			}
#line 1828 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 19:
#line 439 "parser.y" /* yacc.c:1646  */
    {
				type_indicator++;
				type_indicator %= 2;	
				type[type_indicator] = TYPE_FLOAT;
			}
#line 1838 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 27:
#line 458 "parser.y" /* yacc.c:1646  */
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
#line 1891 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 38:
#line 525 "parser.y" /* yacc.c:1646  */
    {
					if(head == NULL) {
						head = (sym *)malloc(sizeof(sym));

						strcpy(head->name, (yyvsp[0].s));

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
#line 1916 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 41:
#line 550 "parser.y" /* yacc.c:1646  */
    {	
						if(tail != NULL) {
							tail->next = (sym *)malloc(sizeof(sym));
							tail = tail->next;

							strcpy(tail->name, (yyvsp[0].s));

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
#line 1940 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 48:
#line 582 "parser.y" /* yacc.c:1646  */
    {
					funcAsVar = false;
					found = false;

					if(ltable != NULL) {
						temp = ltable;
						while(temp != NULL) { /* local symbol table */
							if(strcmp(temp->name, (yyvsp[-2].s)) == 0) {
								printf("Local %s variable %s declared in line %d used in line %d.\n", 
										data_type[temp->val_type], temp->name, temp->lineno, yylineno);

								// AST =======================================================================

								if((yyvsp[0].a)->datatype != temp->val_type) {
								
									printf("ERROR: Value of wrong type assigned to %s variable %s. Line: %d.\n",
																		data_type[temp->val_type], temp->name, yylineno);
									(yyval.a) = NULL;
								}
								else {
									(yyval.a) = (yyvsp[0].a);
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
							if(strcmp(temp->name, (yyvsp[-2].s)) == 0 && !(temp->declared) && !(temp->implemented)) {
								printf("Global %s variable %s declared in line %d used in line %d.\n", 
									temp->val_type, temp->name, temp->lineno, yylineno);

								// AST =======================================================================

								if((yyvsp[0].a)->datatype != temp->val_type) {
									
									printf("ERROR: Value of wrong type assigned to %s variable %s. Line: %d.\n",
																		temp->val_type, temp->name, yylineno);
									(yyval.a) = NULL;
								}
								else {
									(yyval.a) = (yyvsp[0].a);
								}
								// ===========================================================================

								found = true;
								break;
							}
							if(strcmp(temp->name, (yyvsp[-2].s)) == 0 && (temp->declared || temp->implemented)) {
								funcAsVar = true;
								(yyval.a) = NULL;
							}
							temp = temp->next;
						}
					}
					if(!found) {
						if(funcAsVar)
							printf("ERROR line %d: function %s used as a variable.\n", yylineno, (yyvsp[-2].s));
						else {
							printf("ERROR line %d: variable %s not declared.\n", yylineno, (yyvsp[-2].s));
							// AST
							(yyval.a) = NULL;
						}
					}
				}
#line 2015 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 50:
#line 656 "parser.y" /* yacc.c:1646  */
    { 
					(yyval.a) = newast('+', (yyvsp[-2].a), (yyvsp[0].a));

					if((yyvsp[-2].a)->datatype != (yyvsp[0].a)->datatype) { // error: mixed types in arithmetic op
						
						if((yyvsp[-2].a)->nodetype == 'I') {
							struct idval *temp = (struct idval *)(yyvsp[-2].a);
							printf("ERROR: Adding %s \"%s\" (declared on line %d) to ", 
									data_type[temp->datatype], temp->name, temp->decl_lineno);
						}
						else {
							printf("ERROR: Adding %s value to ", data_type[(yyvsp[-2].a)->datatype]);
						}

						if((yyvsp[0].a)->nodetype == 'I') {
							struct idval *temp = (struct idval *)(yyvsp[0].a);
							printf("%s \"%s\" (declared on line %d). Line: %d\n", 
									data_type[temp->datatype], temp->name, temp->decl_lineno, yylineno);
						}
						else {
							printf("%s value. Line: %d\n", data_type[(yyvsp[0].a)->datatype], yylineno);
						}
					}
				}
#line 2044 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 51:
#line 681 "parser.y" /* yacc.c:1646  */
    {
					(yyval.a) = newast('-', (yyvsp[-2].a), (yyvsp[0].a));

					if((yyvsp[-2].a)->datatype != (yyvsp[0].a)->datatype) { // error: mixed types in arithmetic op

						if((yyvsp[-2].a)->nodetype == 'I') {
							struct idval *temp = (struct idval *)(yyvsp[-2].a);
							printf("ERROR: From %s \"%s\" (declared on line %d) ", 
									data_type[temp->datatype], temp->name, temp->decl_lineno);
						}
						else {
							printf("ERROR: From %s value ", data_type[(yyvsp[-2].a)->datatype]);
						}

						if((yyvsp[0].a)->nodetype == 'I') {
							struct idval *temp = (struct idval *)(yyvsp[0].a);
							printf("subtract %s \"%s\" (declared on line %d). Line: %d\n", 
									data_type[temp->datatype], temp->name, temp->decl_lineno, yylineno);
						}
						else {
							printf("subtract %s value. Line: %d\n", data_type[(yyvsp[0].a)->datatype], yylineno);
						}

					}
				}
#line 2074 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 52:
#line 707 "parser.y" /* yacc.c:1646  */
    {
					(yyval.a) = newast('*', (yyvsp[-2].a), (yyvsp[0].a));

 					if((yyvsp[-2].a)->datatype != (yyvsp[0].a)->datatype) { // error: mixed types in arithmetic op

						if((yyvsp[-2].a)->nodetype == 'I') {
							struct idval *temp = (struct idval *)(yyvsp[-2].a);
							printf("ERROR: Multiplying %s \"%s\" (declared on line %d) by ", 
									data_type[temp->datatype], temp->name, temp->decl_lineno);
						}
						else {
							printf("ERROR: Multiplying %s value by ", data_type[(yyvsp[-2].a)->datatype]);
						}

						if((yyvsp[0].a)->nodetype == 'I') {
							struct idval *temp = (struct idval *)(yyvsp[0].a);
							printf("%s \"%s\" (declared on line %d). Line: %d\n", 
									data_type[temp->datatype], temp->name, temp->decl_lineno, yylineno);
						}
						else {
							printf("%s value. Line: %d\n", data_type[(yyvsp[0].a)->datatype], yylineno);
						}

					}
				}
#line 2104 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 53:
#line 733 "parser.y" /* yacc.c:1646  */
    {
					(yyval.a) = newast('/', (yyvsp[-2].a), (yyvsp[0].a));

					if((yyvsp[-2].a)->datatype != (yyvsp[0].a)->datatype) { // error: mixed types in arithmetic op

						if((yyvsp[-2].a)->nodetype == 'I') {
							struct idval *temp = (struct idval *)(yyvsp[-2].a);
							printf("ERROR: dividing %s \"%s\" (declared on line %d) by ", 
									data_type[temp->datatype], temp->name, temp->decl_lineno);
						}
						else {
							printf("ERROR: dividing %s value by ", data_type[(yyvsp[-2].a)->datatype]);
						}

						if((yyvsp[0].a)->nodetype == 'I') {
							struct idval *temp = (struct idval *)(yyvsp[0].a);
							printf("%s \"%s\" (declared on line %d). Line: %d\n", 
								data_type[temp->datatype], temp->name, temp->decl_lineno, yylineno);
						}
						else {
							printf("%s value. Line: %d\n", data_type[(yyvsp[0].a)->datatype], yylineno);
						}
					}
				}
#line 2133 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 54:
#line 757 "parser.y" /* yacc.c:1646  */
    { (yyval.a) = newast('M', (yyvsp[0].a), NULL); }
#line 2139 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 56:
#line 761 "parser.y" /* yacc.c:1646  */
    { (yyval.a) = newnum((yyvsp[0].i), TYPE_INT); }
#line 2145 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 57:
#line 762 "parser.y" /* yacc.c:1646  */
    { (yyval.a) = newnum((yyvsp[0].d), TYPE_FLOAT); }
#line 2151 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 59:
#line 764 "parser.y" /* yacc.c:1646  */
    { (yyval.a) = (yyvsp[-1].a); }
#line 2157 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 60:
#line 766 "parser.y" /* yacc.c:1646  */
    {
					found = false;
					funcAsVar = false;

					if(ltable != NULL) {
						temp = ltable;
						while(temp != NULL) {
							if(strcmp(temp->name, (yyvsp[0].s)) == 0) {
								printf("Local %s variable %s declared in line %d used in line %d.\n", 
												data_type[temp->val_type], temp->name, temp->lineno, yylineno);
								
								// AST TODO: temporary ID value
								(yyval.a) = newid(0.0, temp->val_type, temp->name, temp->lineno, yylineno);

								found = true;
								break;
							}
							temp = temp->next;
						}
					}
					if(found == false && gtable != NULL) {
						temp = gtable;
						while(temp != NULL) {
							if(strcmp(temp->name, (yyvsp[0].s)) == 0 && !(temp->declared) && !(temp->implemented)) {
								printf("Global %s variable %s declared in line %d used in line %d.\n", 
												data_type[temp->val_type], temp->name, temp->lineno, yylineno);
								
								// AST TODO: temporary ID value
								(yyval.a) = newid(0.0, temp->val_type, temp->name, temp->lineno, yylineno);

								found = true;
								break;
							}
							if(strcmp(temp->name, (yyvsp[0].s)) == 0 && (temp->declared || temp->implemented)) {
								funcAsVar = true;
								// AST
								(yyval.a) = newid(0.0, TYPE_INVALID, (yyvsp[0].s), 0, yylineno);
							}
							temp = temp->next;
						}
					}
					if(!found) {
						if(funcAsVar)
							printf("ERROR line %d: function %s used as a variable.\n", yylineno, (yyvsp[0].s));
						else {
							printf("ERROR line %d: variable %s not declared.\n", yylineno, (yyvsp[0].s));
							// AST
							(yyval.a) = newid(0.0, TYPE_INVALID, (yyvsp[0].s), 0, yylineno);
						}
					}
				}
#line 2213 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 61:
#line 820 "parser.y" /* yacc.c:1646  */
    {
						varAsFunc = false;
						found = false;

						if(ltable != NULL) {
							temp = ltable;
							while(temp != NULL) { /* check if a variable is used as a function */
								if(strcmp(temp->name, (yyvsp[-3].s)) == 0) {
									printf("ERROR line %d: variable %s used as function.\n", 
																		yylineno, temp->name);

									// AST
									(yyval.a) = newnum(0.0, TYPE_INVALID);

									found = true;
									break;
								}
								temp = temp->next;
							}
						}
						if(found == false && gtable != NULL) {
							temp = gtable;
							while(temp != NULL) {
								if(strcmp(temp->name, (yyvsp[-3].s)) == 0) {
									if(temp->implemented) {
										temp->called = true;
										printf("Function %s defined in line %d used in line %d.\n", 
															temp->name, temp->def_lineno, yylineno);
										// AST ==================================================================
										(yyval.a) = newnum(0.0, temp->ret_type);

										if((yyvsp[-1].a)->datatype != temp->val_type) {
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
										(yyval.a) = newnum(0.0, temp->ret_type);
										
										if((yyvsp[-1].a)->datatype != temp->val_type) {
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
										(yyval.a) = newnum(0.0, TYPE_INVALID);
									}
								}
								temp = temp->next;
							}
							if(!found) {
								if(varAsFunc)
									printf("ERROR line %d: variable %s used as a function.\n", yylineno, (yyvsp[-3].s));
								else {
									printf("ERROR line %d: function %s is not declared.\n", yylineno, (yyvsp[-3].s));
									// AST
									(yyval.a) = newnum(0.0, TYPE_INVALID);
								}
							}
						}
					}
#line 2291 "parser.tab.c" /* yacc.c:1646  */
    break;


#line 2295 "parser.tab.c" /* yacc.c:1646  */
      default: break;
    }
  /* User semantic actions sometimes alter yychar, and that requires
     that yytoken be updated with the new translation.  We take the
     approach of translating immediately before every use of yytoken.
     One alternative is translating here after every semantic action,
     but that translation would be missed if the semantic action invokes
     YYABORT, YYACCEPT, or YYERROR immediately after altering yychar or
     if it invokes YYBACKUP.  In the case of YYABORT or YYACCEPT, an
     incorrect destructor might then be invoked immediately.  In the
     case of YYERROR or YYBACKUP, subsequent parser actions might lead
     to an incorrect destructor call or verbose syntax error message
     before the lookahead is translated.  */
  YY_SYMBOL_PRINT ("-> $$ =", yyr1[yyn], &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;
  *++yylsp = yyloc;

  /* Now 'shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTOKENS] + *yyssp;
  if (0 <= yystate && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTOKENS];

  goto yynewstate;


/*--------------------------------------.
| yyerrlab -- here on detecting error.  |
`--------------------------------------*/
yyerrlab:
  /* Make sure we have latest lookahead translation.  See comments at
     user semantic actions for why this is necessary.  */
  yytoken = yychar == YYEMPTY ? YYEMPTY : YYTRANSLATE (yychar);

  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if ! YYERROR_VERBOSE
      yyerror (YY_("syntax error"));
#else
# define YYSYNTAX_ERROR yysyntax_error (&yymsg_alloc, &yymsg, \
                                        yyssp, yytoken)
      {
        char const *yymsgp = YY_("syntax error");
        int yysyntax_error_status;
        yysyntax_error_status = YYSYNTAX_ERROR;
        if (yysyntax_error_status == 0)
          yymsgp = yymsg;
        else if (yysyntax_error_status == 1)
          {
            if (yymsg != yymsgbuf)
              YYSTACK_FREE (yymsg);
            yymsg = (char *) YYSTACK_ALLOC (yymsg_alloc);
            if (!yymsg)
              {
                yymsg = yymsgbuf;
                yymsg_alloc = sizeof yymsgbuf;
                yysyntax_error_status = 2;
              }
            else
              {
                yysyntax_error_status = YYSYNTAX_ERROR;
                yymsgp = yymsg;
              }
          }
        yyerror (yymsgp);
        if (yysyntax_error_status == 2)
          goto yyexhaustedlab;
      }
# undef YYSYNTAX_ERROR
#endif
    }

  yyerror_range[1] = yylloc;

  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
         error, discard it.  */

      if (yychar <= YYEOF)
        {
          /* Return failure if at end of input.  */
          if (yychar == YYEOF)
            YYABORT;
        }
      else
        {
          yydestruct ("Error: discarding",
                      yytoken, &yylval, &yylloc);
          yychar = YYEMPTY;
        }
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:

  /* Pacify compilers like GCC when the user code never invokes
     YYERROR and the label yyerrorlab therefore never appears in user
     code.  */
  if (/*CONSTCOND*/ 0)
     goto yyerrorlab;

  yyerror_range[1] = yylsp[1-yylen];
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;      /* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (!yypact_value_is_default (yyn))
        {
          yyn += YYTERROR;
          if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
            {
              yyn = yytable[yyn];
              if (0 < yyn)
                break;
            }
        }

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
        YYABORT;

      yyerror_range[1] = *yylsp;
      yydestruct ("Error: popping",
                  yystos[yystate], yyvsp, yylsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END

  yyerror_range[2] = yylloc;
  /* Using YYLLOC is tempting, but would change the location of
     the lookahead.  YYLOC is available though.  */
  YYLLOC_DEFAULT (yyloc, yyerror_range, 2);
  *++yylsp = yyloc;

  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", yystos[yyn], yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;

#if !defined yyoverflow || YYERROR_VERBOSE
/*-------------------------------------------------.
| yyexhaustedlab -- memory exhaustion comes here.  |
`-------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
  if (yychar != YYEMPTY)
    {
      /* Make sure we have latest lookahead translation.  See comments at
         user semantic actions for why this is necessary.  */
      yytoken = YYTRANSLATE (yychar);
      yydestruct ("Cleanup: discarding lookahead",
                  yytoken, &yylval, &yylloc);
    }
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
                  yystos[*yyssp], yyvsp, yylsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
#if YYERROR_VERBOSE
  if (yymsg != yymsgbuf)
    YYSTACK_FREE (yymsg);
#endif
  return yyresult;
}
#line 895 "parser.y" /* yacc.c:1906  */


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

