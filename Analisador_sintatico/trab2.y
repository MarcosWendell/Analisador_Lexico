%{
#include <stdio.h>
#include <stdlib.h>
#include <string>

//declaracao do cabecalho das funcoes
void yyerror(const char*);
int yylex(void);
//puxando variaveis globais do analisador lexico
extern int errors_found;
extern int line;
%}

//definindo opcao com mensagens de erro mais significativas
%define parse.error verbose

//definindo tipos que podem ser retornados em yyval
%union {int inteiro;
        double real;
        char * str;
}

//tokens do gramatica
%token PROGRAM BEGIN_ END CONST VAR REAL INTEGER PROCEDURE ELSE READ WHILE WRITE DO IF THEN FOR TO
%token IDENT NUMERO_INTEIRO NUMERO_REAL CARACTER_INVALIDO
//nao terminal inicial
%start program

//resolvendo problemas de ambiguidade da gramatica
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

//regras da grmatica LALG
%%
program: PROGRAM IDENT ';' corpo '.'{ //verificando se houve erros
                                      if(errors_found != 0){
                                        //retornado que ha erros na sintaxe
                                        YYABORT;
                                      }
                                    }
        | error {
                  //retornando que ha erros na sintaxe
                  YYABORT;
                }
        ;
corpo: dc BEGIN_ comandos END
      ;
dc: dc_c dc_v dc_p
    ;
dc_c: CONST IDENT '=' numero';'dc_c
    | %empty
    ;
dc_v: VAR variaveis ':' tipo_var ';' dc_v
    | %empty
    ;
tipo_var: REAL
        | INTEGER
        | error
        ;
variaveis: IDENT mais_var
        | error
        ;
mais_var: ','variaveis
        | error
        | %empty
        ;
dc_p: PROCEDURE IDENT parametros';'corpo_p dc_p
    | error
    | %empty
    ;
parametros: '('lista_par')'
          | error
          | %empty
          ;
lista_par: variaveis ':' tipo_var mais_par
          | error
          ;
mais_par: ';'lista_par
        | error
        | %empty
        ;
corpo_p: dc_loc BEGIN_ comandos END';'
        | error
        ;
dc_loc: dc_v
        ;
lista_arg: '('argumentos')'
          | error
          | %empty
          ;
argumentos: IDENT mais_ident
          | error
          ;
mais_ident: ';'argumentos
          | error
          | %empty
          ;
pfalsa: ELSE cmd
      | %empty %prec LOWER_THAN_ELSE
      ;
comandos: cmd ';' comandos
        | error
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
    | error
    ;
condicao: expressao relacao expressao
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
              | %empty
              ;
op_ad: '+'
      | '-'
      ;
termo: op_un fator mais_fatores
      ;
mais_fatores: op_mul fator mais_fatores
            | error
            | %empty
            ;
op_mul: '*'
      | '/'
      | error
      ;
fator: IDENT
      | numero
      | '('expressao')'
      ;
numero: NUMERO_INTEIRO
      | NUMERO_REAL
      | error
      ;
%%
// funcao que exibe as mensagens de erro
void yyerror(const char *str){
  std::string aux = std::string(str);

  //substituindo $end por uma mensagem mais significativa
  int index = aux.find("$end");
  if(index != std::string::npos)
    aux.replace(index,4,"EOF");

  //substituindo BEGIN_ por uma mensagem mais significativa
  index = aux.find("BEGIN_");
  if(index != std::string::npos)
    aux.replace(index,6,"BEGIN");

  //atualizando o numero de erros
  errors_found++;

  //imprimindo mensagem de erro
  fprintf(stderr,"Error in line %d: %s\n",line,aux.c_str());
}
