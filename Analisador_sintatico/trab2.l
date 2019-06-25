%{
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include "table.cpp"
#include "y.tab.h"

void yyerror(const char*);

//arquivo com as palavras reservadas e simbolos especiais
#define WORDFILE "codes.txt"

//variaveis globais para contar a linha atual e o numero de erros encontrados
int line;
int errors_found;

//tabela com as palavras reservadas e simbolos especiais
table t;

//funcao que copia uma string para uma nova regiao da memoria
char *copyString(char *source,int length){
	int size = sizeof(char)*(length+1);
	char *str = (char *)malloc(size);
	memcpy(str,yytext,size);
	return str;
}

%}
/* padroes de auxilio na construcao de outro padores */
digito [0-9]
letra [a-zA-Z]
palavra {letra}+
/* padroes a serem identificados */
ident {letra}({letra}|{digito})*
numero_inteiro {digito}+
numero_real {digito}+"."{digito}+
comentario "{"[^\n\}]*"}"
quebra_de_linha \n
espaco " "
/* padroes de possiveis erros */
caracter_invalido [^a-zA-Z\n 0-9{}]
comentario_mal_formatado "{"[^\n}]*|[^\n{]*"}"
ident_mal_formado {ident}{caracter_invalido}
numero_inteiro_mal_formado {numero_inteiro}({caracter_invalido}|{letra})
numero_real_mal_formado {numero_real}({caracter_invalido}|{letra})
%%
{numero_inteiro} {	//retornando valor inteiro
										yylval.inteiro = atoi(yytext);
										return NUMERO_INTEIRO;
									}
{numero_real} { //retornando valor real
								yylval.real = atof(yytext);
								return NUMERO_REAL;
							}
{ident} {	//verificando se é identificador ou palavra reservada
					string str = inTable(string(yytext),t);
					yylval.str = copyString(yytext,yyleng);
					if(str.size() == 0){
						// retornando identificador
						return IDENT;
					}else{
						// retornando palavra reservada
						return atoi(str.c_str());
					}
				}
{comentario}	//cosumindo comentarios
{quebra_de_linha}	{line++;} // atualizando a linha atual
{espaco}	//consumindo espacos em branco
{caracter_invalido} { //verificando se eh um simbolo especial ou caracter invalido
											string str = inTable(string(yytext),t);
											if(str.size() == 0){
												//exibindo mensagem de erro
												yyerror((string("lexical error, invalid character '")+string(yytext)+"'").c_str());
												// retornando caracter invalido
												return CARACTER_INVALIDO;
											}else{
												//retornando carater especial
												return str.c_str()[0];
											}
										}
{ident_mal_formado} { //verificando se eh identificador mal formado ou identificador/palavra reservada seguida de caracter especial
											string str = inTable(string(&yytext[yyleng-1]),t);
	 										if(str.size() == 0){
												//exibindo mensagem de erro
												yyerror(string("lexical error, ill formed identifier '"+string(yytext)+"'").c_str());
												//retornando identificador
												return IDENT;
											}else{
												//verificando se eh identificador ou palavra reservada
												char aux = yytext[yyleng-1];
												yyless(yyleng-1);
												string word = inTable(string(yytext),t);
												if(word.size() == 0){
													//retornando identificador
													yylval.str = copyString(yytext,yyleng);
													return IDENT;
												}else{
													//retornando palavra reservada
													return atoi(word.c_str());
												}
											}
										}
{comentario_mal_formatado} {  //exibindo mensagem de erro
															yyerror(string("lexical error, ill formed comment '"+string(yytext)+"'").c_str());
														}
{numero_inteiro_mal_formado} {//verificando se eh numero mal formado ou numero seguido de caracter especial
															string str = inTable(string(&yytext[yyleng-1]),t);
															if(str.size() == 0){
																//exibindo mensagem de erro
																yyerror(string("lexical error, ill formed number '"+string(yytext)+"'").c_str());
																//retornando inteiro
																return NUMERO_INTEIRO;
															}else{
																yyless(yyleng-1);
																//retornando inteiro
																yylval.inteiro = atoi(str.c_str());
																return NUMERO_INTEIRO;
															}
										 				 }
{numero_real_mal_formado} {//verificando se eh numero mal formado ou numero seguido de caracter especial
													 string str = inTable(string(&yytext[yyleng-1]),t);
													 if(str.size() == 0){
														 //exibindo mensagem de erro
														 yyerror(string("lexical error, ill formed number '"+string(yytext)+"'").c_str());
														 //retornando real
														 return NUMERO_REAL;
													 }else{
														 //retornando real
														 yyless(yyleng-1);
														 yylval.real = atof(yytext);
														 return NUMERO_REAL;
													 }
												 	}
%%
//funcao main
int main(){
	//iniciando tabela
	initTable(&t);
	//preenchendo tabela
	fillTable(&t,string(WORDFILE));
	//inciando valores de variaveis auxiliares
	line = 1;
	errors_found = 0;
	//axecutando o analisador sintatico
	int success = yyparse();
	//verificando se houve erros
	switch(success){
		case 0:
			printf("\nNo errors found;\n");
		break;
		case 1:
			printf("\n%d error found;\n", errors_found);
		break;
	}
	return 0;
}

//funcao para sinalizar o fim do arquivo para a analise lexica
int yywrap(){
  return 1;
}
