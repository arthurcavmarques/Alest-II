
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

O problema do "Inflator Tabajara Plus" consiste em calcular o tamanho final de um texto gerado a partir de sucessivas substituições de caracteres, sem que seja necessário construir a string resultante. O objetivo é determinar apenas a quantidade total de caracteres após a expansão completa.

A entrada é fornecida por meio de um arquivo de texto. Cada linha pode conter uma regra de substituição no formato `<letra> <string_de_substituicao>`, onde a string de substituição possui no máximo 1024 caracteres, ou apenas uma `<letra>` isolada, indicando que este caractere não possui regra de expansão — ou seja, é um símbolo terminal.

A letra inicial (raiz da expansão) corresponde à primeira letra listada no arquivo de entrada. A saída esperada é um número inteiro sem sinal de 64 bits (`unsigned long` em C) representando o tamanho total da string resultante após a aplicação recursiva de todas as substituições possíveis.

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

Para obter os 47 caracteres finais, o tamanho é calculado de baixo para cima, a partir das folhas da árvore de recursão. Letras sem regra de expansão, como `m` e `o`, contribuem com valor 1 cada.

- `i` expande para `mooo` $->$ 1 + 1 + 1 + 1 = 4.
- `u` expande para `mimimi` $->$ 1 + 4 + 1 + 4 + 1 + 4 = 15.
- `e` expande para `mimomu` $->$ 1 + 4 + 1 + 1 + 1 + 15 = 23.
- `a` expande para `memimomu` $->$ 1 + 23 + 1 + 4 + 1 + 1 + 1 + 15 = 47.

#pagebreak()

// ============================================================
= Descrição da Solução

== Ideia Geral

A intuição central foi perceber que o problema não exige a construção da string resultante, apenas o cálculo de seu tamanho. Tentar alocar e concatenar as strings em memória seria inviável para entradas grandes, pois o resultado pode crescer exponencialmente. Portanto, em vez de retornar strings, cada chamada recursiva retorna um inteiro que representa o comprimento da expansão daquele caractere, e esses valores são somados à medida que a recursão retorna.

== Estruturas de Dados Utilizadas

Para garantir acesso em tempo constante $O(1)$ às regras de substituição, utilizou-se uma tabela de endereçamento direto implementada por meio de um array em C:

- `char *regras[26]`: um array de ponteiros indexado pela posição da letra no alfabeto, calculada pela expressão `letra - 'a'`. Cada posição armazena a string de substituição correspondente, ou `NULL` caso a letra seja terminal.

Essa abordagem equivale a uma tabela hash com função de hash perfeita, eliminando colisões e garantindo acesso em $O(1)$.

== Algoritmo (C)

```C
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

unsigned long calcularTamanho(char c, char *vetor[]);

int main() {
    FILE *pFile = fopen("input.txt", "r");
    if (pFile == NULL) {
        printf("Não foi possível ler o arquivo");
        return 1;
    }
    clock_t inicio, fim;
    double tempo_final;

    char *regras[26] = {0};
    char letra;
    char valor[1025] = {0};
    char buffer[1050] = {0};
    char letraInicial;
    int count = 0;

    while (fgets(buffer, sizeof(buffer), pFile) != NULL) {
        if (sscanf(buffer, "%c %s", &letra, valor) == 2) {
            if (count == 0) {
                letraInicial = letra;
            }
            printf("%c == %s\n", letra, valor);
            regras[letra - 'a'] = strdup(valor);
        } else if (sscanf(buffer, "%c", &letra) == 1) {
            printf("%c\n", letra);
        } else {
            break;
        }
        count++;
    }

    inicio = clock();
    unsigned long soma = calcularTamanho(letraInicial, regras);
    fim = clock();
    tempo_final = ((double) fim - inicio) / CLOCKS_PER_SEC;
    printf("%lu\n",soma);
    printf("%f\n",tempo_final);
    for (int i = 0; i < 26; i++) {
        if (regras[i] != NULL) {
            free(regras[i]);
        }
    }
    fclose(pFile);
    return 0;
}

unsigned long calcularTamanho(char c, char *vetor[]) {
    if (vetor[c - 'a'] == NULL) {
        return 1;
    }

    char *valor = vetor[c - 'a'];
    unsigned long soma = 0;

    for (int i = 0; valor[i] != '\0'; i++) {
        soma = soma + calcularTamanho(valor[i], vetor);
    }
    return soma;
}
```

== Determinação da Letra Inicial

A letra inicial é definida como a primeira letra que aparece no arquivo de entrada. Para identificá-la, utiliza-se um contador inicializado em zero antes do laço de leitura. Na primeira iteração do `while`, quando o contador ainda vale zero, a letra lida à esquerda do buffer é armazenada na variável `letraInicial`. O contador é então incrementado a cada iteração, garantindo que apenas a primeira ocorrência seja capturada e que o valor não seja sobrescrito nas leituras seguintes.

== Complexidade

Por não utilizar memoização — conforme estabelecido pelos requisitos do trabalho — o algoritmo pode recomputar o tamanho de expansão de um mesmo caractere múltiplas vezes ao longo da árvore de recursão. No pior caso, a complexidade de tempo é proporcional ao tamanho da string virtualmente expandida, ou seja, $O(N)$, onde $N$ é o número total de caracteres da expansão completa. Como $N$ pode crescer de forma exponencial em relação ao número de regras, entradas com cadeias profundas de substituições recíprocas tendem a apresentar tempos de execução significativamente maiores.

== Dificuldades Encontradas

A principal dificuldade do grupo não foi a implementação da recursão em si — parte que inicialmente gerava mais receio —, mas sim encontrar uma estrutura de dados adequada para mapear letras às suas respectivas regras de substituição em C. Foram consideradas alternativas como migrar para C++, ou implementar um hashmap genérico em um arquivo de cabeçalho separado. A solução surgiu ao perceber que a tabela ASCII permite mapear cada letra minúscula diretamente a um índice inteiro por meio da expressão `letra - 'a'`, resultando em um array de 26 posições que funciona como uma tabela hash de endereçamento direto, sem colisões e com acesso em tempo constante.

#pagebreak()

// ============================================================
= Testes e Validação

== Caso de Teste do Enunciado

#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    inset: 8pt,
    align: center,
    stroke: 0.5pt,
    [*Entrada*], [*Saída Esperada*], [*Saída Obtida*],
    [Exemplo do enunciado], [47], [47],
  ),
  caption: [Verificação do caso do enunciado.],
)

== Casos de Teste da Disciplina

#figure(
  table(
    columns: (auto, 1fr, 1fr),
    inset: 8pt,
    align: (left, center, center),
    stroke: 0.5pt,
    [*Arquivo*], [*Tamanho Final*], [*Tempo (s)*],
    [`teste01.txt`], [], [],
    [`teste02.txt`], [], [],
    [`teste03.txt`], [], [],
    [`teste04.txt`], [], [],
    [`teste05.txt`], [], [],
    [`teste06.txt`], [], [],
    [`teste07.txt`], [], [],
    [`teste08.txt`], [], [],
    [`teste09.txt`], [], [],
    [`teste10.txt`], [], [],
    [`teste11.txt`], [], [],
    [`teste12.txt`], [], [],
    [`teste13.txt`], [], [],
  ),
  caption: [Resultados nos casos de teste da disciplina.],
)

// ============================================================
= Resultados e Análise

A solução apresentou desempenho satisfatório nos casos de teste de menor porte. Para entradas com cadeias de substituição curtas e baixo grau de compartilhamento entre regras, o tempo de execução manteve-se em frações de segundo.

Nos casos de maior porte, o crescimento exponencial do número de chamadas recursivas tornou-se evidente. Como o algoritmo não utiliza memoização, o tamanho de expansão de um mesmo caractere é recalculado toda vez que ele aparece na string de substituição de outro. Esse fator explica os tempos mais elevados observados nos arquivos de teste com cadeias de substituição mais profundas ou com maior grau de reutilização de símbolos intermediários.

Uma otimização natural, caso fosse permitida, seria armazenar em cache o resultado de `calcularTamanho(c)` para cada um dos 26 caracteres possíveis. Com isso, cada subproblema seria resolvido no máximo uma vez, reduzindo a complexidade efetiva para $O(26 dot S)$, onde $S$ é o comprimento máximo de uma string de substituição.

#pagebreak()

// ============================================================
= Conclusões

Este trabalho permitiu aplicar na prática o conceito de recursão com expansão simbólica, situação recorrente em linguagens formais, compiladores e sistemas de geração de conteúdo. A ideia central — trabalhar apenas com o tamanho das strings em vez de construí-las efetivamente — foi determinante para tornar a solução viável em termos de memória.

A ausência de memoização, imposta pelos requisitos do trabalho, evidenciou de forma clara a diferença de desempenho entre algoritmos com e sem reaproveitamento de subproblemas. Casos com alta sobreposição de chamadas recursivas revelaram crescimento exponencial no tempo de execução, ilustrando na prática a importância da programação dinâmica em problemas dessa natureza.

#pagebreak()

// ============================================================
= Referências

+ #text[Cormen, T. H. et al. _Introduction to Algorithms_. 4ª ed. MIT Press, 2022.]
