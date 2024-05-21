// Tabela de simbolos

/*
 | -------------------------------------------------------------------------------------------
 |                            Unifal - Universidade Federal de Alfenas.
 |                             Bacharelado em Ciência da Computação.  
 |
 | Trabalho..: Registro e verificação de tipos
 | Disciplina..: Teoria de Linguagens e Compiladores
 | Professor...: Luiz Eduardo da Silva
 | Aluno(s).. : Paulo César Moraes de Menezes e Rafael Silva Fortuna
 | Data.......: 15/12/2023
 | ------------------------------------------------------------------------------------------- */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum // Tipos de dados
{
    INT, // 0
    LOG, // 1
    REG  // 2
};

#define TAM_TAB 100
#define TAM_PIL 100

char msg [200]; // Mensagem de erro

char nomeTipo[3][4] = {"INT", "LOG", "REG"}; // Nomes dos tipos de dados

typedef struct no *ptno; // Ponteiro para nó
struct no { // Nó da lista encadeada
    char * nome; // Nome do campo
    int tip; // Tipo do campo
    int pos; // Posição do campo
    int des; // Deslocamento do campo
    int tam; // Tamanho do campo
    ptno prox; // Próximo campo
};

struct elemTabSimbolos {
    char id[100]; // Identificador
    int end; // Endereço
    int tip; // Tipo
    int tam; // Tamanho
    int pos; // Posição
    ptno campos; // Lista de campos
} tabSimb[TAM_TAB], elemTab; // Tabela de símbolos e elemento da tabela

int posTab = 0; // Posição da tabela de símbolos

// Função para inserir um campo na lista de campos
ptno insereCampo(ptno cabeca, char * nome, int tipo, int posicao, int deslocamento, int tamanho){
    ptno p, novo_campo; // Ponteiro para nó e novo campo
    novo_campo = (ptno) malloc(sizeof(struct no)); // Aloca memória para o novo campo
    novo_campo->nome = strdup(nome); // Copia o nome do campo para o novo campo
    novo_campo->tip = tipo; // Copia o tipo do campo para o novo campo
    novo_campo->pos = posicao; // Copia a posição do campo para o novo campo
    novo_campo->des = deslocamento; // Copia o deslocamento do campo para o novo campo
    novo_campo->tam = tamanho; // Copia o tamanho do campo para o novo campo
    novo_campo->prox = NULL; // O próximo campo é nulo

    p = cabeca; // Ponteiro para nó recebe a cabeça da lista
    while (p && p->prox){ // Enquanto o ponteiro para nó e o próximo campo forem diferentes de nulo
        p = p->prox; // Ponteiro para nó recebe o próximo campo
    }

    if (p) // Se o ponteiro para nó for diferente de nulo
        p->prox = novo_campo; // O próximo campo recebe o novo campo
    else // Senão
        cabeca = novo_campo; // A cabeça da lista recebe o novo campo

    return cabeca;  // Retorna a cabeça da lista
}

// Função para busca de um campo na lista de campos
ptno buscaCampo(ptno cabeca, char *nome){
    ptno p; // Ponteiro para nó
    p = cabeca; // Ponteiro para nó recebe a cabeça da lista
    while (p && strcmp(p->nome, nome) != 0){ // Enquanto o ponteiro para nó e o nome do campo forem diferentes de nulo
        if (p->prox == NULL) // Se o próximo campo for nulo
            break; // Interrompe o laço
        p = p->prox; // Ponteiro para nó recebe o próximo campo
    }
    if (!p){ // Se o ponteiro para nó for nulo
        char msg[200]; // Mensagem de erro
        sprintf(msg, "Campo [%s] não encontrado! ", nome);
        fprintf(stderr, "%s\n", msg);
    }

    return p; // Retorna o ponteiro para nó
}

// Função para calcular o deslocamento 
int procuraDeslocamento (int deslocamento){
    // Percorre a tabela de símbolos
    int i;
    for (i = 0; i < posTab; i++){
        if (tabSimb[i].end == deslocamento)
        // Se o endereço for igual ao deslocamento
            return i; // Retorna o índice
    }
    return -1; // Senão, retorna -1
}

int procuraPosicao (int posicao){ // Função para calcular a posição
    int i; // Índice
    for (i = 0; i < posTab; i++){ // Percorre a tabela de símbolos
        if (tabSimb[i].pos == posicao) // Se a posição for igual a posição
            return i; // Retorna o índice
    }
    return -1; // Senão, retorna -1
}


// Função para exibir os campos bonitinhos na tabela de símbolos
void exibeCampos(ptno lista) {
    ptno p = lista; // Ponteiro para nó recebe a lista
    if (p != NULL) { // Se o ponteiro para nó for diferente de nulo
        printf(" (%s,%s,%d,%d,%d)", p->nome, nomeTipo[p->tip], p->pos, p->des, p->tam);
        p = p->prox; // Ponteiro para nó recebe o próximo campo
    }
    while (p != NULL) { // Enquanto o ponteiro para nó for diferente de nulo
        printf(" => (%s,%s,%d,%d,%d)", p->nome, nomeTipo[p->tip], p->pos, p->des, p->tam);
        p = p->prox; // Ponteiro para nó recebe o próximo campo
    }
}

// Função para buscar um símbolo na tabela de símbolos
int buscaSimbolo (char *s) {
    int i; // Índice
    // Percorre a tabela de símbolos
    for(i = posTab - 1; strcmp(tabSimb[i].id, s) && i >= 0; i--);
    if ( i == -1) {
        char msg[200];
        sprintf(msg, "O campo [%s] não existe na estrutura", s);
        yyerror (msg);
    }
    return i; 
}

// Função para inserir um símbolo na tabela de símbolos
void insereSimbolo (struct elemTabSimbolos elem) {
    int i; // Índice
    if(posTab == TAM_TAB) // Se a posição da tabela de símbolos for igual ao tamanho da tabela de símbolos
        yyerror ("Tabela de Simbolos cheia!");
    // Percorre a tabela de símbolos
    for(i = posTab - 1; strcmp(tabSimb[i].id, elem.id) && i >= 0; i--);
    if(i != -1){
        char msg[200];
        sprintf(msg, "Identificador [%s] duplicado", elem.id);
        yyerror (msg);
    }
    // Insere o elemento na tabela de símbolos
    tabSimb[posTab++] = elem;
}

// FUnção para mostrar a tabelinha bonitinha
void mostraTabela (){
    printf("------------------------------------- Tabela de Simbolos -------------------------------------------------\n");
    printf("\n");
    printf("%30s | %s | %s | %s | %s | %s |\n","ID", "END", "TIPO", "TAM", "POS", "CAMPOS");
    for (int i = 0; i < 50; i++)
        printf("--");
    for (int i = 0; i < posTab; i++){
        if(tabSimb[i].tip  == REG){ // Se o tipo for REG
        printf("\n%30s | %3d |  %3s | %3d | %3d |",
            tabSimb[i].id,
            tabSimb[i].end,
            nomeTipo[tabSimb[i].tip],
            tabSimb[i].tam,
            tabSimb[i].pos);
        exibeCampos(tabSimb[i].campos); 
        }
        else{ // Senão
        printf("\n%30s | %3d |  %3s | %3d | %3d |",
            tabSimb[i].id,
            tabSimb[i].end,
            nomeTipo[tabSimb[i].tip],
            tabSimb[i].tam, 
            tabSimb[i].pos);
        }
    }
    puts(" ");
}

int pilha[TAM_PIL]; // Pilha semântica
int topo = -1; // Topo da pilha semântica

void empilha (int valor) { // Função para empilhar
    if(topo == TAM_PIL)
        yyerror("Pilha semantica cheia!");
    pilha[++topo] = valor;
}

int desempilha (void) { // Função para desempilhar
    if(topo == -1){
        yyerror("Pilha semantica vazia!");}
    return pilha[topo--];
}

// Função para testar o tipo
void testaTipo (int tipo1, int tipo2, int ret) { 
    int t1 = desempilha(); // Desempilha o tipo 1
    int t2 = desempilha(); // Desempilha o tipo 2
    if (t1 != tipo1 || t2 != tipo2)  // Se o tipo 1 for diferente do tipo 1 ou o tipo 2 for diferente do tipo 2
        yyerror("Incompatibilidade de tipo!");
    empilha(ret); // Empilha o retorno
}

// Lembrando que o funcionamento de uma pilha é:
// Empilha: 1, 2, 3, 4, 5
// Desempilha: 5, 4, 3, 2, 1
// O topo da pilha é o último elemento inserido, no caso, o 5

