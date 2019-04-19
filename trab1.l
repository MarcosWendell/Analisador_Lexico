%{
#include <stdio.h>
%}

digito [0-9]
letra [a-zA-Z]
palavra {letra}+
ident {letra}({letra} | {digito})*
numero_inteiro -?{dígito}+
numero_real -?{dígito}+.{digito}+
%%
ECHO;
%%
int main(){
	yylex();
	return 0;
}
