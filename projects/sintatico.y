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
 
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lexico.c"
#include "utils.c"

int aux1; // será usada pela função de busca posicao
int aux2; // será usada pela função de busca deslocamento

int contaVar = 0; // contador de variáveis

int rotulo = 0; // contador de rótulos
int ehRegistro = 0; // flag para indicar se é registro
int tipo; // tipo da variável
int tamanho; // tamanho da variável
int deslocamento = 0; // deslocamento da variável
int posicao; // posição da variável
int id; // id da variável
ptno campo = NULL; // campo da variável
%}

%token T_PROGRAMA
%token T_INICIO
%token T_FIM
%token T_IDENTIF
%token T_ENTRADA
%token T_SAIDA
%token T_ENQUANTO
%token T_FACA
%token T_FIMENQUANTO
%token T_SE
%token T_ENTAO
%token T_SENAO
%token T_FIMSE
%token T_ATRIB
%token T_VEZES
%token T_DIV
%token T_MAIS
%token T_MENOS
%token T_MAIOR
%token T_MENOR
%token T_IGUAL
%token T_ELOGICO
%token T_OULOGICO
%token T_V
%token T_F
%token T_NUMERO
%token T_NAO
%token T_ABRE
%token T_FECHA
%token T_LOGICO
%token T_INTEIRO
%token T_DEF
%token T_FIMDEF
%token T_REGISTRO
%token T_IDPONTO

%start programa

%left T_ELOGICO T_OU
%left T_IGUAL
%left T_MAIOR T_MENOR
%left T_MAIS T_MENOS
%left T_VEZES T_DIV

%%

programa 
   : cabecalho definicoes variaveis 
        { 
            empilha (contaVar); // empilha o número de variáveis
            if (contaVar) // se tiver variáveis, gera AMEM (Aloca memória)
            fprintf(yyout, "\tAMEM\t%d\n", contaVar); 
        }
     T_INICIO lista_comandos T_FIM
        { 
            int conta = desempilha(); // desempilha o número de variáveis
            if (conta) // se tiver variáveis, gera DMEM (Desaloca memória)
               fprintf(yyout, "\tDMEM\t%d\n", conta); 
        }
        { fprintf(yyout, "\tFIMP\n"); // gera FIMP (Fim do programa)
         mostraTabela(); // mostra a tabela de símbolos

        }
   ;

cabecalho
   : T_PROGRAMA T_IDENTIF
       {
            strcpy(elemTab.id, "Inteiro"); // insere o tipo inteiro na tabela de símbolos
            elemTab.end = -1; // endereço -1 indica que não é variável
            elemTab.tip = INT; // tipo inteiro
            elemTab.tam = 1; // tamanho 1
            elemTab.pos = 0; // posição 0
            insereSimbolo(elemTab); // insere o tipo inteiro na tabela de símbolos

            strcpy(elemTab.id, "Logico"); // insere o tipo lógico na tabela de símbolos
            elemTab.end = -1; // endereço -1 indica que não é variável
            elemTab.tip = LOG; // tipo lógico
            elemTab.tam = 1; // tamanho 1
            elemTab.pos = 1; // posição 1
            insereSimbolo(elemTab); // insere o tipo lógico na tabela de símbolos
            
            fprintf(yyout, "\tINPP\n"); // gera INPP (Início do programa)

       }
   ;

tipo
   : T_LOGICO
         { 
            tipo = LOG; 
            // TODO #1
            // Além do tipo, precisa guardar o TAM (tamanho) do
            // tipo e a POS (posição) do tipo na tab. símbolos
            tamanho = 1; // tamanho do tipo - Para lógico e inteiro é 1
            posicao = 1; // posição do tipo na tab. símbolos
         }
   | T_INTEIRO
         { ;
            tipo = INT;
            // idem 
            tamanho = 1; // tamanho do tipo - Para lógico e inteiro é 1
            posicao = 0; // posição do tipo na tab. símbolos
        }
   | T_REGISTRO T_IDENTIF
         { 
            tipo = REG; 
            // TODO #2
            // Aqui tem uma chamada de buscaSimbolo para encontrar
            // as informações de TAM e POS do registro
            posicao = buscaSimbolo(atomo); // posição do tipo na tab. símbolos
            tamanho = tabSimb[posicao].tam; // tamanho do tipo
            elemTab.campos =  tabSimb[posicao].campos; // lista de campos do tipo
            campo = NULL; // inicializa a lista de campos
         }
   ;

definicoes
   : define definicoes
   | /* vazio */
   ;

define 
   : T_DEF
        {
            // TODO #3
            // Iniciar a lista de campos
            campo = NULL; // inicializa a lista de campos
            elemTab.campos = campo; // inicializa a lista de campos

        } 
   definicao_campos T_FIMDEF T_IDENTIF
   {
       // TODO #4
       // Inserir esse novo tipo na tabela de simbolos
       // com a lista que foi montada

      strcpy(elemTab.id, atomo); // insere o tipo na tabela de símbolos
      elemTab.end = -1; // endereço -1 indica que não é variável
      elemTab.tip = REG; // tipo registro
      elemTab.tam = tabSimb[posicao].tam; // tamanho do tipo
      elemTab.tam += campo->tam; // tamanho do tipo + tamanho da lista de campos
      elemTab.pos++; // posição do tipo na tab. símbolos
      elemTab.campos = campo; // lista de campos do tipo
      insereSimbolo(elemTab); // insere o tipo na tabela de símbolos
   }
;

definicao_campos
   : tipo lista_campos definicao_campos
   {
      deslocamento = 0; // deslocamento inicial
   }
   | tipo lista_campos
   {
      deslocamento = 0; // deslocamento inicial
   }
   ;

lista_campos
   : lista_campos T_IDENTIF
      {
         // TODO #5
         // acrescentar esse campo na lista de campos que
         // esta sendo construida
         // o deslocamento (endereço) do próximo campo
         // será o deslocamento anterior mais o tamanho desse campo

         campo = insereCampo(campo, atomo, tipo, posicao, deslocamento, tamanho);
         // Campo é o ponteiro para a lista de campos; Está sendo 
         // Inserido o atomo (nome do campo), o tipo, a posição, 
         // o deslocamento e o tamanho

         deslocamento = deslocamento + tamanho; 
         // deslocamento do próximo campo
      }
   | T_IDENTIF
      {
         // idem
         campo = insereCampo(campo, atomo, tipo, posicao, deslocamento, tamanho);
         deslocamento = deslocamento + tamanho;
      }
   ;
variaveis
   : /* vazio */
   | declaracao_variaveis
   ;

declaracao_variaveis
   : tipo lista_variaveis declaracao_variaveis
   | tipo lista_variaveis
   ;

lista_variaveis
   : lista_variaveis
     T_IDENTIF 
        { 
            strcpy(elemTab.id, atomo); // insere o identificador na tabela de símbolos
            elemTab.end = contaVar; // endereço da variável
            elemTab.tip = tipo; // tipo da variável
            // TODO #6
            // Tem outros campos para acrescentar na tab. símbolos
            elemTab.tam = tamanho; // tamanho da variável
            elemTab.pos = posicao;  // posição da variável
            insereSimbolo (elemTab); // insere o identificador na tabela de símbolos
            // TODO #7
            // Se a variavel for registro
            // contaVar = contaVar + TAM (tamanho do registro)
             if (elemTab.tip == REG) // se for registro
               contaVar += contaVar + tamanho; // contaVar = contaVar + TAM (tamanho do registro)
            else // se não for registro
               contaVar++;  // contaVar = contaVar + 1
            
        }
   | T_IDENTIF
       { 
            strcpy(elemTab.id, atomo); // insere o identificador na tabela de símbolos
            elemTab.end = contaVar; // endereço da variável
            elemTab.tip = tipo; // tipo da variável
            // idem
            elemTab.tam = tamanho; // tamanho da variável
            elemTab.pos = posicao; // posição da variável
            insereSimbolo (elemTab); // insere o identificador na tabela de símbolos
            // bidem 
            if (elemTab.tip ==  REG) // se for registro
               contaVar = contaVar + tamanho; // contaVar = contaVar + TAM (tamanho do registro)
            else // se não for registro
            contaVar++; // contaVar = contaVar + 1
            
       }
   ;

lista_comandos
   : /* vazio */
   | comando lista_comandos
   ;

comando
   : entrada_saida
   | atribuicao
   | selecao
   | repeticao
   ;

entrada_saida
   : entrada
   | saida 
   ;

entrada
   : T_ENTRADA expressao_acesso
       { 
          // TODO #8
          // Se for registro, tem que fazer uma repetição do
          // TAM do registro de leituras
          if (elemTab.tip == REG){
            fprintf(yyout, "\tLEIT\n"); // gera LEIT (Leitura)
            fprintf(yyout, "\tARGZ\t%d\n", deslocamento); // gera ARGZ (Argumento de endereço)
            for (int i = 1; i < tamanho; i++) // TAM do registro de leituras
            { 
               fprintf(yyout, "\tLEIT\n"); // gera LEIT (Leitura)
               fprintf(yyout, "\tDSVS\t%d\n", deslocamento + i); // gera DSVS (Desvio para subrotina)
            }
          }
          else{
            fprintf(yyout, "\tLEIT\n"); // gera LEIT (Leitura)
            fprintf(yyout, "\tARZG\t%d\n", deslocamento); // gera ARZG (Argumento de endereço)
          
          }
       }
   ;

saida
   : T_SAIDA expressao
       {  
          desempilha(); // desempilha o tipo
          // TODO #9
          // Se for registro, tem que fazer uma repetição do
          // TAM do registro de escritas
          id = buscaSimbolo(atomo); // busca o símbolo na tabela de símbolos
          if (ehRegistro == 1){ // se for registro
            fprintf(yyout, "\tESCR\n"); // gera ESCR (Escrita)
            fprintf(yyout, "\tARZG\t%d\n", deslocamento); // gera ARZG (Argumento de endereço)
            for (int i = 1; i < tamanho; i++) // TAM do registro de escritas
            {
               fprintf(yyout, "\tESCR\n"); // gera ESCR (Escrita)
               fprintf(yyout, "\tDSVS\t%d\n", deslocamento + i); // gera DSVS (Desvio para subrotina)
            }
          }
          else{
            fprintf(yyout, "\tESCR\n"); // gera ESCR (Escrita)
            fprintf(yyout, "\tARZG\t%d\n", deslocamento); // gera ARZG (Argumento de endereço)
          }

          fprintf(yyout, "\tESCR\n");  // gera ESCR (Escrita)
      }
   ;

atribuicao
   : expressao_acesso
       { 
         // TODO #10 - FEITO
         // Tem que guardar o TAM, DES e o TIPO (POS do tipo, se for registro)
          empilha(tamanho); // empilha o tamanho
          empilha(deslocamento); // empilha o deslocamento
          empilha(tipo); // empilha o tipo
       }
     T_ATRIB expressao
       { 
          int tipexp = desempilha(); // desempilha o tipo da expressão
          int tipvar = desempilha(); // desempilha o tipo da variável
          deslocamento = desempilha(); // desempilha o deslocamento
          tamanho = desempilha(); // desempilha o tamanho
          if (tipexp != tipvar) // se o tipo da expressão for diferente do tipo da variável
             yyerror("Incompatibilidade de tipo!"); // erro
          // TODO #11 - FEITO
          // Se for registro, tem que fazer uma repetição do
          // TAM do registro de ARZG
          if (ehRegistro == 1) // Se for registro 
          for (int i = 0; i < tamanho; i++) // TAM do registro de ARZG
             fprintf(yyout, "\tARZG\t%d\n", deslocamento + i);  // gera ARZG (Argumento de endereço)
       }
   ;

selecao
   : T_SE expressao T_ENTAO
      { 
                int t = desempilha(); // desempilha o tipo
                if (t != LOG) // se o tipo for diferente de lógico 
                    yyerror("Incompatibilidade de tipo!"); 
                fprintf(yyout, "\tDSVF\tL%d\n", ++rotulo); // gera DSVF (Desvio para subrotina falso)
                empilha(rotulo);  // empilha o rótulo
      }
   lista_comandos T_SENAO
      { 
         fprintf(yyout, "\tDSVS\tL%d\n", ++rotulo); // gera DSVS (Desvio para subrotina verdadeiro)
         int rot = desempilha();  // desempilha o rótulo
         fprintf(yyout, "L%d\tNADA\n", rot); // gera NADA
         empilha(rotulo); // empilha o rótulo
      }
   lista_comandos T_FIMSE
      {  
         int rot = desempilha(); // desempilha o rótulo
         fprintf(yyout, "L%d\tNADA\n", rot);  // gera NADA
      }
        ;

repeticao
   : T_ENQUANTO 
       { 
         fprintf(yyout, "L%d\tNADA\n", ++rotulo); // gera NADA
         empilha(rotulo); // empilha o rótulo
       }
     expressao T_FACA 
       {  
         int t = desempilha(); // desempilha o tipo
         if (t != LOG)
            yyerror("Incompatibilidade de tipo!"); // erro
         fprintf(yyout, "\tDSVF\tL%d\n", ++rotulo);  // gera DSVF (Desvio para subrotina falso)
         empilha(rotulo); // empilha o rótulo
       }
     lista_comandos T_FIMENQUANTO
       { 
          int rot1 = desempilha(); // desempilha o rótulo
          int rot2 = desempilha(); // desempilha o rótulo
          fprintf(yyout, "\tDSVS\tL%d\n", rot2); // gera DSVS (Desvio para subrotina verdadeiro)
          fprintf(yyout, "L%d\tNADA\n", rot1);   // gera NADA
       }
   ;

expressao
   : expressao T_VEZES expressao
       { 
         testaTipo(INT,INT,INT); fprintf(yyout, "\tMULT\n");
        // Testa se o tipo da expressão é inteiro
       }
   | expressao T_DIV expressao
       {  
        testaTipo(INT,INT,INT); fprintf(yyout, "\tDIVI\n");
       // Testa se o tipo da expressão é inteiro 
     }
   | expressao T_MAIS expressao
      { 
         testaTipo(INT,INT,INT); fprintf(yyout, "\tSOMA\n"); 
            // Testa se o tipo da expressão é inteiro
       }
   | expressao T_MENOS expressao
      {  testaTipo(INT,INT,INT); fprintf(yyout, "\tSUBT\n");
        // Testa se o tipo da expressão é inteiro
        }
   | expressao T_MAIOR expressao
      {  testaTipo(INT,INT,LOG); fprintf(yyout, "\tCMMA\n");  
        // Testa se o tipo da expressão é inteiro
      }
   | expressao T_MENOR expressao
      {  testaTipo(INT,INT,LOG); fprintf(yyout, "\tCMME\n"); 
        // Testa se o tipo da expressão é inteiro
       }
   | expressao T_IGUAL expressao
      {  testaTipo(INT,INT,LOG); fprintf(yyout, "\tCMIG\n"); 
        // Testa se o tipo da expressão é inteiro
       }
   | expressao T_ELOGICO expressao
      {  testaTipo(LOG,LOG,LOG); fprintf(yyout, "\tCONJ\n");
        // Testa se o tipo da expressão é lógico
        }
   | expressao T_OU expressao
      {  testaTipo(LOG,LOG,LOG); fprintf(yyout, "\tDISJ\n");
        // Testa se o tipo da expressão é lógico
        }
   | termo
   ;
//posição do tipo da tabela -> tem que fazer essa busca
expressao_acesso
   : T_IDPONTO
       {   //--- Primeiro nome do registro
            id = buscaSimbolo(atomo); // busca o símbolo na tabela de símbolos

           if (!ehRegistro) { // se não for registro
              // TODO #12  
              // 1. busca o símbolo na tabela de símbolos
               ehRegistro = 1; // flag para indicar que é registro

              // 2. se não for do tipo registro, tem erro
              if (tabSimb[id].tip != REG) // se não for registro
              {
                sprintf(msg, "O identificador [%s] não é registro!", atomo);
                yyerror(msg);
              }

              // 3. guardar o TAM, POS e DES desse t_IDENTIF
              tamanho = tabSimb[id].tam; // tamanho do tipo
              posicao = tabSimb[id].pos; // posição do tipo na tab. símbolos
              deslocamento = deslocamento + tamanho; // deslocamento do tipo
           } else {
              //--- Campo que é registro
              // 1. busca esse campo na lista de campos
               aux1 = procuraDeslocamento(deslocamento); // procura o deslocamento
               ptno campo = buscaCampo(tabSimb[id].campos, atomo); // busca o campo na lista de campos

              // 2. se não encontrar, erro 
               if (campo == NULL){ // Se não encontrar o campo
                sprintf(msg, "O campo [%s] não existe na estrutura", atomo);
                yyerror(msg);
               }

              // 3. se encontrar e não for registro, erro
               if (campo->tip != REG){ // Se encontrar o campo e não for registro
                  sprintf(msg, "O campo [%s] não é registro!", atomo);
                    yyerror(msg);
               }

              // 4. guardar o TAM, POS e DES desse CAMPO
               tamanho = campo->tam; // tamanho do tipo
               posicao = campo->pos; // posição do tipo na tab. símbolos
               deslocamento = campo->des; // deslocamento do tipo
           }
       }
     expressao_acesso
   | T_IDENTIF
       {   
           if (ehRegistro == 1) { // se for registro
               // TODO #13
               // 1. buscar esse campo na lista de campos
               aux2 = procuraPosicao(posicao); // procura a posição
               ptno campo = buscaCampo(tabSimb[posicao].campos, atomo); // busca o campo na lista de campos

               // 2. Se não encontrar, erro
               if (campo == NULL){ // Se não encontrar o campo
                sprintf(msg, "O campo [%s] não existe na estrutura", atomo);
                yyerror(msg);
               }
               // 3. guardar o TAM, DES e TIPO desse campo.
               //    o tipo (TIP) nesse caso é a posição do tipo
               //    na tabela de símbolos
               tamanho = campo->tam; // tamanho do tipo
               deslocamento = campo->des; // deslocamento do tipo
               posicao = campo->pos; // posição do tipo na tab. símbolos
               tipo = campo->pos; // tipo do campo
           } else {
              // TODO #14

              id = buscaSimbolo (atomo); // busca o símbolo na tabela de símbolos
              if (id == -1) { // se não encontrar o símbolo
                  yyerror("Variável não encontrada!"); 
              }
            
              // guardar TAM, DES e TIPO dessa variável
               tamanho = tabSimb[id].tam; // tamanho do tipo
               deslocamento = tabSimb[id].end; // deslocamento do tipo
               tipo = tabSimb[id].tip; // tipo do campo
           }
           ehRegistro = 0; // flag para indicar que não é registro
       };


termo
   : expressao_acesso
       {
          // TODO #15
          // Se for registro, gerar CRVG para cada campo (em ordem inversa)
          if (ehRegistro ==1){ // Se for registro
            for (int i = tabSimb[posTab].campos->tam -1; i>=0; i=i-1) // TAM do registro
               fprintf(yyout, "\tCRVG\t%d\n", tabSimb[posTab].end + i); // gera CRVG (Carrega valor global)
          }
          fprintf(yyout, "\tCRVG\t%d\n", tabSimb[posTab].end); // gera CRVG (Carrega valor global)
          empilha(tipo);  // Empilha o tipo
       }
   | T_NUMERO
       {  
          fprintf(yyout, "\tCRCT\t%s\n", atomo); // gera CRCT (Carrega constante)  
          empilha(INT); // Empilha o tipo
       }
   | T_V
       {  
          fprintf(yyout, "\tCRCT\t1\n"); // gera CRCT (Carrega constante)
          empilha(LOG); // Empilha o tipo
       }
   | T_F
       {  
          fprintf(yyout, "\tCRCT\t0\n");  // gera CRCT (Carrega constante)
          empilha(LOG); // Empilha o tipo
       }
   | T_NAO termo
       {  
          int t = desempilha(); // desempilha o tipo
          if (t != LOG) // se o tipo for diferente de lógico
              yyerror("Incompatibilidade de tipo!"); 
          fprintf(yyout, "\tNEGA\n");
          empilha(LOG); // Empilha o tipo
       }
   | T_ABRE expressao T_FECHA
   ;
%%

int main(int argc, char *argv[]) { // argc = número de argumentos; argv = argumentos
    char *p, nameIn[100], nameOut[100]; // p = ponteiro; nameIn = nome do arquivo de entrada; nameOut = nome do arquivo de saída
    argv++;
    if (argc < 2) { //  se o número de argumentos for menor que 2
        puts("\nCompilador da linguagem SIMPLES"); 
        puts("\n\tUSO: ./simples <NOME>[.simples]\n\n");
        exit(1);
    }
    p = strstr(argv[0], ".simples"); // strstr = procura uma string dentro de outra string
    if (p) *p = 0; 
    strcpy(nameIn, argv[0]); // copia o nome do arquivo de entrada
    strcat(nameIn, ".simples"); // concatena o nome do arquivo de entrada com a extensão .simples
    strcpy(nameOut, argv[0]); // copia o nome do arquivo de saída
    strcat(nameOut, ".mvs"); // concatena o nome do arquivo de saída com a extensão .mvs
    yyin = fopen(nameIn, "rt"); // abre o arquivo de entrada
    if (!yyin) {
        puts ("Programa fonte não encontrado!");
        exit(2);
    }
    yyout = fopen(nameOut, "wt");
    yyparse();
    return 0;
}