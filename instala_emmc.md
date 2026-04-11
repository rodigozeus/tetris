# Instalação do Rocknix na eMMC interna do RG DS

## Contexto

O Anbernic RG DS tem uma eMMC interna de ~29GB que vem com Android de fábrica. O objetivo é instalar o Rocknix nela, liberando o slot de SD card exclusivamente para ROMs e ganhando mais velocidade de boot.

O Android de fábrica é descartável — sem interesse em manter dual boot.

---

## O que já sabemos

### Estrutura de armazenamento

| Dispositivo | Tamanho | Conteúdo |
|-------------|---------|----------|
| `/dev/mmcblk0` | ~29GB | eMMC interna (Android de fábrica, 15 partições) |
| `/dev/mmcblk1` | ~119GB | SD card (Rocknix em execução) |

A eMMC tem `mmcblk0boot0` e `mmcblk0boot1` — partições especiais de boot do hardware.

### Estrutura da imagem do Rocknix

A imagem `ROCKNIX-RK3566.aarch64-XXXXXX-Specific.img.gz` contém:

| Setor | Conteúdo |
|-------|----------|
| 0 | MBR |
| 64 | idbloader (magic `RKNS` — bootloader Rockchip) |
| 67–470 | U-Boot TPL/SPL |
| 16384 | U-Boot proper |
| 32768 | Partição FAT32 `ROCKNIX` (kernel, DTB, extlinux) |
| ~95936+ | Partição ext4 `STORAGE` |

Boot configurado por labels: `boot=LABEL=ROCKNIX disk=LABEL=STORAGE`

DTB do RG DS: `rk3568-anbernic-rg-ds.dtb`

### Script nativo `installtointernal`

Existe em `/usr/bin/installtointernal` mas **não é compatível com RK3566** — foi feito para dispositivos Snapdragon (SM8250/SM8550/SM8650) com UFS (`/dev/sda`). Não serve para o RG DS.

### Sequência de boot do RK3566

1. BootROM (imutável na CPU)
2. Lê idbloader do `mmcblk0boot0` (eMMC) — ou sector 64 do SD card
3. Se falhar → tenta SD card

**Implicação de segurança:** com o SD card intocado e com Rocknix funcionando, o pior cenário é reiniciar com o SD inserido e tudo volta ao normal.

---

## Métodos disponíveis

### Método A — USB Mass Storage (preferido, mais seguro)

Informação da comunidade: alguns dispositivos RK3566 da Anbernic permitem entrar em modo de armazenamento em massa via USB.

**Procedimento:**
1. Desligar o console
2. Conectar USB ao PC (porta DC/OTG)
3. Ligar segurando **Volume -**
4. Se aparecer como disco no Windows → usar **Balena Etcher** para gravar a imagem
5. Reiniciar segurando **Volume +**

**Status:** ainda não testado no RG DS — primeiro passo a tentar.

---

### Método B — dd via SSH (plano B)

Rodar enquanto Rocknix está ativo no SD card.

**Pré-requisito:** transferir a imagem para o console:
```bash
# No PC
scp "games/releases/ROCKNIX-RK3566.aarch64-20260409-Specific.img.gz" root@<IP>:/storage/
```

**Passo 1 — Habilitar escrita no boot0:**
```bash
echo 0 > /sys/block/mmcblk0boot0/force_ro
```

**Passo 2 — Gravar idbloader do Rocknix no boot0:**
```bash
gunzip -c /storage/ROCKNIX-RK3566*.img.gz | dd skip=64 bs=512 count=960 of=/dev/mmcblk0boot0 seek=64
```

**Passo 3 — Gravar imagem completa na eMMC:**
```bash
gunzip -c /storage/ROCKNIX-RK3566*.img.gz | dd of=/dev/mmcblk0 bs=4M status=progress
```

**Passo 4 — Reiniciar sem o SD card.**

> ⚠️ O Passo 2 (gravar no boot0) é importante para substituir o bootloader do Android pelo do Rocknix, garantindo que o U-Boot do Rocknix seja carregado — e ele tem fallback para SD se a eMMC falhar.

---

## Imagem disponível localmente

```
games/releases/ROCKNIX-RK3566.aarch64-20260409-Specific.img.gz
```

Usar sempre a versão **Specific** (tem suporte específico ao RG DS).

---

## Resultado esperado

- Rocknix rodando da eMMC interna
- SD card usado só para ROMs
- Boot mais rápido
- Slot de SD livre para um cartão de alta capacidade dedicado a ROMs

---

## Próximo passo

Testar o **Método A** (USB Mass Storage, Volume -) antes de qualquer coisa.
