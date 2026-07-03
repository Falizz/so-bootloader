.code16                         # Indica que o processador operará em Modo Real (16 bits)
.intel_syntax noprefix
.global _start

_start:
    # 1. Desabilitar as interrupções temporariamente para configurar os registradores
    cli

    # 2. Limpar os registradores de segmento
    mov ax, 0x0
    mov ds, 0x0
    mov es, 0x0
    mov ss, 0x0

    # 3. Mover o ponteiro de pilha (Stack Pointer) para o endereço 0x7c00
    mov sp, 0x7c00

    # 4. Habilitar novamente as interrupções
    sti

    # 5. Resetar o sistema de disco (Função 0x0 da INT 0x13)
    mov ah, 0x0
    mov dl, 0x80                # 0x80 indica o primeiro disco rígido
    int 0x13

    # 6. Setar o segmento estendido (ES) para 0x7E0
    mov ax, 0x7E0
    mov es, ax

    # 7. Carregar o kernel para a memória (Função 0x02 da INT 0x13)
    # Endereço final mapeado na RAM: (0x7E0 << 4) + 0x0000 = 0x7E00
    mov ah, 0x02                # Função de leitura de setores do disco
    mov al, 0x04                # Ler 4 setores (suficiente para o tamanho do kernel)
    mov ch, 0x00                # Cilindro 0
    mov cl, 0x02                # Setor 2 (O setor 1/setor 0 da BIOS contém este bootloader)
    mov dh, 0x00                # Cabeça 0
    mov dl, 0x80                # Unidade de disco (Hard Disk)
    mov bx, 0x0000              # Offset de destino em ES (ES:BX = 0x7E0:0x0000)
    int 0x13

    # 8. Inserir o Verificador da Matrícula (VM) no registrador AX
    mov ax, 798

    # 9. Saltar para o início do kernel carregado no endereço 0x7E00
    jmp 0x7E0:0x0000

# Preenchimento automático com zeros até o byte 510
.fill (510 - (. - _start)), 1, 0

# bytes 511 e 512: Assinatura mágica exigida pela BIOS para reconhecer o disco como bootável
.byte 0x55, 0xaa
