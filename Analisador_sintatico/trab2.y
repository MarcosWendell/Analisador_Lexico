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
%token IDENT NUMERO_INTEIRO NUMERO_REAL COMMENT
%start program

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%
program: PROGRAM IDENT ';' corpo '.' {};
corpo: dc BEGIN_ comandos END {};
dc: dc_c dc_v dc_p {};
dc_c: CONST IDENT '=' numero';'dc_c {}
      |
      ;
dc_v: VAR variaveis ':' tipo_var ';' dc_v {}
      |
      ;
tipo_var: REAL {}
        | INTEGER {};
variaveis: IDENT mais_var {};
mais_var: ','variaveis {}
        |
        ;
dc_p: PROCEDURE IDENT parametros';'corpo_p dc_p {}
    |
    ;
parametros: '('lista_par')' {}
          |
          ;
lista_par: variaveis ':' tipo_var mais_par {};
mais_par: ';'lista_par {}
        |
        ;
corpo_p: dc_loc BEGIN_ comandos END';' {};
dc_loc: dc_v {};
lista_arg: '('argumentos')' {}
          |
          ;
argumentos: IDENT mais_ident {}
mais_ident: ';'argumentos {}
          |
          ;
pfalsa: ELSE cmd {}
      | %prec LOWER_THAN_ELSE {}
      ;
comandos: cmd ';' comandos {}
        |
        ;
cmd: READ'('variaveis')' {}
    | WRITE'('variaveis')' {}
    | WHILE'('condicao')' DO cmd {}
    | FOR IDENT ':''=' NUMERO_INTEIRO TO NUMERO_INTEIRO DO cmd {}
    | IF condicao THEN cmd pfalsa {}
    | IDENT ':''=' expressao {}
    | IDENT lista_arg {}
    | BEGIN_ comandos END {}
    ;
condicao: expressao relacao expressao {}
        ;
relacao: '=''='{}
        | '<''>'{}
        | '>''='{}
        | '<''='{}
        | '>'{}
        | '<'{}
        ;
expressao: termo outros_termos{}
        ;
op_un: '+'{}
      | '-'{}
      |
      ;
outros_termos: op_ad termo outros_termos{}
              |
              ;
op_ad: '+'{}
      | '-'{}
      ;
termo: op_un fator mais_fatores{}
      ;
mais_fatores: op_mul fator mais_fatores{}
            |
            ;
op_mul: '*'{}
      | '/'{}
      ;
fator: IDENT{}
      | numero{}
      | '('expressao')'{}
      ;
numero: NUMERO_INTEIRO{}
      | NUMERO_REAL{}
      ;
%%
extern int line;
void yyerror(const char *str){
  fprintf(stderr,"error: %s %d\n", str,line);
}
