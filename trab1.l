%{
#include <stdio.h>
#include "table.cpp"

//arquivo com as palavras reservadas e simbolos especiais
#define WORDFILE "words.txt"

//tabela com as palavras reservadas e simbolos especiais
table t;
%}

digito [0-9]
letra [a-zA-Z]
palavra {letra}+
ident {letra}({letra}|{digito})*
numero_inteiro [+-]?{digito}+
numero_real [+-]?{digito}+"."{digito}+
comentario "{"[^\n\}]*"}"
quebra_de_linha \n
espaco " "
caracter_invalido [^a-zA-Z\n 0-9{}]
comentario_mal_formatado "{"[^\n}]*|[^\n{]*"}"
ident_mal_formado {ident}{caracter_invalido}
numero_inteiro_mal_formado {numero_inteiro}({caracter_invalido}|{letra})
numero_real_mal_formado {numero_real}({caracter_invalido}|{letra})
%%
{numero_inteiro} { fprintf(yyout,"%s - Numero_Inteiro\n",yytext); }
{numero_real} { fprintf(yyout,"%s - Numero_Real\n",yytext); }
{ident} {
					//verificando se eh uma palavra reservada ou um identificador
					string str = inTable(string(yytext),t);
					if(str.size() == 0)
						fprintf(yyout,"%s - Identificador\n",yytext);
					else
						fprintf(yyout,"%s - %s\n",yytext,str.c_str());
				}
{comentario}	//cosumindo comentarios
{quebra_de_linha}	//cosumindo quebras de linha
{espaco}	//consumindo espacos em branco
{caracter_invalido} {
											//verificando se eh um simbolo especial ou carater invalido
											string str = inTable(string(yytext),t);
											if(str.size() == 0)
												fprintf(yyout,"%s - Erro: Caracter Invalido\n",yytext);
											else
												fprintf(yyout,"%s - %s\n",yytext,str.c_str());
										}
{ident_mal_formado} {
											//verificando se eh identificador mal formado ou identificador/palavra reservada seguida de carater especial
											string str = inTable(string(&yytext[yyleng-1]),t);
	 										if(str.size() == 0)
												fprintf(yyout,"%s - Erro: Identificador Mal Formado\n",yytext);
											else{
												char aux = yytext[yyleng-1];
												yytext[yyleng-1] = '\0';
												string word = inTable(string(yytext),t);
												//verificando se eh identificador ou palavra reservada
												if(word.size() == 0)
													fprintf(yyout,"%s - Identificador\n",yytext);
												else
													fprintf(yyout,"%s - %s\n",yytext,word.c_str());
												fprintf(yyout,"%c - %s\n",aux,str.c_str());
											}
										}
{comentario_mal_formatado} { fprintf(yyout,"%s - Erro: Comentario Mal Formatado\n",yytext); }
{numero_inteiro_mal_formado} {
															//verificando se eh numero mal formado ou numero seguido de carater especial
															string str = inTable(string(&yytext[yyleng-1]),t);
															if(str.size() == 0)
																fprintf(yyout,"%s - Erro: Numero Mal Formado\n",yytext);
															else{
																char aux = yytext[yyleng-1];
																yytext[yyleng-1] = '\0';
																fprintf(yyout,"%s - Numero_Inteiro\n",yytext);
																fprintf(yyout,"%c - %s\n",aux,str.c_str());
															}
										 				 }
{numero_real_mal_formado} {
													 //verificando se eh numero mal formado ou numero seguido de carater especial
													 string str = inTable(string(&yytext[yyleng-1]),t);
													 if(str.size() == 0)
														 fprintf(yyout,"%s - Erro: Numero Mal Formado\n",yytext);
													 else{
														 char aux = yytext[yyleng-1];
														 yytext[yyleng-1] = '\0';
														 fprintf(yyout,"%s - Numero_Real\n",yytext);
														 fprintf(yyout,"%c - %s\n",aux,str.c_str());
													 }
												 	}
%%
int main(){
	//iniciando tabela
	initTable(&t);
	//preenchendo tabela
	fillTable(&t,string(WORDFILE));
	//iniciando analise lexica
	yylex();
	return 0;
}
