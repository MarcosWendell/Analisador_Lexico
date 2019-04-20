%{
#include <stdio.h>
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
{ident} {	/*if(NOT_IN_HASH)*/
						fprintf(yyout,"%s - Identificador\n",yytext);
					/*else
						fprintf(yyout,"%s - %s\n",yytext,LABEL_IN_HASH_FOR_FOUND_WORLD_OR_CHARACTER);*/
				}
{comentario}
{quebra_de_linha}
{espaco}
{caracter_invalido} { /*if(NOT_IN_HASH)*/
												fprintf(yyout,"Erro: Caracter Invalido - %s\n",yytext);
											/*else
												fprintf(yyout,"%s - %s\n",yytext,LABEL_IN_HASH_FOR_FOUND_WORLD_OR_CHARACTER);*/
										}
{ident_mal_formado} { /*if(yytext[yyleng-1] NOT_IN_HASH)*/
												fprintf(yyout,"Erro: Identificador Mal Formado - %s\n",yytext);
											/*else{
												char aux = yytext[yyleng-1];
												yytext[yyleng-1] = '\0';
												if(yytext NOT_IN_HASH)
													fprintf(yyout,"%s - Identificador\n",yytext);
												else
													fprintf(yyout,"%s - %s\n",yytext,LABEL_IN_HASH_FOR_FOUND_WORLD_OR_CHARACTER);
												fprintf(yyout,"%c - %s\n",aux,LABEL_IN_HASH_FOR_FOUND_WORLD_OR_CHARACTER);
											}*/
										}
{comentario_mal_formatado} { fprintf(yyout,"Erro: Comentario Mal Formatado - %s\n",yytext); }
{numero_inteiro_mal_formado} {/*if(yytext[yyleng-1] NOT_IN_HASH)*/
																fprintf(yyout,"Erro: Numero Mal Formado - %s\n",yytext);
															/*else{
																char aux = yytext[yyleng-1];
																yytext[yyleng-1] = '\0';
																fprintf(yyout,"%s - Numero_Inteiro\n",yytext);
																fprintf(yyout,"%c - %s\n",aux,LABEL_IN_HASH_FOR_FOUND_WORLD_OR_CHARACTER);
															}*/
										 				 }
{numero_real_mal_formado} {/*if(yytext[yyleng-1] NOT_IN_HASH)*/
														 fprintf(yyout,"Erro: Numero Mal Formado - %s\n",yytext);
													 /*else{
														 char aux = yytext[yyleng-1];
														 yytext[yyleng-1] = '\0';
														 fprintf(yyout,"%s - Numero_Real\n",yytext);
														 fprintf(yyout,"%c - %s\n",aux,LABEL_IN_HASH_FOR_FOUND_WORLD_OR_CHARACTER);
													 }*/
												 	}
%%
int main(){
	yylex();
	return 0;
}
