%{
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include "table.cpp"
#include "y.tab.h"

void yyerror(const char*);

//arquivo com as palavras reservadas e simbolos especiais
#define WORDFILE "codes.txt"

int line = 1;
int errors_found = 0;

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
{numero_inteiro} {
										yylval.inteiro = atoi(yytext);
										return NUMERO_INTEIRO;
									}
{numero_real} {
								yylval.real = atof(yytext);
								return NUMERO_REAL;
							}
{ident} {
					string str = inTable(string(yytext),t);
					yylval.str = copyString(yytext,yyleng);
					if(str.size() == 0){
						return IDENT;
					}else{
						return atoi(str.c_str());
					}
				}
{comentario}	//cosumindo comentarios
{quebra_de_linha}	{line++;}
{espaco}	//consumindo espacos em branco
{caracter_invalido} {
											string str = inTable(string(yytext),t);
											if(str.size() == 0){
												yyerror((string("lexical error, invalid character '")+string(yytext)+"'").c_str());
												return CARACTER_INVALIDO;
											}else{
												return str.c_str()[0];
											}
										}
{ident_mal_formado} {
											string str = inTable(string(&yytext[yyleng-1]),t);
	 										if(str.size() == 0){
												yyerror(string("lexical error, ill formed identifier '"+string(yytext)+"'").c_str());
												return IDENT;
											}else{
												char aux = yytext[yyleng-1];
												yyless(yyleng-1);
												string word = inTable(string(yytext),t);
												if(word.size() == 0){
													yylval.str = copyString(yytext,yyleng);
													return IDENT;
												}else{
													return atoi(word.c_str());
												}
											}
										}
{comentario_mal_formatado} {
															yyerror(string("lexical error, ill formed comment '"+string(yytext)+"'").c_str());
														 /* return COMENTARIO_MAL_FORMATADO; */
														}
{numero_inteiro_mal_formado} {
															string str = inTable(string(&yytext[yyleng-1]),t);
															if(str.size() == 0){
																yyerror(string("lexical error, ill formed number '"+string(yytext)+"'").c_str());
																return NUMERO_INTEIRO;
															}else{
																yyless(yyleng-1);
																yylval.inteiro = atoi(str.c_str());
																return NUMERO_INTEIRO;
															}
										 				 }
{numero_real_mal_formado} {
													 string str = inTable(string(&yytext[yyleng-1]),t);
													 if(str.size() == 0){
														 yyerror(string("lexical error, ill formed number '"+string(yytext)+"'").c_str());
														 /* return NUMERO_MAL_FORMADO; */
													 }else{
														 yyless(yyleng-1);
														 yylval.real = atof(yytext);
														 return NUMERO_REAL;
													 }
												 	}
%%
int main(){
	#ifdef YYDEBUG
	yydebug = 0;
	#endif

	//iniciando tabela
	initTable(&t);
	//preenchendo tabela
	fillTable(&t,string(WORDFILE));
	line = 1;
	errors_found = 0;
	int success = yyparse();
	switch(success){
		case 0:
			printf("No errors found;\n");
		break;
		case 1:
			printf("\n%d error found;\n", errors_found);
		break;
	}
	return 0;
}

int yywrap(){
  return 1;
}
