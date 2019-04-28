%{
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include "table.cpp"

//arquivo com as palavras reservadas e simbolos especiais
#define WORDFILE "words.txt"

//possiveis valores de retorno do analisador lexico
enum{
	FIM_DO_ARQUIVO,
	NUMERO_INTEIRO,
	NUMERO_REAL,
	IDENTIFICADOR,
	PALAVRA_RESERVADA,
	CARACTER_ESPECIAL,
	CARACTER_INVALIDO,
	IDENTIFICADOR_MAL_FORMADO,
	NUMERO_MAL_FORMADO,
	COMENTARIO_MAL_FORMATADO
};

//variaveis globais para retorno de informacoes dos padroes encontrados
char *tolken;//na variavel tolken e retornado o tolken
string label;//na variavel label e retornado o simbolo definifo para cada caracter especial e palavra reservada, identificados por meio do uso da tabela

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
numero_inteiro [+-]?{digito}+
numero_real [+-]?{digito}+"."{digito}+
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
{numero_inteiro} { 	//se houver arquivo de texto para escrever eh feita a escrtia tambem no arquivo
										if(yyout != stdout)
											fprintf(yyout,"%s - Numero_Inteiro\n",yytext);
										tolken = copyString(yytext,yyleng);
										return NUMERO_INTEIRO;
									}
{numero_real} { //se houver arquivo de texto para escrever eh feita a escrtia tambem no arquivo
								if(yyout != stdout)
									fprintf(yyout,"%s - Numero_Real\n",yytext);
								tolken = copyString(yytext,yyleng);
								return NUMERO_REAL;
							}
{ident} {
					//verificando se eh uma palavra reservada ou um identificador
					string str = inTable(string(yytext),t);
					tolken = copyString(yytext,yyleng);
					//se nao estiver na tabela eh um identificador
					if(str.size() == 0){
						//se houver arquivo de texto para escrever eh feita a escrtia tambem no arquivo
						if(yyout != stdout)
							fprintf(yyout,"%s - Identificador\n",yytext);
						return IDENTIFICADOR;
					}else{
						//se houver arquivo de texto para escrever eh feita a escrtia tambem no arquivo
						if(yyout != stdout)
							fprintf(yyout,"%s - %s\n",yytext,str.c_str());
						label = str;
						return PALAVRA_RESERVADA;
					}
				}
{comentario}	//cosumindo comentarios
{quebra_de_linha}	//cosumindo quebras de linha
{espaco}	//consumindo espacos em branco
{caracter_invalido} {
											//verificando se eh um simbolo especial ou caracter invalido
											string str = inTable(string(yytext),t);
											tolken = copyString(yytext,yyleng);
											//se o caracter nao estiver na tabela eh um caracter invalido
											if(str.size() == 0){
												//se houver arquivo de texto para escrever eh feita a escrtia tambem no arquivo
												if(yyout != stdout)
													fprintf(yyout,"%s - Erro: Caracter Invalido\n",yytext);
												return CARACTER_INVALIDO;
											}else{
												//se houver arquivo de texto para escrever eh feita a escrtia tambem no arquivo
												if(yyout != stdout)
													fprintf(yyout,"%s - %s\n",yytext,str.c_str());
												label = str;
												return CARACTER_ESPECIAL;
											}
										}
{ident_mal_formado} {
											//verificando se eh identificador mal formado ou identificador/palavra reservada seguida de caracter especial
											string str = inTable(string(&yytext[yyleng-1]),t);
											//se o ultimo caracter do padrao encontrado nao estiver na tabela eh um identificador mal formado
	 										if(str.size() == 0){
												tolken = copyString(yytext,yyleng);
												//se houver arquivo de texto para escrever eh feita a escrtia tambem no arquivo
												if(yyout != stdout)
													fprintf(yyout,"%s - Erro: Identificador Mal Formado\n",yytext);
												return IDENTIFICADOR_MAL_FORMADO;
											}else{
												char aux = yytext[yyleng-1];
												//retornando caracter especial para proxima verificacao
												yyless(yyleng-1);
												string word = inTable(string(yytext),t);
												//verificando se eh identificador ou palavra reservada
												tolken = copyString(yytext,yyleng);
												//se nao estiver na tabela eh um identificador
												if(word.size() == 0){
													//se houver arquivo de texto para escrever eh feita a escrtia tambem no arquivo
													if(yyout != stdout)
														fprintf(yyout,"%s - Identificador\n",yytext);
													return IDENTIFICADOR;
												}else{
													//se houver arquivo de texto para escrever eh feita a escrtia tambem no arquivo
													if(yyout != stdout)
														fprintf(yyout,"%s - %s\n",yytext,word.c_str());
													label = word;
													return PALAVRA_RESERVADA;
												}
											}
										}
{comentario_mal_formatado} { //se houver arquivo de texto para escrever eh feita a escrtia tambem no arquivo
														 if(yyout != stdout)
														   fprintf(yyout,"%s - Erro: Comentario Mal Formatado\n",yytext);
														 tolken = copyString(yytext,yyleng);
														 return COMENTARIO_MAL_FORMATADO;
														}
{numero_inteiro_mal_formado} {
															//verificando se eh numero mal formado ou numero seguido de caracter especial
															string str = inTable(string(&yytext[yyleng-1]),t);
															if(str.size() == 0){
																//se houver arquivo de texto para escrever eh feita a escrtia tambem no arquivo
																if(yyout != stdout)
																	fprintf(yyout,"%s - Erro: Numero Mal Formado\n",yytext);
																tolken = copyString(yytext,yyleng);
																return NUMERO_MAL_FORMADO;
															}else{
																//retornando caracter especial para proxima verificacao
																yyless(yyleng-1);
																//se houver arquivo de texto para escrever eh feita a escrtia tambem no arquivo
																if(yyout != stdout)
																	fprintf(yyout,"%s - Numero_Inteiro\n",yytext);
																tolken = copyString(yytext,yyleng);
																return NUMERO_INTEIRO;
															}
										 				 }
{numero_real_mal_formado} {
													 //verificando se eh numero mal formado ou numero seguido de caracter especial
													 string str = inTable(string(&yytext[yyleng-1]),t);
													 if(str.size() == 0){
														 //se houver arquivo de texto para escrever eh feita a escrtia tambem no arquivo
														 if(yyout != stdout)
															 fprintf(yyout,"%s - Erro: Numero Mal Formado\n",yytext);
														 tolken = copyString(yytext,yyleng);
														 return NUMERO_MAL_FORMADO;
													 }else{
														 //retornando caracter especial para proxima verificacao
														 yyless(yyleng-1);
														 //se houver arquivo de texto para escrever eh feita a escrtia tambem no arquivo
														 if(yyout != stdout)
															 fprintf(yyout,"%s - Numero_Real\n",yytext);
														 tolken = copyString(yytext,yyleng);
														 return NUMERO_REAL;
													 }
												 	}
%%
int main(int argc, char *argv[]){
	//iniciando tabela
	initTable(&t);
	//preenchendo tabela
	fillTable(&t,string(WORDFILE));
	//valor de retorno do analisador lexico
	int ret;
	//se houver foi passado um arquivo como parametro do programa o analisador lexico tambem escreverah no arquivo
	if(argc == 2){
		yyout = fopen(argv[1],"w+");
	}
	do{
		//realizando analise lexica
		ret = yylex();
		//imprimindo na tela o tolken encontrado e sua classificacao
		switch(ret){
			case IDENTIFICADOR:
				printf("%s - Identificador\n", tolken);
				free(tolken);
			break;
			case PALAVRA_RESERVADA:
				printf("%s - %s\n", tolken, label.c_str());
				free(tolken);
			break;
			case CARACTER_ESPECIAL:
				printf("%s - %s\n", tolken, label.c_str());
				free(tolken);
			break;
			case CARACTER_INVALIDO:
				printf("%s - Erro: Caracter Invalido\n", tolken);
				free(tolken);
			break;
			case IDENTIFICADOR_MAL_FORMADO:
				printf("%s - Erro: Identificador Mal Formado\n",tolken);
				free(tolken);
			break;
			case NUMERO_MAL_FORMADO:
				printf("%s - Erro: Numero Mal Formado\n",tolken);
				free(tolken);
			break;
			case COMENTARIO_MAL_FORMATADO:
				printf("%s - Erro: Comentario Mal Formatado\n",tolken);
				free(tolken);
			break;
			case NUMERO_INTEIRO:
				printf("%s - Numero_Inteiro\n", tolken);
				free(tolken);
			break;
			case NUMERO_REAL:
				printf("%s - Numero_Real\n", tolken);
				free(tolken);
			break;
		}
		//enquanto o arquivo nao acabar, o analisador sera chamado novamente para obter-se o proximo tolken
	}while(ret != FIM_DO_ARQUIVO);
	//se foi passado um arquivo por linha de comando, ele deve ser fechado
	if(argc == 2)
		fclose(yyout);
	return 0;
}
