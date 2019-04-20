%{
#include <stdio.h>
%}

digito [0-9]
letra [a-zA-Z]
palavra {letra}+
ident {letra}({letra}|{digito})*
numero_inteiro [+-]?{digito}+
numero_real [+-]?{digito}+"."{digito}+
comentario "{".*"}"
quebra_de_linha \n
espaco " "
erros ([^a-zA-Z\n 0-9]+|"{".*|.*"}")
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
{erros} { /*if(NOT_IN_HASH)*/
						fprintf(yyout,"Erro - %s\n",yytext);
					/*else
						fprintf(yyout,"%s - %s\n",yytext,LABEL_IN_HASH_FOR_FOUND_WORLD_OR_CHARACTER);*/
				}
%%
int main(){
	yylex();
	return 0;
}
