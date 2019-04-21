#include<string>
#include<vector>
#include<cstdio>
using namespace std;
#define M 98

typedef struct{
  string word, label;
} node;

typedef vector<node> table;

void initHash(table *t){
  node aux;
  aux.word = string();
  aux.label = string();
  *t = table(M,aux);
}

int hashFunction(string & s) {
    int ans = 0;
    for(char c : s) {
        ans = (ans * 151)%M;
        ans = (ans + c - '(' + 1)%M;
    }
    return ans;
}

void fillTable(table *t, string filename){
  FILE* file = fopen(filename.c_str(),"r+");
  do{
    char* aux;
    node n;
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

string inHash(string s,table t){
  int pos = hashFunction(s);
  if(t[pos].word == s)
    return t[pos].label;
  else
    return string();
}
