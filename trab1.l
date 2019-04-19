%{
#include <stdio.h>
%}

digito [0-9]
letra [a-zA-Z]
palavra {letra}+
%%
ECHO;
%%
int main(){
	yylex();
	return 0;
}
