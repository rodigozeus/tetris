# Restauração do Android de fábrica na eMMC do RG DS

> Sessão de **2026-09-01**. Complementa o [instala_emmc.md](instala_emmc.md) — e **corrige um erro importante** que estava lá.

## Objetivo

Instalar o **GammaOS Next** ([v1.2.2-ANBERNICRGDS](https://github.com/TheGammaSqueeze/GammaOSNext/releases/tag/v1.2.2-ANBERNICRGDS)) no RG DS, que estava rodando Rocknix na eMMC.

Descobriu-se no caminho que **restaurar o Android de fábrica não era opcional, e sim pré-requisito técnico** — os dois métodos oficiais de instalação do GammaOS dependem dele. Esta sessão cobre essa restauração.

---

## ⚠️ Correção: a ordem de boot estava documentada errada

O [instala_emmc.md:163](instala_emmc.md#L163) afirmava:

```
SPI → eMMC → SD → MaskROM   ← ERRADO
```

**O comportamento real observado é o inverso: o SD tem prioridade sobre a eMMC.**

Comprovação empírica: com um cartão inserido o aparelho não bootava de jeito nenhum (tela preta); **sem** o cartão, bootava a eMMC normalmente. Depois, com o Rocknix gravado no cartão, ele bootou pelo cartão — e o `mount` confirmou tudo vindo de `mmcblk1`:

```
/dev/mmcblk1p1 on /flash   type vfat
/dev/mmcblk1p2 on /storage type ext4
```

Essa linha errada me levou (Claude) a duas análises completamente furadas na mesma sessão — inclusive a propor zerar o `boot0` pra "forçar um fallback" que já acontecia sozinho. **Vale desconfiar de premissas herdadas antes de construir em cima delas.**

---

## Por que os métodos oficiais não funcionaram

### GammaOS — SD Card Install ❌

Grava a imagem no SD, insere, liga, e o aparelho se auto-flasheia. Resultado: **tela preta, nada acontece**.

### GammaOS — Fastboot Install ❌

O wiki instrui entrar em fastbootd via `adb reboot fastboot` — **executado de dentro do Android**. Não existe combinação de botão documentada pra entrar a frio. Com Rocknix instalado, não há Android pra rodar o comando. Beco sem saída.

### Cartão de firmware da Anbernic (`SD_Firmware_Tool`) ❌

Mesmo sintoma: tela preta. O cartão foi gerado com sucesso (`Creating upgrade disk ok.` no log) e **passou em todas as verificações possíveis** feitas do PC:

| Verificação | Resultado |
|---|---|
| Gravação completou | ✓ log confirma |
| Layout de partições | ✓ bate 1:1 com os offsets do log |
| Loader no setor 64 | ✓ magic `RKNS` |
| Código após o header | ✓ ARM64 legítimo (`fd 7b bf a9` = `stp x29, x30, [sp, #-16]!`) |
| GPT | ✓ válido |

**Hipótese não confirmada:** o `misc` do cartão continha `boot-recovery` em vez de `rk_fwupdate`. O `revision.txt` da ferramenta diz que é esse comando que dispara a atualização:

> `v1.67: when generating sd update card, add sdfwupdate cmd into misc`
> `v1.68: change sdfwupdate cmd into rk_fwupdate`

Suspeita: o gatilho só é injetado com **"Upgrade Firmware"** marcado (foi usado **"Restore"**, que pelo log faz outra coisa — `restore MBR` + `format user disk`, ou seja, restaura o **cartão**, não o aparelho). **Nunca foi testado**, porque a rota do `dd` resolveu antes. Fica registrado como pista, não como fato.

### MaskROM (Volume- + USB) ❌ — não confirmado

O [instala_emmc.md:57](instala_emmc.md#L57) registra que esse combo já funcionou (LED laranja). Nesta sessão **não produziu reação nenhuma**, mesmo testando cabos e portas diferentes, com o driver instalado.

Não achei documentação pública confiável do combo de MaskROM específico do RG DS — nem no wiki da GammaOS, nem no da Rocknix, nem em guias de terceiros. **Tratar aquele registro como duvidoso.**

Ferramentas baixadas (mirror oficial da Radxa, fonte confiável para tools Rockchip):
- `https://dl.radxa.com/tools/windows/RKDevTool_Release_v2.96_zh.zip`
- `https://dl.radxa.com/tools/windows/DriverAssitant_v5.14.zip`

---

## ✅ O método que funcionou: `dd` da imagem do cartão para a eMMC

A sacada: **um cartão de upgrade do `SD_Firmware_Tool` já contém o firmware no layout exato que a eMMC deve ter**. Então dá pra copiar esse layout direto, sem depender de nenhum mecanismo de gatilho.

E rodando **do SD**, a eMMC fica livre — a separação de dispositivos que faltou em setembro.

### Pré-condições

- Rocknix bootando **pelo cartão SD** (`mmcblk1`), com a eMMC (`mmcblk0`) **não montada** — conferir com `mount | grep mmcblk0` antes de qualquer escrita
- `boot0` zerado (era o caso; o loader do Rocknix estava no setor 64 do `mmcblk0`, não no `boot0`)

### Passo 1 — Gerar e salvar a imagem do cartão

Criar o cartão com `SD_Firmware_Tool` + `update.img`, e depois **ler o cartão de volta pro PC**. Só os primeiros **7,5 GB** importam (a partição 15 `userdata` é espaço vazio):

```powershell
# PowerShell COMO ADMINISTRADOR
$src = New-Object System.IO.FileStream("\\.\PhysicalDrive3", 'Open', 'Read', 'ReadWrite')
# ... ler 7680 MB em blocos e gravar num .img
```

Script completo em `scratchpad/salvar_imagem_sd.ps1` (7680 MB, ~2 min a 69 MB/s pelo leitor USB).

### Passo 2 — Transferir para o aparelho

```bash
gzip -1 -c imagem.img | ssh root@<IP> "gunzip -c > /storage/android.img"
```

`/storage` fica no **cartão**, não na eMMC — seguro. Verificar com `md5sum` dos dois lados antes de gravar.

### Passo 3 — Gravar na eMMC

```sh
mount | grep mmcblk0 && echo "ABORTAR: eMMC montada!"   # checagem obrigatória
dd if=/storage/android.img of=/dev/mmcblk0 bs=4M conv=fsync
sync
```

Levou 172s a 44,5 MB/s.

### Passo 4 — Reconstruir a GPT

A imagem descreve um disco de **119 GB** (era um cartão); a eMMC tem **29 GB**. As 14 primeiras partições cabem, mas a `userdata` estoura o fim do disco — e o kernel **rejeita a tabela inteira** nesse caso.

Script em `scratchpad/fix_gpt.py`. Ele ajusta e recalcula os CRC32:

| Campo | De | Para |
|---|---|---|
| `AlternateLBA` | 250347519 | 61071359 |
| `LastUsableLBA` | 250347486 | 61071326 |
| `userdata` último LBA | 250347455 | 61071326 |

Ajustar só o último LBA (em vez de deletar e recriar a partição) **preserva o nome e o type GUID** — que é o que o Android usa pra montar por `by-name`.

```sh
python3 fix_gpt.py            # simulação
python3 fix_gpt.py --apply
partprobe /dev/mmcblk0
```

**Validação:** as 15 partições apareceram em `/proc/partitions` e o `/dev/block/by-name/` foi populado. Kernel aceitando a tabela é a prova mais forte disponível.

### Passo 5 — Desligar, **tirar o cartão**, ligar

Tirar o cartão é obrigatório — ele tem prioridade de boot.

**Primeiro boot cai no recovery**, porque o `misc` contém `boot-recovery` (veio assim de dentro do `update.img`). É o estado inicial definido pelo fabricante: o recovery formata a `userdata`, que está sem sistema de arquivos.

---

## Mapa de partições do Android stock (RG DS, firmware V1.18)

Offsets em setores de 512 bytes. Extraído da GPT do cartão de upgrade.

| # | Nome | Primeiro LBA | Último LBA | Tamanho | Magic esperado |
|---|---|---|---|---|---|
| — | loader | 64 | ~470 | — | `RKNS` |
| 1 | security | 8192 | 16383 | 4 MB | `SSKR` |
| 2 | uboot | 16384 | 24575 | 4 MB | `d0 0d fe ed` (FIT) |
| 3 | trust | 24576 | 32767 | 4 MB | *(vazia, `0xFF`)* |
| 4 | misc | 32768 | 40959 | 4 MB | `boot-recovery` |
| 5 | dtbo | 40960 | 49151 | 4 MB | `d7 b7 ab 1e` |
| 6 | vbmeta | 49152 | 51199 | 1 MB | `AVB0` |
| 7 | boot | 51200 | 182271 | 64 MB | `ANDROID!` |
| 8 | recovery | 182272 | 378879 | 96 MB | `ANDROID!` |
| 9 | backup | 378880 | 1165311 | 384 MB | — |
| 10 | cache | 1165312 | 1951743 | 384 MB | — |
| 11 | metadata | 1951744 | 2082815 | 64 MB | — |
| 12 | frp | 2082816 | 2083839 | 0,5 MB | — |
| 13 | baseparameter | 2083840 | 2085887 | 1 MB | `BASP` |
| 14 | super | 2085888 | 14832639 | 6.224 MB | `gDla` em **+4096** |
| 15 | userdata | 14832640 | *(fim do disco)* | resto | — |

`type GUID` da `userdata`: `70520000-0000-4679-8000-7D5B00002FE6`

**Sobre a `trust` vazia:** preenchida com `0xFF`. A ferramenta da Anbernic **também não escreve** essa partição (confere o log dela). Nas versões recentes do U-Boot Rockchip o BL31/OP-TEE vai dentro da imagem FIT da `uboot`. É o estado normal, não uma lacuna.

**Partições com lixo residual:** `backup`, `cache`, `metadata` e `frp` não são escritas pela ferramenta — carregam restos de gravações anteriores do cartão (a `frp` chegou a ter texto legível). O Android formata essas no primeiro boot.

---

## Ferramentas: o que funciona e o que não

### No Rocknix

| Ferramenta | Status |
|---|---|
| `dd`, `parted`, `partprobe`, `blockdev`, `gzip`, `python3` | ✓ |
| **`sgdisk`** | ❌ **quebrado** — recebe lixo no lugar do argumento (`Problem opening kF for reading!`) e reporta `Disk size is 0 sectors`. Bug de parsing de argv nesse build. Todos os "problemas" que ele relata são artefato disso. |
| `parted` com GPT maior que o disco | ❌ `Invalid argument during seek`, mostra `Partition Table: unknown` |
| `lsblk`, `fdisk`, `sfdisk` | não existem (usar `/proc/partitions`) |

**`python3` é a saída** pra manipulação precisa de GPT — `zlib.crc32` dá os CRCs corretos.

### No Windows

- **Leitura de disco bruto (`\\.\PhysicalDriveN`) exige Administrador** — não só escrita, como o [instala_emmc.md:202](instala_emmc.md#L202) sugeria. Sem elevação o `FileStream` dá "Acesso negado" e o `dd` do Git Bash retorna **0 bytes silenciosamente**.
- `curl` do Git Bash falha com exit 43 em alguns hosts (github.com, sites atrás de Cloudflare) por incompatibilidade de TLS/schannel, mas funciona em outros.

### Leitura de dispositivo de bloco

`dd` em device de bloco **exige `bs` múltiplo de 512**. Com `bs=16` ou `bs=1` a leitura retorna vazio **sem erro** — parece partição em branco quando não é. Perdi tempo com um alarme falso por isso.

---

## Desempenho medido

| Operação | Taxa |
|---|---|
| Leitura do SD pelo leitor USB (PC) | 69 MB/s |
| SSH pela rede (Wi-Fi, ~45 Mbps) | 5,7 MB/s |
| SSH com `gzip -1` no meio | ~12 MB/s efetivos |
| `dd` para a eMMC | 44,5 MB/s |

A cifra do SSH **não** era o gargalo (`chacha20` deu 35,0s vs 35,3s do padrão) — era banda. Por isso comprimir compensou: a região `super` comprime pra 59%.

---

## Estado ao fim da sessão

- ✅ Android de fábrica (V1.18) gravado na eMMC, GPT válida, todas as partições com magic correto
- ✅ Recovery bootou, formatou a `userdata` e **o Android completou o setup — aparelho plenamente funcional**
- ✅ Método validado de ponta a ponta: `dd` da imagem do cartão + reconstrução da GPT **funciona**
- ✅ Rede de segurança: o cartão SD com Rocknix continua bootável
- ✅ **GammaOS instalado com sucesso** logo em seguida, pelo método fastboot — ver [instala_gammaos.md](instala_gammaos.md)

> A restauração do Android de fábrica **não era um desvio do objetivo, era o pré-requisito dele**: o método fastboot do GammaOS exige `adb reboot fastboot`, que só existe rodando de dentro do Android. E o instalador dele só substitui `boot`/`vendor`/`system`, assentando por cima do firmware de fábrica que restauramos aqui.

> Com o Android de fábrica restaurado, o **SD Card Install do GammaOS volta a ser viável** — a falha da primeira tentativa foi provavelmente ambiente errado (bootloader do Rocknix na eMMC em vez do de fábrica), não defeito da imagem nem do cartão.

### O "problema conhecido" do GammaOS foi eliminado na raiz

As release notes do GammaOS v1.2.2 avisam:

> *"If you ever used Rocknix (or another mainline distribution), this will affect your ability to restart or turn on the device. You must unplug and replug the battery to fix this issue."*

**Testado após a restauração: desligar e ligar funciona normalmente, sem precisar mexer na bateria.**

Isso confirma que o sintoma vinha do **bootloader do Rocknix residente no aparelho**, não de dano permanente — e que restaurar o firmware de fábrica por completo (loader incluído) resolve a causa em vez de contornar. Também explica retroativamente os travamentos de boot da manhã.

### Detalhe: o Android de fábrica tem vibração

O motor de vibração funciona no Android e não funcionava no Rocknix — driver presente no device tree de fábrica e nas HALs, ausente na configuração mainline. Bom indicador de que o caminho Android (GammaOS = Android 14 / LineageOS 21 sobre o mesmo stack) preserva suporte de hardware que a distro Linux deixava na mesa.

## Artefatos guardados

| Arquivo | O que é |
|---|---|
| `D:\RGDS_Android_v1.18_upgradecard.img` | Imagem de 7,5 GB do cartão de firmware — o insumo que tornou tudo isso possível |
| `scratchpad/salvar_imagem_sd.ps1` | Lê os primeiros 7,5 GB de um disco bruto no Windows |
| `scratchpad/fix_gpt.py` | Corrige GPT de imagem gravada em disco menor |
| `scratchpad/ler_setor64.ps1` | Inspeciona setores de boot (MBR, GPT, idbloader) |

## Senha do GammaOS v1.2.2

Os `.7z` do release são protegidos. Senha (pública desde 02/04/2026):

```
b2fc6ffcb76fabc91024563a0b94f83be089c60aac4aa8f1a540a11d463d6bfc
```
