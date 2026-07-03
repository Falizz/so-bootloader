#include <stdio.h>
#include <math.h>

int main (void) {

    char *str = "2321055"; 
    int vm = 0;

    for (int i = 0; str[i] != '\0'; i++) {
        int caractere_matricula = str[i] - '0';
        vm += pow(caractere_matricula * (i + 1), 3);
    }

    vm = vm % 4093;

    printf("%d\n", vm);

    return 0;
}