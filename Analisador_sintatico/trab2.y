%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char*);
int yylex(void);
%}

%define parse.error verbose

%union {int inteiro;
        double real;
        char * str;
}

%token PROGRAM BEGIN_ END CONST VAR REAL INTEGER PROCEDURE ELSE READ WHILE WRITE DO IF THEN FOR TO
%token IDENT NUMERO_INTEIRO NUMERO_REAL
%start program

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%
program: PROGRAM IDENT ';' corpo '.'
        | PROGRAM IDENT ';' error '.' 
        ;
corpo: dc BEGIN_ comandos END
      | error BEGIN_ comandos END
      | dc BEGIN_ error END
      ;
dc: dc_c dc_v dc_p
    /* | error dc_v dc_p
    | dc_c error dc_p
    | dc_c dc_v error  */
    ;
dc_c: CONST IDENT '=' numero';'dc_c
    | CONST IDENT '=' error';'dc_c
    /* | CONST IDENT '=' numero';'error  */
    | %empty
    ;
dc_v: VAR variaveis ':' tipo_var ';' dc_v
    | VAR error ':' tipo_var ';' dc_v
    | VAR variaveis ':' error ';' dc_v
    /* | VAR variaveis ':' tipo_var ';' error  */
    | %empty
    ;
tipo_var: REAL
        | INTEGER
        ;
variaveis: IDENT mais_var
        /* | IDENT error  */
        ;
mais_var: ','variaveis
        /* | ','error  */
        | %empty
        ;
dc_p: PROCEDURE IDENT parametros';'corpo_p dc_p
    | PROCEDURE IDENT error';'corpo_p dc_p
    /* | PROCEDURE IDENT parametros';'error dc_p  */
    /* | PROCEDURE IDENT parametros';'corpo_p error  */
    | %empty
    ;
parametros: '('lista_par')'
          | '('error')'
          | %empty
          ;
lista_par: variaveis ':' tipo_var mais_par
          | error ':' tipo_var mais_par
          /* | variaveis ':' error mais_par  */
          /* | variaveis ':' tipo_var error  */
          ;
mais_par: ';'lista_par
        /* | ';'error  */
        | %empty
        ;
corpo_p: dc_loc BEGIN_ comandos END';'
        | error BEGIN_ comandos END';'
        | dc_loc BEGIN_ error END';'
        ;
dc_loc: dc_v
        /* | error  */
        ;
lista_arg: '('argumentos')'
          | '('error')'
          | %empty
          ;
argumentos: IDENT mais_ident
          /* | IDENT error  */
          ;
mais_ident: ';'argumentos
          /* | ';'error  */
          | %empty
          ;
pfalsa: ELSE cmd
      /* | ELSE error  */
      | %empty %prec LOWER_THAN_ELSE
      ;
comandos: cmd ';' comandos
        | error ';' comandos
        /* | cmd ';' error  */
        | %empty
        ;
cmd: READ'('variaveis')'
    | WRITE'('variaveis')'
    | WHILE'('condicao')' DO cmd
    | FOR IDENT ':''=' NUMERO_INTEIRO TO NUMERO_INTEIRO DO cmd
    | IF condicao THEN cmd pfalsa
    | IDENT ':''=' expressao
    | IDENT lista_arg
    | BEGIN_ comandos END
    | WRITE'('error')'
    | WHILE'('error')' DO cmd
    /* | WHILE'('condicao')' DO error  */
    /* | FOR IDENT ':''=' NUMERO_INTEIRO TO NUMERO_INTEIRO DO error  */
    | IF error THEN cmd pfalsa
    /* | IF condicao THEN error pfalsa  */
    /* | IF condicao THEN cmd error  */
    /* | IDENT ':''=' error  */
    /* | IDENT error  */
    | BEGIN_ error END
    ;
condicao: expressao relacao expressao
        /* | error relacao expressao  */
        /* | expressao error expressao  */
        /* | expressao relacao error  */
        ;
relacao: '=''='
        | '<''>'
        | '>''='
        | '<''='
        | '>'
        | '<'
        ;
expressao: termo outros_termos
        /* | error outros_termos  */
        /* | termo error  */
        ;
op_un: '+'
      | '-'
      | %empty
      ;
outros_termos: op_ad termo outros_termos
              /* | error termo outros_termos  */
              /* | op_ad error outros_termos  */
              /* | op_ad termo error  */
              | %empty
              ;
op_ad: '+'
      | '-'
      ;
termo: op_un fator mais_fatores
      /* | error fator mais_fatores  */
      /* | op_un error mais_fatores  */
      /* | op_un fator error  */
      ;
mais_fatores: op_mul fator mais_fatores
            /* | error fator mais_fatores  */
            /* | op_mul error mais_fatores  */
            /* | op_mul fator error  */
            | %empty
            ;
op_mul: '*'
      | '/'
      ;
fator: IDENT
      | numero
      | '('expressao')'
      | '('error')'
      /* | error  */
      ;
numero: NUMERO_INTEIRO
      | NUMERO_REAL
      ;
%%
extern int line;
void yyerror(const char *str){
  fprintf(stderr,"Error in line %d: %s\n",line,str);
}
