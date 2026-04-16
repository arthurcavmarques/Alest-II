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
