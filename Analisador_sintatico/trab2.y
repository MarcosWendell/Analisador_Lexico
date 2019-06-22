%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char*);
int yylex(void);
extern int errors_found;
%}

%define parse.error verbose

/* %expect 0 */

%union {int inteiro;
        double real;
        char * str;
}

%token PROGRAM BEGIN_ END CONST VAR REAL INTEGER PROCEDURE ELSE READ WHILE WRITE DO IF THEN FOR TO
%token IDENT NUMERO_INTEIRO NUMERO_REAL CARACTER_INVALIDO
%start program

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%
program: PROGRAM IDENT ';' corpo '.'{if(errors_found != 0){
                                        YYABORT;
                                      }
                                    }
        | PROGRAM IDENT ';' error '.'{YYABORT;}
        | PROGRAM IDENT ';' error {YYABORT;}
        ;
corpo: dc BEGIN_ comandos END
      | error BEGIN_ comandos END {yyerrok;}
      | dc BEGIN_ error END {yyerrok;}
      | dc BEGIN_ error {yyerrok;}
      ;
dc: dc_c dc_v dc_p
    ;
dc_c: CONST IDENT '=' numero';'dc_c
    | CONST IDENT '=' error';'dc_c {yyerrok;}
    | CONST IDENT '=' error {yyerrok;}
    | CONST IDENT '=' numero ';' error {yyerrok;}
    | %empty
    ;
dc_v: VAR variaveis ':' tipo_var ';' dc_v
    | VAR error ':' tipo_var ';' dc_v {yyerrok;}
    | VAR error {yyerrok;}
    | VAR variaveis ':' error ';' dc_v {yyerrok;}
    | VAR variaveis ':' error {yyerrok;}
    | VAR variaveis ':' tipo_var ';' error {yyerrok;}
    | %empty
    ;
tipo_var: REAL
        | INTEGER
        ;
variaveis: IDENT mais_var
        | IDENT error {yyerrok;}
        ;
mais_var: ','variaveis
        | ','error {yyerrok;}
        | %empty
        ;
dc_p: PROCEDURE IDENT parametros';'corpo_p dc_p
    | PROCEDURE IDENT error';'corpo_p dc_p {yyerrok;}
    | PROCEDURE IDENT error {yyerrok;}
    | %empty
    ;
parametros: '('lista_par')'
          | '('error')' {yyerrok;}
          | '('error {yyerrok;}
          | %empty
          ;
lista_par: variaveis ':' tipo_var mais_par
          | error ':' tipo_var mais_par {yyerrok;}
          | variaveis ':' error mais_par {yyerrok;}
          | variaveis ':' tipo_var error {yyerrok;}
          ;
mais_par: ';'lista_par
        | ';'error {yyerrok;}
        | %empty
        ;
corpo_p: dc_loc BEGIN_ comandos END';'
        | error BEGIN_ comandos END';' {yyerrok;}
        | dc_loc BEGIN_ error END';' {yyerrok;}
        | dc_loc BEGIN_ error {yyerrok;}
        | error BEGIN_ error END';' {yyerrok;}
        ;
dc_loc: dc_v
        ;
lista_arg: '('argumentos')'
          | '('error')' {yyerrok;}
          | '('error {yyerrok;}
          | %empty
          ;
argumentos: IDENT mais_ident
          | IDENT error {yyerrok;}
          ;
mais_ident: ';'argumentos
          | ';'error
          | %empty
          ;
pfalsa: ELSE cmd
      | ELSE error {yyerrok;}
      | %empty %prec LOWER_THAN_ELSE
      ;
comandos: cmd ';' comandos
        | error ';' comandos {yyerrok;}
        | cmd ';' error {yyerrok;}
        | error ';' error {yyerrok;}
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
    | READ'('error')' {yyerrok;}
    | READ'('error {yyerrok;}
    | WRITE'('error')' {yyerrok;}
    | WRITE'('error {yyerrok;}
    | WHILE'('error')' DO cmd {yyerrok;}
    | WHILE'('error')' DO error {yyerrok;}
    | WHILE'('error {yyerrok;}
    | WHILE'('condicao')' DO error {yyerrok;}
    | IF error THEN cmd pfalsa {yyerrok;}
    | IF condicao THEN error pfalsa {yyerrok;}
    | IF error {yyerrok;}
    | IDENT ':''=' error
    | IDENT error
    | BEGIN_ error END {yyerrok;}
    ;
condicao: expressao relacao expressao
        | error relacao expressao {yyerrok;}
        | expressao error expressao {yyerrok;}
        | expressao relacao error {yyerrok;}
        | error relacao error {yyerrok;}
        ;
relacao: '=''='
        | '<''>'
        | '>''='
        | '<''='
        | '>'
        | '<'
        ;
expressao: termo outros_termos
        ;
op_un: '+'
      | '-'
      | %empty
      ;
outros_termos: op_ad termo outros_termos
              | op_ad error outros_termos {yyerrok;}
              | %empty
              ;
op_ad: '+'
      | '-'
      ;
termo: op_un fator mais_fatores
      | error fator mais_fatores {yyerrok;}
      ;
mais_fatores: op_mul fator mais_fatores
            | op_mul error mais_fatores
            | %empty
            ;
op_mul: '*'
      | '/'
      ;
fator: IDENT
      | numero
      | '('expressao')'
      | '('error')' {yyerrok;}
      ;
numero: NUMERO_INTEIRO
      | NUMERO_REAL
      ;
%%
extern int line;
void yyerror(const char *str){
  errors_found++;
  fprintf(stderr,"Error in line %d: %s\n",line,str);
}
