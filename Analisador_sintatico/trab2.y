%{
#include <stdio.h>
#include <stdlib.h>
%}

%union {int inteiro;
        double real;
        char * str;
}

%token IDENT NUMERO_INTEIRO NUMERO_REAL
%start program

%%
program: "program" IDENT";"corpo".";
corpo: dc "begin" comandos "end";
dc: dc_c dc_v dc_p;
dc_c: "const" IDENT "=" numero";"dc_c
      |
      ;
dc_v: "var" variaveis ":" tipo_var ";" dc_v
      |
      ;
tipo_var: "real"
        | "integer";
variaveis: IDENT mais_var;
mais_var: ","variaveis
        |
        ;
dc_p: "procedure" IDENT parametros";"corpo_p dc_p
    |
    ;
parametros: "("lista_par")"
          |
          ;
lista_par: variaveis ":" tipo_var mais_par;
mais_par: ";"lista_par
        |
        ;
corpo_p: dc_loc "begin" comandos "end"";";
dc_loc: dc_v;
lista_arg: "("argumentos")"
          |
          ;
argumentos: IDENT mais_ident
mais_ident: ";"argumentos
          |
          ;
pfalsa: "else" cmd
      |
      ;
comandos: cmd ";" comandos
        |
        ;
cmd: "read""("variaveis")"
    | "write""("variaveis")"
    | "while""("condicao")" "do" cmd
    | "for" IDENT ":=" expressao "to" "do" cmd
    | "if" condicao "then" cmd pfalsa
    | IDENT ":=" expressao
    | IDENT lista_arg
    | "begin" comandos "end"
    ;
condicao: expressao relacao expressao
        ;
relacao: "=="
        | "<>"
        | ">="
        | "<="
        | ">"
        | "<"
        ;
expressao: termo outros_termos
        ;
op_un: "+"
      | "-"
      |
      ;
outros_termos: op_ad termo outros_termos
              |
              ;
op_ad: "+"
      | "-"
      ;
termo: op_un fator mais_fatores
      ;
mais_fatores: op_mul fator mais_fatores
            |
            ;
op_mul: "*"
      | "/"
      ;
fator: IDENT
      | numero
      | "("expressao")"
      ;
numero: NUMERO_INTEIRO
      | NUMERO_REAL
      ;
%%
void yyerror(const char *str){
  fprintf(stderr,"error: %s\n", str);
}

int yywrap(){
  return 1;
}

main(){
  yyparse();
}
