// ============================================================
//  Relatório — T1: O Inflator Tabajara Plus de Textos
// ============================================================

#set document(
  title: "T1 — O Inflator Tabajara Plus de Textos",
  author: "Vicenzo Másera",
)

#set page(
  paper: "a4",
  margin: (top: 3cm, bottom: 2.5cm, left: 3cm, right: 2.5cm),
  numbering: "1",
  number-align: right,
)

#set text(
  font: "New Computer Modern",
  size: 12pt,
  lang: "pt",
)

#set heading(numbering: "1.")

#set par(
  justify: true,
  leading: 0.75em,
  spacing: 1.2em,
)

// Capa
#align(center)[
  #v(2cm)

  #text(size: 14pt, weight: "bold")[
    PUCRS — Engenharia de Software — Algoritmos e Estruturas de Dados 2
  ]

  #v(0.5cm)

  #text(size: 13pt)[
    2026/1
  ]

  #v(3cm)

  #text(size: 18pt, weight: "bold")[
    T1 — O Inflator Tabajara Plus de Textos
  ]

  #v(1cm)

  #text(size: 13pt)[
    Professor: Alexandre Agustini
  ]

  #v(3cm)

  #text(size: 13pt)[
    *Aluno(s):* \
    Vicenzo Ribas Másera
    \
    Arthur Cavalheiro Marques
  ]

  #v(1cm)

  #text(size: 12pt)[
    #datetime.today().display("[day]/[month]/[year]")
  ]
]

#pagebreak()

// Sumário
#outline(
  title: "Sumário",
  indent: 1.5em,
)

#pagebreak()

// ============================================================
= Descrição do Problema

O problema do "Inflator Tabajara Plus" consiste em calcular o tamanho final de um texto gerado a partir de sucessivas substituições de caracteres. O objetivo é determinar apenas a quantidade total de caracteres resultantes.

A entrada é fornecida através de um arquivo de texto. Cada linha pode conter uma regra de substituição no formato `<letra> <string_de_substituicao>`, onde a string possui no máximo 1024 caracteres, ou apenas uma `<letra>`, indicando que esta não possui regra de expansão (ou seja, é um caractere terminal).

A letra inicial (raiz da expansão) não é fornecida explicitamente de forma isolada. Ela deve ser inferida: que não é "filha" de nenhuma outra letra. A saída esperada é um número inteiro longo (`unsigned long` na linguagem C) representando o tamanho final da string após todas as substituições possíveis terem sido aplicadas recursivamente.

== Exemplo Ilustrativo

#figure(
  table(
    columns: (auto, 1fr),
    inset: 8pt,
    align: (center, left),
    stroke: 0.5pt,
    [*Letra*], [*Substituição*],
    [`a`], [`memimomu`],
    [`e`], [`mimomu`],
    [`i`], [`mooo`],
    [`u`], [`mimimi`],
    [`o`], [_(sem substituição)_],
    [`m`], [_(sem substituição)_],
  ),
  caption: [Tabela de substituições do exemplo do enunciado.],
)

Para chegar aos 47 caracteres finais, calculamos o tamanho de baixo para cima (ou nas folhas da árvore de recursão). Letras sem regras como `m` e `o` valem 1.
- `i` vira `mooo` $->$ 1 + 1 + 1 + 1 = 4.
- `u` vira `mimimi` $->$ 1 + 4 + 1 + 4 + 1 + 4 = 15.
- `e` vira `mimomu` $->$ 1 + 4 + 1 + 1 + 1 + 15 = 23.
- `a` vira `memimomu` $->$ 1 + 23 + 1 + 4 + 1 + 1 + 1 + 15 = 47.

#pagebreak()

// ============================================================
= Descrição da Solução

== Ideia Geral

A intuição principal foi perceber que o problema não exige a string resultante, apenas o seu tamanho. Se tentássemos alocar memória para concatenar as strings, rapidamente esgotaríamos a RAM em entradas grandes. A cada chamada, em vez de retornar strings, retornamos inteiros que são somados na subida da recursão.

== Estruturas de Dados Utilizadas

Para garantir acesso em tempo constante $O(1)$ às regras de substituição, utilizou-se o princípio de Tabela Hash direta através de arrays em C:
- `char *regras[26]`: Um array de ponteiros onde o índice é calculado pela subtração da tabela ASCII (`letra - 'a'`). Ele armazena as strings de substituição.
- `int apareceComoFilho[26]`: Um array booleano (0 ou 1) usado para rastrear quais letras aparecem no lado direito das regras, fundamental para descobrir a letra inicial.

== Algoritmo — Pseudocódigo

```C
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

unsigned long calcularTamanho(char c, char *vetor[], unsigned long cache[]);

int main() {
    FILE *pFile = fopen("input.txt", "r");
    if (pFile == NULL) {
        printf("Não foi possível ler o arquivo");
        return 1;
    }
    char *regras[26] = {0};
    char letra;
    char valor[1025] = {0};
    char buffer[1050] = {0};
    int apareceComoFilho[26] = {0};
    while (fgets(buffer, sizeof(buffer), pFile) != NULL) {
        if (sscanf(buffer, "%c %s", &letra, valor) == 2) {
            printf("%c == %s\n", letra, valor);
            regras[letra - 'a'] = strdup(valor);
            for (int i = 0; valor[i] != '\0'; i++) {
                apareceComoFilho[valor[i] - 'a'] = 1;
            }
        } else if (sscanf(buffer, "%c", &letra) == 1) {
            printf("%c\n", letra);
        } else {
            break;
        }
    }
    char letraInicial;
    for (int i = 0; i < 26; i++) {
        if (regras[i] != NULL && apareceComoFilho[i] == 0) {
            letraInicial = 'a' + i;
        }
    }
    unsigned long cache[26] ={0};
    unsigned long soma = calcularTamanho(letraInicial, regras, cache);
    printf("%lu\n",soma);
    for (int i = 0; i < 26; i++) {
        if (regras[i] != NULL) {
            free(regras[i]);
        }
    }
    fclose(pFile);
    return 0;
}


unsigned long calcularTamanho(char c, char *vetor[], unsigned long cache[]) {
    if (vetor[c - 'a'] == NULL) {
        return 1;
    }
    if (cache[c - 'a'] > 0) {
        return cache[c - 'a'];
    }

    char *valor = vetor[c - 'a'];
    unsigned long soma = 0;

    for (int i = 0; valor[i] != '\0'; i++) {
        soma = soma + calcularTamanho(valor[i], vetor, cache);
    }
    cache[c - 'a'] = soma;
    return soma;
}
```

== Determinação da Letra Inicial

lida, o algoritmo itera sobre todos os caracteres da string de substituicao. Para cada caractere, marca-se a posição correspondente no array apareceComoFilho como 1 (verdadeiro).
Após ler todo o arquivo, basta procurar no array regras uma letra que possua uma regra mapeada (diferente de NULL), mas cujo valor em apareceComoFilho seja 0. Essa letra obrigatoriamente é a raiz, pois engatilha expansões mas nunca é gerada por outra regra.

== Complexidade

Como não há programação dinâmica (memoização(cache)), o algoritmo recalcula subproblemas repetidos. No pior caso, a complexidade de tempo é proporcional ao tamanho final da string virtual gerada, ou seja, $O(N)$, onde $N$ é o número de caracteres da expansão completa (o que pode representar um crescimento exponencial em relação ao tamanho da entrada.

== Dificuldades Encontradas

// Relate os obstáculos que apareceram durante o desenvolvimento
// e como você os superou.

#pagebreak()

// ============================================================
= Testes e Validação

== Caso de Teste do Enunciado

// Mostre que sua solução produz 47 para o exemplo dado.

#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    inset: 8pt,
    align: center,
    stroke: 0.5pt,
    [*Entrada*], [*Saída Esperada*], [*Saída Obtida*],
    [Exemplo do enunciado], [47], [_preencha_],
  ),
  caption: [Verificação do caso do enunciado.],
)

== Casos de Teste da Disciplina

// Preencha a tabela com os arquivos de teste disponibilizados na página da disciplina.

#figure(
  table(
    columns: (auto, 1fr, 1fr, 1fr),
    inset: 8pt,
    align: (left, center, center, center),
    stroke: 0.5pt,
    [*Arquivo*], [*Tamanho Final*], [*Tempo (s)*], [*Observações*],
    [`teste01.txt`], [], [], [],
    [`teste02.txt`], [], [], [],
    [`teste03.txt`], [], [], [],
    [`teste04.txt`], [], [], [],
    [`teste05.txt`], [], [], [],
    // Adicione linhas conforme necessário
  ),
  caption: [Resultados nos casos de teste da disciplina.],
)

== Testes Adicionais (opcional)

// Descreva casos-limite que você criou para estressar sua solução,
// como letras sem substituição, cadeias muito longas, ciclos (se aplicável), etc.

#pagebreak()

// ============================================================
= Resultados e Análise

// Comente os tempos obtidos. Sua solução escala bem?
// Houve algum caso que demorou mais do que o esperado? Por quê?

#pagebreak()

// ============================================================
= Conclusões

// Resuma o que você aprendeu com o trabalho.
// O que funcionou bem? O que faria diferente numa próxima vez?

#pagebreak()

// ============================================================
= Referências

+ #text[Cormen, T. H. et al. _Introduction to Algorithms_. 4ª ed. MIT Press, 2022.]
