#include<string>
#include<vector>
#include<cstdio>
using namespace std;
#define M 98

//tupla palavra resevada e simbolo da palavra reservada
typedef struct{
  string word, label;
} tupla;

typedef vector<tupla> table;

//inicializacao da tabela
void initTable(table *t){
  tupla aux;
  aux.word = string();
  aux.label = string();
  *t = table(M,aux);
}

//funcao hash para alocacao na tabela
int hashFunction(string & s) {
    int ans = 0;
    for(char c : s) {
        ans = (ans * 151)%M;
        ans = (ans + c - '(' + 1)%M;
    }
    return ans;
}

//funcao que preenche a tabela a partir de um arquivo
void fillTable(table *t, string filename){
  FILE* file = fopen(filename.c_str(),"r+");
  do{
    char* aux;
    tupla n;
    fscanf(file,"%ms",&aux);
    n.word = string(aux);
    free(aux);
    fscanf(file,"%ms\n",&aux);
    n.label = string(aux);
    free(aux);
    (*t)[hashFunction(n.word)] = n;
  }while(!feof(file));
  fclose(file);
}

//funcao que verifica se a string procurada estah na tabela
string inTable(string s,table t){
  int pos = hashFunction(s);
  if(t[pos].word == s)
    return t[pos].label;
  else
    return string();
}
