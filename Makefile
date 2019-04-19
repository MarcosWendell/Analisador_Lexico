all:
	lex trab1.l
	gcc lex.yy.c -ll -o trab1.out
