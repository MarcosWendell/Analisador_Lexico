all: yacc lex
	g++ lex.yy.c y.tab.c -ly -o trab2.out
	rm *.yy.c *.tab.*
yacc:
	yacc -d trab2.y -t
lex:
	lex trab2.l
run:
	./trab2.out <teste1
clean:
	rm trab2.out
