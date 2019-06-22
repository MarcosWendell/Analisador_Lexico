all: gcc
	rm *.yy.c *.tab.*
yacc:
	yacc -d trab2.y -t
lex:
	lex trab2.l
gcc: yacc lex
	g++ lex.yy.c y.tab.c -ly -o trab2.out
run:
	if test -f trab2.out; then ./trab2.out < teste1; fi
state-machine:
	yacc -v trab2.y
clean:
	if test -f trab2.out; then rm trab2.out; fi
	if test -f y.output; then rm y.output; fi
	clear
