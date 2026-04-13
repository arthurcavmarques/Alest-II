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
