
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

== Algoritmo (Pseudo Código)

```
FUNÇÃO Principal():
    ABRIR arquivo "input.txt"

    letraInicial = NULO
    regras = VETOR vazio (mapeamento de chars para strings)

    // Leitura das regras
    PARA CADA linha no arquivo:
        LER 'letra' e 'texto'
        SE for a primeira linha:
            letraInicial = letra
        regras[letra] = texto

    // Processamento
    INICIAR cronômetro
    tamanho_total = CalcularTamanho(letraInicial, regras)
    PARAR cronômetro

    IMPRIMIR tamanho_total e tempo gasto
FIM FUNÇÃO

FUNÇÃO CalcularTamanho(letra, regras):
    // Caso base: se a letra não for uma regra
    SE regras[letra] for VAZIO:
        RETORNA 1

    // Soma o tamanho gerado por cada caractere da regra
    soma = 0
    texto = regras[letra]

    PARA CADA caractere EM texto:
        soma = soma + CalcularTamanho(caractere, regras)
    RETORNA soma
FIM FUNÇÃO
```

== Determinação da Letra Inicial

A letra inicial é definida como a primeira letra que aparece no arquivo de entrada. Para identificá-la, utiliza-se um contador inicializado em zero antes do laço de leitura. Na primeira iteração do `while`, quando o contador ainda vale zero, a letra lida à esquerda do buffer é armazenada na variável `letraInicial`. O contador é então incrementado a cada iteração, garantindo que apenas a primeira ocorrência seja capturada e que o valor não seja sobrescrito nas leituras seguintes.

== Complexidade

Por não utilizar memoização , conforme estabelecido pelos requisitos do trabalho, o algoritmo pode recomputar o tamanho de expansão de um mesmo caractere múltiplas vezes ao longo da árvore de recursão. No pior caso, a complexidade de tempo é proporcional ao tamanho da string virtualmente expandida, ou seja, $O(N)$, onde $N$ é o número total de caracteres da expansão completa. Como $N$ pode crescer de forma exponencial em relação ao número de regras, entradas com cadeias profundas de substituições recíprocas tendem a apresentar tempos de execução significativamente maiores.

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

== Casos de Teste (sem memoização)

#figure(
  table(
    columns: (auto, 1fr, 1fr),
    inset: 8pt,
    align: (left, center, center),
    stroke: 0.5pt,
    [*Arquivo*], [*Tamanho Final*], [*Tempo (s)*],
    [`teste01.txt`], [10], [0.00],
    [`teste02.txt`], [1202], [0.00],
    [`teste03.txt`], [12328], [0.00],
    [`teste04.txt`], [59443], [0.00],
    [`teste05.txt`], [3745926], [0.03],
    [`teste06.txt`], [3848292], [0.03],
    [`teste07.txt`], [4258112], [0.03],
    [`teste08.txt`], [7683690], [0.05],
    [`teste09.txt`], [13884922], [0.11],
    [`teste10.txt`], [2329991102], [27.23],
    [`teste11.txt`], [1881188405], [229.78],
    [`teste12.txt`], [Sem resultado], [~],
    [`teste13.txt`], [Sem resultado], [~],
  ),
  caption: [Resultados nos casos de teste do algoritmo sem o uso de programação dinâmica.],
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

+ #text[Cormen, T. H. et al. _Introduction to Algorithms_. 5ª ed. MIT Press, 2022.]
