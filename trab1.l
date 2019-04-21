%{
#include <stdio.h>
#include "hash.cpp"

#define WORDFILE "words.txt"

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
					string str = inHash(string(yytext),t);
					if(str.size() == 0)
						fprintf(yyout,"%s - Identificador\n",yytext);
					else
						fprintf(yyout,"%s - %s\n",yytext,str.c_str());
				}
{comentario}
{quebra_de_linha}
{espaco}
{caracter_invalido} {
											string str = inHash(string(yytext),t);
											if(str.size() == 0)
												fprintf(yyout,"Erro: Caracter Invalido - %s\n",yytext);
											else
												fprintf(yyout,"%s - %s\n",yytext,str.c_str());
										}
{ident_mal_formado} {
											string str = inHash(string(&yytext[yyleng-1]),t);
	 										if(str.size() == 0)
												fprintf(yyout,"Erro: Identificador Mal Formado - %s\n",yytext);
											else{
												char aux = yytext[yyleng-1];
												yytext[yyleng-1] = '\0';
												string word = inHash(string(yytext),t);
												if(word.size() == 0)
													fprintf(yyout,"%s - Identificador\n",yytext);
												else
													fprintf(yyout,"%s - %s\n",yytext,word.c_str());
												fprintf(yyout,"%c - %s\n",aux,str.c_str());
											}
										}
{comentario_mal_formatado} { fprintf(yyout,"Erro: Comentario Mal Formatado - %s\n",yytext); }
{numero_inteiro_mal_formado} {
															string str = inHash(string(&yytext[yyleng-1]),t);
															if(str.size() == 0)
																fprintf(yyout,"Erro: Numero Mal Formado - %s\n",yytext);
															else{
																char aux = yytext[yyleng-1];
																yytext[yyleng-1] = '\0';
																fprintf(yyout,"%s - Numero_Inteiro\n",yytext);
																fprintf(yyout,"%c - %s\n",aux,str.c_str());
															}
										 				 }
{numero_real_mal_formado} {
													 string str = inHash(string(&yytext[yyleng-1]),t);
													 if(str.size() == 0)
														 fprintf(yyout,"Erro: Numero Mal Formado - %s\n",yytext);
													 else{
														 char aux = yytext[yyleng-1];
														 yytext[yyleng-1] = '\0';
														 fprintf(yyout,"%s - Numero_Real\n",yytext);
														 fprintf(yyout,"%c - %s\n",aux,str.c_str());
													 }
												 	}
%%
int main(){
	initHash(&t);
	fillTable(&t,string(WORDFILE));
	yylex();
	return 0;
}
