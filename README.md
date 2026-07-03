# Bootloader de Sistema Operacional Simplificado (T02)

## 📌 Sobre o Projeto

Este projeto consiste no desenvolvimento e na execução de um **Bootloader de 16 bits em Assembly Intel**, projetado como parte das atividades práticas da disciplina de Sistemas Operacionais do IDP.

O objetivo principal é construir um programa de inicialização que:

- configure o ambiente básico do hardware em **Modo Real**;
- carregue um **Kernel simplificado** a partir de um disco virtual para a memória RAM;
- transfira o controle de execução para ele.

---

## 💻 Objetivos Alcançados

- **Compreensão do Processo de Boot**: entendimento prático de conceitos como POST, MBR (Master Boot Record), Vetor de Reset e Assinatura de Boot (`0xAA55`).
- **Manipulação de Memória em Modo Real**: configuração manual de registradores de segmento (`DS`, `ES`, `SS`), ponteiro de pilha (`SP`) e uso do esquema de endereçamento por segmento estendido.
- **Uso de Interrupções de BIOS**: utilização da interrupção `0x13` para resetar e ler setores do disco rígido virtual para a RAM.
- **Comunicação entre Bootloader e Kernel**: passagem de parâmetros através do registrador `AX`, utilizando o cálculo do Verificador de Matrícula (VM).

---

## 🛠️ Ambiente de Desenvolvimento e Ferramentas

O projeto foi montado, testado e validado no ambiente Linux do laboratório, utilizando as seguintes especificações e ferramentas:

| Categoria | Ferramenta / Versão |
|---|---|
| Sistema Operacional / Kernel | Ubuntu 24.04 (via WSL2), Kernel `6.6.87.2-microsoft-standard-WSL2` |
| Compilador / Assembler | `as` (GNU Assembler), pacote `gcc` 13.3.0+ |
| Linker | `ld` (GNU Linker) |
| Emulador de Hardware | QEMU (`qemu-system-x86_64`) 8.2.2+ |
| Utilitários de Sistema | `dd` e `hexdump` (`coreutils` 9.4+) |

---

## 🗂️ Fluxo de Arquivos no Repositório

| Arquivo | Descrição |
|---|---|
| `bootloader.s` | Código-fonte em Assembly contendo a rotina de inicialização, o preenchimento de zeros e a assinatura mágica de boot. |
| `.gitignore` | Configuração para impedir que arquivos temporários de compilação ou imagens pesadas de disco (`.o`, `.img`, `.zip`) sejam enviados acidentalmente ao GitHub. |

---

## ⚙️ Instruções de Compilação e Execução

### 1. Compilar e Linkar o Bootloader

Monta o código-fonte gerando um binário puro de exatamente 512 bytes, mapeado para o endereço de memória `0x7C00` (padrão lido pela BIOS):

```bash
as -o bootloader.o bootloader.s
ld -o bootloader --oformat binary -Ttext 0x7c00 bootloader.o
```

### 2. Criar e Montar o Disco Virtual (`disco.img`)

Gera uma imagem de disco de 720 KB preenchida com zeros, injeta o executável do bootloader no Setor 0 e anexa o binário do kernel logo em seguida, a partir do Setor 1:

```bash
dd if=/dev/zero of=disco.img bs=1024 count=720
dd if=bootloader of=disco.img conv=notrunc seek=0
dd if=kernel of=disco.img conv=notrunc bs=512 seek=1
```

### 3. Executar no Emulador QEMU

Inicia a emulação da máquina virtual carregando o disco virtual gerado:

```bash
qemu-system-x86_64 -drive format=raw,file=disco.img
```

> **Nota de Depuração:** caso ocorra o erro `Failed to get "write" lock` devido a algum travamento residual em segundo plano, execute `killall qemu-system-x86_64` ou force a execução em modo somente leitura anexando a flag `,readonly=on`.

---

## 🔢 Regra de Negócio: Verificador de Matrícula (VM)

O Kernel exige que o bootloader armazene o valor do Verificador de Matrícula no registrador `AX` antes de saltar para o endereço `0x7E00`.

A fórmula adotada é a soma do produto de cada dígito $d_i$ pela sua respectiva posição $i$ (da esquerda para a direita), aplicando o operador módulo 4093 ao final:

$$VM = \sum_{i=1}^{n} (d_i \times i) \pmod{4093}$$

**Exemplo de cálculo** para a matrícula `2321055`:

$$(2 \times 1) + (3 \times 2) + (2 \times 3) + (1 \times 4) + (0 \times 5) + (5 \times 6) + (5 \times 7) = 83$$

$$83 \pmod{4093} = \mathbf{83}$$

No código `bootloader.s`, a instrução correspondente aplicada foi:

```asm
mov ax, 83
```

---

## 🎓 Autor

- **Nome:** [Seu Nome Aqui]
- **Curso:** Ciência da Computação / Engenharia de Software
- **Instituição:** IDP Asa Norte
- **Professor:** Jeremias Moreira Gomes
