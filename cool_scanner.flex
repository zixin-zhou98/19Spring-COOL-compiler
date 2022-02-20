/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */
int comment_num=0;
%}

/*
 * Define names for regular expressions here.
 */

DARROW          =>
DIGIT           [0-9]
CHAR            [A-Za-z]
LETTERDIGIT     [A-Za-z0-9_]
INVALID		"`"|"!"|"#"|"$"|"%"|"^"|"&"|"_"|"["|"]"|"|"|[\\]|">"|"?"|\0
A [Aa]
C [Cc]
D [Dd]
E [Ee]
F [Ff]
L [Ll]
S [Ss]
R [Rr]
T [Tt]
U [Uu]
H [Hh]
I [Ii]
N [Nn]
O [Oo]
P [Pp]
V [Vv]
W [Ww]
%x COMMENT
%x COMMENTDASH
%x STRING
%x STRERROR
%%
 /*
  *  Nested comments
  */
<INITIAL>"*)" {
cool_yylval.error_msg = "Unmatched *)";
return(ERROR);
}
<COMMENT>"--" {}
<INITIAL,COMMENT>"(*" {
comment_num++;
BEGIN(COMMENT);}
<COMMENT>\( {; } 
<COMMENT>\n {curr_lineno++;yylineno++;}
<COMMENT>[^\n\(\*] {/* eat up content of comment*/}
<COMMENT>\\.  { ; }
<COMMENT>\*   { ; }

<COMMENT>"*)" {
comment_num--; if (comment_num == 0){
BEGIN(INITIAL);} else if(comment_num<0)
{
BEGIN(INITIAL);
yylval.error_msg="Unmatched *)";return (ERROR);
} 
}
<COMMENT><<EOF>> {BEGIN(INITIAL);
yylval.error_msg="EOF in comment";
return (ERROR);}

 /*dash comment*/
<COMMENTDASH>"(*"|"*)" {}

<INITIAL,COMMENTDASH>"--" {BEGIN(COMMENTDASH);}
<COMMENTDASH>[^\n]* {/*Skip the content*/}
<COMMENTDASH>\n {/*printf("change line");*/
curr_lineno++;
yylineno++;
BEGIN(INITIAL);}
<COMMENTDASH><<EOF>> {BEGIN(INITIAL);/*End of file*/}

 /*Integer*/
{DIGIT}+ {
cool_yylval.symbol=inttable.add_string(yytext);
curr_lineno = yylineno;
return (INT_CONST);
 }


 /*
  *  The multiple-character operators.
  */
{DARROW}		{curr_lineno=yylineno; return (DARROW); }
"<-"                    {curr_lineno=yylineno; return (ASSIGN); }
"<="                    {curr_lineno=yylineno; return (LE); }
 /*The one character operators.*/
"{" {curr_lineno = yylineno;return int('{');}
"}" {curr_lineno = yylineno;return int('}');}
"+" {curr_lineno = yylineno;  return int('+');  }
"-" {curr_lineno = yylineno;  return int('-');  }
"*" {curr_lineno = yylineno;  return int('*');  }
"/" {curr_lineno = yylineno;  return int('/');  }
"." {curr_lineno = yylineno; return int( '.'); }
"(" {curr_lineno = yylineno; return int('('); }
")" {curr_lineno = yylineno; return int(')'); }
"~" {curr_lineno = yylineno;  return int('~');  }
"<" {curr_lineno = yylineno;  return int('<');  }
"=" {curr_lineno = yylineno;  return int('=');  }
"@" {curr_lineno = yylineno; return int('@'); }
"," {curr_lineno = yylineno; return int(','); }
";" {curr_lineno = yylineno; return int(';'); }
":" {curr_lineno = yylineno; return int(':'); }
 /*Invalid characters*/
{INVALID} {cool_yylval.error_msg = yytext;
return ERROR;}
 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */
{C}{L}{A}{S}{S}    {curr_lineno = yylineno;  return (CLASS); }
{E}{L}{S}{E} {curr_lineno = yylineno;  return (ELSE); }
"f"{A}{L}{S}{E} {curr_lineno = yylineno;cool_yylval.boolean = false;  return BOOL_CONST; }
{F}{I} {curr_lineno = yylineno;  return FI; }
{I}{F} {curr_lineno = yylineno;  return IF; }
{I}{N} {curr_lineno = yylineno;  return IN; }
{I}{N}{H}{E}{R}{I}{T}{S} {curr_lineno = yylineno;  return INHERITS; }
{I}{S}{V}{O}{I}{D} {curr_lineno = yylineno;  return ISVOID; }
{L}{E}{T} {curr_lineno = yylineno;  return LET; }
{L}{O}{O}{P} {curr_lineno = yylineno;  return LOOP; }
{P}{O}{O}{L} {curr_lineno = yylineno;  return POOL; }
{T}{H}{E}{N} {curr_lineno = yylineno;  return THEN; }
{W}{H}{I}{L}{E} {curr_lineno = yylineno;  return WHILE; }
{C}{A}{S}{E} {curr_lineno = yylineno;  return CASE; }
{E}{S}{A}{C} {curr_lineno = yylineno;  return ESAC; }
{N}{E}{W} {curr_lineno = yylineno;  return NEW; }
{O}{F} {curr_lineno = yylineno;  return OF; }
{N}{O}{T} {curr_lineno = yylineno;  return NOT; }
"t"{R}{U}{E} {curr_lineno = yylineno;cool_yylval.boolean = true;  return BOOL_CONST;}

 /*Type identifier*/
[A-Z]{LETTERDIGIT}* {cool_yylval.symbol=idtable.add_string(yytext);
curr_lineno = yylineno;
return (TYPEID);
}
 /*Object identifier*/
[a-z]{LETTERDIGIT}*|(self) {cool_yylval.symbol=idtable.add_string(yytext);
curr_lineno = yylineno;
return (OBJECTID); }
 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */
<INITIAL>\" {strcpy(string_buf,"");
BEGIN(STRING);}
<STRING>\" {BEGIN(INITIAL);
curr_lineno=yylineno;
cool_yylval.symbol=stringtable.add_string(string_buf);
return STR_CONST;}

<STRING><<EOF>> {
BEGIN(STRERROR);
cool_yylval.error_msg = "EOF in string constant";
return ERROR;
}
<STRING>>\\0|\\\0|\0 {BEGIN(STRERROR);
cool_yylval.error_msg = "String contains null character";
return ERROR;}
<STRING>\\b {
if(strlen(string_buf)+1+1>MAX_STR_CONST)
{cool_yylval.error_msg="String constant too long";
return ERROR;
}
curr_lineno=yylineno;
strcat(string_buf,"\b");
}

<STRING>\\t {
if(strlen(string_buf)+1+1>MAX_STR_CONST)
{cool_yylval.error_msg="String constant too long";
BEGIN(STRERROR);
return ERROR;
}
curr_lineno=yylineno;
strcat(string_buf,"\t");
}

<STRING>\\f {
if(strlen(string_buf)+1+1>MAX_STR_CONST)
{cool_yylval.error_msg="String constant too long";
BEGIN(STRERROR);
return ERROR;
}
curr_lineno=yylineno;
strcat(string_buf,"\f");
}
<STRING>\\\n {
if(strlen(string_buf)+1+1>MAX_STR_CONST)
{cool_yylval.error_msg="String constant too long";
BEGIN(STRERROR);
return ERROR;
}
yylineno++;
curr_lineno=yylineno;
strcat(string_buf,"\n");
}
<STRING>\\n {
if(strlen(string_buf)+1+1>MAX_STR_CONST)
{cool_yylval.error_msg="String constant too long";
BEGIN(STRERROR);
return ERROR;
}
curr_lineno=yylineno;
strcat(string_buf,"\n");
}
<STRERROR>[^\"\n]* {}
<STRERROR>\n {curr_lineno++;yylineno++; BEGIN(INITIAL);}
<STRERROR>\" {BEGIN(INITIAL);}
 /*White space*/
[\n] {curr_lineno++;yylineno++;}


<STRING>\n { 
 curr_lineno++; 
 BEGIN(INITIAL);
 cool_yylval.error_msg = "Unterminated string constant";
return(ERROR);}


<STRING>\\.  { //escaped character, just add the character
strcat(string_buf, &strdup(yytext)[1]);
if (strlen(string_buf)+1+1>MAX_STR_CONST)
 {string_buf[0] = '\0';
cool_yylval.error_msg = "String constant too long";
return ERROR; }

}
<STRING>. {
if (strlen(string_buf)+1+1>MAX_STR_CONST) 
{string_buf[0] = '\0';
cool_yylval.error_msg = "String constant too long";
return ERROR; }
strcat(string_buf, yytext);}

[ \f\r\t\v] {}
. { cool_yylval.error_msg = yytext;
return(ERROR);
}
%%