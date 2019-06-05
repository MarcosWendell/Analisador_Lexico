%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char*);
int yylex(void);
%}

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
        | PROGRAM IDENT ';' error '.' {yyerror("Erro sintatico - erro no corpo do programa.");}
        ;
corpo: dc BEGIN_ comandos END
      | error BEGIN_ comandos END {yyerror("Erro sintatico - erro na declaracao de variaveis.");}
      | dc BEGIN_ error END {yyerror("Erro sintatico - erro nos comandos do programa.");}
      ;
dc: dc_c dc_v dc_p
    /* | error dc_v dc_p {yyerror("");}
    | dc_c error dc_p {yyerror("");}
    | dc_c dc_v error {yyerror("");} */
    ;
dc_c: CONST IDENT '=' numero';'dc_c
    | CONST IDENT '=' error';'dc_c {yyerror("");}
    /* | CONST IDENT '=' numero';'error {yyerror("");} */
    | %empty
    ;
dc_v: VAR variaveis ':' tipo_var ';' dc_v
    | VAR error ':' tipo_var ';' dc_v {yyerror("");}
    | VAR variaveis ':' error ';' dc_v {yyerror("");}
    /* | VAR variaveis ':' tipo_var ';' error {yyerror("");} */
    | %empty
    ;
tipo_var: REAL
        | INTEGER
        ;
variaveis: IDENT mais_var
        /* | IDENT error {yyerror("");} */
        ;
mais_var: ','variaveis
        /* | ','error {yyerror("");} */
        | %empty
        ;
dc_p: PROCEDURE IDENT parametros';'corpo_p dc_p
    | PROCEDURE IDENT error';'corpo_p dc_p {yyerror("");}
    /* | PROCEDURE IDENT parametros';'error dc_p {yyerror("");} */
    /* | PROCEDURE IDENT parametros';'corpo_p error {yyerror("");} */
    | %empty
    ;
parametros: '('lista_par')'
          | '('error')' {yyerror("");}
          | %empty
          ;
lista_par: variaveis ':' tipo_var mais_par
          | error ':' tipo_var mais_par {yyerror("");}
          /* | variaveis ':' error mais_par {yyerror("");} */
          /* | variaveis ':' tipo_var error {yyerror("");} */
          ;
mais_par: ';'lista_par
        /* | ';'error {yyerror("");} */
        | %empty
        ;
corpo_p: dc_loc BEGIN_ comandos END';'
        | error BEGIN_ comandos END';' {yyerror("");}
        | dc_loc BEGIN_ error END';' {yyerror("");}
        ;
dc_loc: dc_v
        /* | error {yyerror("");} */
        ;
lista_arg: '('argumentos')'
          | '('error')' {yyerror("");}
          | %empty
          ;
argumentos: IDENT mais_ident
          /* | IDENT error {yyerror("");} */
          ;
mais_ident: ';'argumentos
          /* | ';'error {yyerror("");} */
          | %empty
          ;
pfalsa: ELSE cmd
      /* | ELSE error {yyerror("");} */
      | %empty %prec LOWER_THAN_ELSE
      ;
comandos: cmd ';' comandos
        | error ';' comandos {yyerror("");}
        /* | cmd ';' error {yyerror("");} */
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
    | WRITE'('error')' {yyerror("");}
    | WHILE'('error')' DO cmd {yyerror("");}
    /* | WHILE'('condicao')' DO error {yyerror("");} */
    /* | FOR IDENT ':''=' NUMERO_INTEIRO TO NUMERO_INTEIRO DO error {yyerror("");} */
    | IF error THEN cmd pfalsa {yyerror("");}
    /* | IF condicao THEN error pfalsa {yyerror("");} */
    /* | IF condicao THEN cmd error {yyerror("");} */
    /* | IDENT ':''=' error {yyerror("");} */
    /* | IDENT error {yyerror("");} */
    | BEGIN_ error END {yyerror("");}
    ;
condicao: expressao relacao expressao
        /* | error relacao expressao {yyerror("");} */
        /* | expressao error expressao {yyerror("");} */
        /* | expressao relacao error {yyerror("");} */
        ;
relacao: '=''='
        | '<''>'
        | '>''='
        | '<''='
        | '>'
        | '<'
        ;
expressao: termo outros_termos
        /* | error outros_termos {yyerror("");} */
        /* | termo error {yyerror("");} */
        ;
op_un: '+'
      | '-'
      | %empty
      ;
outros_termos: op_ad termo outros_termos
              /* | error termo outros_termos {yyerror("");} */
              /* | op_ad error outros_termos {yyerror("");} */
              /* | op_ad termo error {yyerror("");} */
              | %empty
              ;
op_ad: '+'
      | '-'
      ;
termo: op_un fator mais_fatores
      /* | error fator mais_fatores {yyerror("");} */
      /* | op_un error mais_fatores {yyerror("");} */
      /* | op_un fator error {yyerror("");} */
      ;
mais_fatores: op_mul fator mais_fatores
            /* | error fator mais_fatores {yyerror("");} */
            /* | op_mul error mais_fatores {yyerror("");} */
            /* | op_mul fator error {yyerror("");} */
            | %empty
            ;
op_mul: '*'
      | '/'
      ;
fator: IDENT
      | numero
      | '('expressao')'
      | '('error')' {yyerror("");}
      /* | error {yyerror("");} */
      ;
numero: NUMERO_INTEIRO
      | NUMERO_REAL
      ;
%%
extern int line;
void yyerror(const char *str){
  fprintf(stderr,"Erro na linha %d: %s\n",line,str);
}
