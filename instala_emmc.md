# Instalação do Rocknix na eMMC interna do RG DS

> 📚 **Série de documentos sobre o RG DS:**
> 1. **`instala_emmc.md`** (este) — Rocknix na eMMC. ⚠️ Contém duas afirmações que se provaram **erradas** depois; procure pelos avisos "CORRIGIDO" e "Não reproduzido".
> 2. [restaura_android_emmc.md](restaura_android_emmc.md) — restauração do Android de fábrica via `dd` + reconstrução de GPT
> 3. [instala_gammaos.md](instala_gammaos.md) — GammaOS Next pelo método fastboot, e por que o SD Card Install não funciona neste aparelho
> 4. [backup_rgds.md](backup_rgds.md) — backup automático de roms/saves/configs (não esquecer de rodar antes de qualquer experimento no console)

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

### Método A — USB Mass Storage ❌ Não funciona no RG DS

Testado: ao segurar Volume - e conectar USB, o console entrou em **modo Loader/Maskrom** (LED laranja), mas não aparece como disco no Windows.

> ⚠️ **Não reproduzido em 2026-09-01.** Esse combo não gerou reação nenhuma (nem LED), testando cabos e portas diferentes, com o driver Rockchip instalado. Também não achei documentação pública do combo de MaskROM específico do RG DS. **Tratar este registro como duvidoso** até alguém reproduzir. Precisaria do **Rockchip DriverAssistant** + **RKDevTool** — caminho complexo, abandonado.

---

### Método B — dd via SSH ✅ CONCLUÍDO COM SUCESSO

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

**Passo 4 — Montar a partição de boot da eMMC e corrigir o extlinux.conf:**
```bash
mkdir /tmp/emmc_boot
mount /dev/mmcblk0p1 /tmp/emmc_boot
sed -i 's/rk3566-powkiddy-x55.dtb/rk3568-anbernic-rg-ds.dtb/' /tmp/emmc_boot/extlinux/extlinux.conf
umount /tmp/emmc_boot
```

> ⚠️ **Problema encontrado:** a imagem Specific vinha com o DTB errado (`rk3566-powkiddy-x55.dtb` ao invés de `rk3568-anbernic-rg-ds.dtb`). Sem essa correção o console não boota pela eMMC.

**Passo 5 — Reiniciar sem o SD card.**

> ⚠️ O Passo 2 (gravar no boot0) é importante para substituir o bootloader do Android pelo do Rocknix, garantindo que o U-Boot do Rocknix seja carregado — e ele tem fallback para SD se a eMMC falhar.

---

## Imagem disponível localmente

```
games/releases/ROCKNIX-RK3566.aarch64-20260409-Specific.img.gz
```

Usar sempre a versão **Specific** (tem suporte específico ao RG DS).

---

## Resultado

✅ **Concluído em 2026-04-11.**

- Rocknix rodando da eMMC interna (~29GB)
- Boot visivelmente mais rápido
- SD card formatado em **exFAT** dedicado exclusivamente a ROMs e saves
- Rocknix auto-monta o SD card em `/storage/` — ROMs e saves ficam acessíveis automaticamente

---

## Estrutura de armazenamento final

| Caminho | Onde fica | Filesystem |
|---------|-----------|------------|
| Sistema (Rocknix) | eMMC (`/dev/mmcblk0`) | ext4 |
| `/storage/roms/` | SD card | exFAT |
| `/storage/saves/` | SD card | exFAT |
| `/storage/.config/` | SD card | exFAT |

> O Rocknix monta o SD card diretamente em `/storage/`, sobrepondo o diretório da eMMC.

---

## Organização dos saves no PC (backup)

Saves ficam em `games/saves/` — flat, sem subpastas. O RetroArch busca por nome de arquivo.

Para copiar saves das ROMs pra pasta correta no PC:
```bash
find games/roms \( -name "*.dsv" -o -name "*.sav" -o -name "*.srm" \) -exec cp {} games/saves/ \;
```

---

## Incidente de 2026-09-01 — atualização do Rocknix (20260409 → 20260801)

Contexto: console tinha acabado de voltar de uma tentativa (fracassada, por um comprador) de restaurar o Android de fábrica. Em vez de reinstalar Android, decidiu-se só atualizar o Rocknix pra versão estável mais recente. O que deveria ser trivial (repetir o Método B com uma imagem nova) deu bastante trabalho. Registro pra não repetir os mesmos erros.

### ❌ Erro fatal: gravar a eMMC enquanto o sistema roda dela mesma

Repetimos o Método B (dd via SSH) com o Rocknix **rodando da própria eMMC** (configuração já migrada). O script de gravação mandava o log de progresso para `/storage/dd.log` — só que `/storage` é a própria partição (`mmcblk0p2`) sendo sobrescrita pelo `dd`.

Assim que o `dd` começou a passar pelos blocos ativos de `/storage` (bem cedo, já que a partição STORAGE começa por volta do setor 95936, ~2% do total), tudo que dependia do sistema de arquivos ao vivo — rede, SSH, o próprio script tentando logar — colapsou quase instantaneamente. O `dd` em si (que escreve direto no bloco bruto, sem passar pelo filesystem) provavelmente terminou a gravação dos dados normalmente, mas o `sync` final — que também dependia do script conseguir ler a próxima linha do `/storage/flash.sh`, arquivo esse também soterrado pela gravação — pode nunca ter rodado, arriscando perder os últimos bytes ainda em cache.

**Resultado:** console parou de responder (SSH morto em segundos, tela preta que não reagia a botão). Depois de ~15min sem sinal de vida, forçamos um desligamento — e a eMMC não bootou mais.

> ⚠️ **Lição: nunca escrever (nem logar) para o mesmo disco que está sendo sobrescrito por `dd`, mesmo que a escrita raw em si (`of=/dev/mmcblk0`) pareça segura por operar "abaixo" do filesystem.** Da primeira vez (instalação original) isso funcionou por sorte/timing. Não repetir.

### ✅ Recuperação: boot por SD explorando a ordem fixa do BootROM

> ⚠️ **CORRIGIDO EM 2026-09-01:** a ordem abaixo está **errada** — o **SD tem prioridade sobre a eMMC**, não o contrário. Comprovado empiricamente: com cartão inserido o aparelho não boota a eMMC, e com Rocknix no cartão o `mount` mostra tudo vindo de `mmcblk1`. Ver [restaura_android_emmc.md](restaura_android_emmc.md). Essa linha induziu a erros de diagnóstico graves.

A ordem de boot do RK3566/RK3568 é fixa e não pode ser alterada: ~~**SPI → eMMC → SD → MaskROM**~~. Com a eMMC quebrada, o BootROM deveria cair pro SD automaticamente — então em vez de mexer com MaskROM/RKDevTool (Método A, sempre complicado), bastou:

1. Gravar a mesma imagem `.img` diretamente num SD card via **Rufus** (modo "Write in DD Image mode") — usando o PC, sem nenhum risco de auto-sobrescrita.
2. Corrigir o `EXTLINUX/extlinux.conf` da partição FAT32 recém-gravada (mesmo bug do DTB, ver abaixo) diretamente pelo Windows, já que essa partição é lida nativamente.
3. Recolocar o cartão no console e ligar — bootou do SD normalmente.

Isso confirmou a eMMC morta sem precisar de ferramentas exóticas, e devolveu um sistema funcional enquanto se decidia o que fazer com a eMMC.

### 🐛 Bug recorrente: DTB errado na imagem "Specific"

Confirmado que **toda imagem "Specific" testada até agora** (20260409 e 20260801) vem com `extlinux.conf` apontando pro DTB errado:
```
FDT /device_trees/rk3566-powkiddy-x55.dtb   ← errado, vem assim de fábrica
```
O arquivo certo (`rk3568-anbernic-rg-ds.dtb`) **existe** na mesma pasta `device_trees/` — a imagem "Specific" empacota os DTBs de vários aparelhos da família (RG353, RG-ARC, Powkiddy X55/X35s/RGB*, RG DS...), só o `extlinux.conf` que vem com o valor errado por padrão. Corrigir sempre com:
```bash
sed -i 's/rk3566-powkiddy-x55.dtb/rk3568-anbernic-rg-ds.dtb/' extlinux.conf
```
Aplica-se tanto gravando na eMMC quanto num SD card de boot.

### 🌐 Rede: hotspot instável foi o maior gargalo do dia

O console estava conectado num hotspot móvel (`192.168.137.x` — faixa clássica do Windows Mobile Hotspot). Ao longo do dia:
- Múltiplas quedas de `scp` (~1.3-2.3MB/s de throughput, bem abaixo do normal) com "connection reset by peer" ou "connection timed out"
- Uma queda foi causada por fechar a tampa do notebook (suspende o Wi-Fi)
- Outra vez o notebook trocou de rede sozinho no meio da sessão, deixando PC e console em subredes diferentes sem avisar
- O console "grudou" na rede antiga mesmo depois de reiniciar e trocar a config manualmente — só resolveu reconectando o PC na rede antiga de volta

**Truque útil:** pra retomar uma transferência `scp` que caiu no meio sem reenviar tudo de novo:
```bash
# descobre quantos bytes já chegaram (ls -la no destino), e reenvia só o resto:
tail -c +$((BYTES_JA_ENVIADOS + 1)) arquivo_local | ssh host "dd of=arquivo_remoto bs=1M oflag=append conv=notrunc"
```

**Comparação de velocidade:** os mesmos ~1,3GB que levaram mais de 15 minutos (com quedas) via rede levaram **~35 segundos via leitor de cartão USB direto no PC** (quando não esbarra no problema do ext4, ver abaixo). Sempre preferir cópia física quando disponível.

### 🪟 Limitações do Windows pra manipular discos brutos

- `Set-Disk -IsOffline $true` **não funciona em mídia removível** (USB/SD) — só em discos fixos. Usar `Dismount-Volume` no lugar.
- Mesmo como Administrador, `System.IO.FileStream` do .NET abrindo `\\.\PhysicalDriveN` pra escrita direta deu **"Acesso negado"**, mesmo com o volume desmontado — o Windows protege discos com filesystem reconhecido de um jeito que só ferramentas feitas pra isso (lock de baixo nível via `FSCTL_LOCK_VOLUME`) conseguem contornar. **Solução: usar o Rufus** (portátil, `rufus.ie`) em vez de tentar reinventar isso via PowerShell.
- O Windows **não lê/escreve ext4 nativamente** — quando o cartão SD já estava com Rocknix instalado nele (partição STORAGE em ext4), não deu pra copiar arquivos grandes direto por ali via Explorer/PowerShell. Alternativas não testadas ainda: WSL (`wsl --mount`) ou Ext2Fsd.
- Robocopy invocado de dentro do Git Bash (`robocopy.exe "E:\\" ...`) recebe o path mangulado (`E:\\` vira `E:/`) e falha com "Parâmetro Inválido". **Sempre rodar robocopy via PowerShell nativo**, não pelo bash.

### 🔧 Outras pegadinhas

- **SSH desabilitado por padrão** numa instalação nova/limpa do Rocknix — precisa ativar manualmente no menu do console (Configurações → Network/Services) antes de conseguir conectar. Gastamos uns bons minutos achando que o SSH tinha travado, quando na real nunca tinha sido ligado.
- Depois de reescrever o SD card inteiro com o Rufus (imagem de sistema), a pasta de download da imagem `.img` costuma vir dentro de uma **subpasta com o mesmo nome do arquivo** (resíduo de extração de um `.zip`/`.gz`) — sempre conferir o caminho real com `ls`/`Get-ChildItem` antes de assumir que é um arquivo direto.

---

## Retorno ao Rocknix na eMMC, a partir do cartão SD ao vivo (2026-09-22)

Contexto: depois do Android/GammaOS ([restaura_android_emmc.md](restaura_android_emmc.md), [instala_gammaos.md](instala_gammaos.md)), o console tinha voltado a rodar Rocknix **do cartão SD** (fallback de boot), com configs/saves/roms já bem estabelecidos ali (versão `ROCKNIX 20260901`). Objetivo: levar esse estado **exatamente como estava** de volta pra eMMC, sem passar por reconfiguração do zero.

### A sacada: eMMC como disco "de bloco" comum, sem precisar reiniciar

Como o SD tem prioridade de boot ([confirmado em restaura_android_emmc.md](restaura_android_emmc.md)), dava pra ter o Rocknix rodando do SD (`mmcblk1`) com a eMMC (`mmcblk0`) livre, desmontada, só esperando ser escrita — sem nenhum dos riscos do incidente de setembro (ver acima), porque a eMMC **não é** o disco em uso.

### Passos

1. **Molde de partições/bootloader**: gravar a imagem "Specific" antiga (a mesma disponível localmente, `20260409`) na eMMC via Método B (idbloader no `boot0` + `dd of=/dev/mmcblk0` da imagem inteira ~2GB). Isso cria a tabela MBR com as partições `ROCKNIX` (FAT32) e `STORAGE` (ext4), mas com a versão/conteúdo antigos — só serve de esqueleto.

   > ⚠️ `status=progress` **não existe** no `dd` do busybox — falha com `invalid argument` e não escreve nada. Confirmar com `cat /proc/partitions` que nada mudou antes de repetir sem essa flag.

2. **Redimensionar `STORAGE`** pra ocupar o resto da eMMC (a imagem base só declara uma partição pequena, ~32MB — o resto do disco fica livre até esse passo):
   ```sh
   parted -s /dev/mmcblk0 resizepart 2 100%
   partprobe /dev/mmcblk0
   e2fsck -f -y /dev/mmcblk0p2
   resize2fs /dev/mmcblk0p2
   ```

3. **Sobrescrever `ROCKNIX`** (kernel/SYSTEM/device_trees/extlinux) com os arquivos **atuais** do `/flash` (montado a partir do SD), não com os da imagem baixada — isso garante que a eMMC fique com a mesma versão que estava rodando, não com uma mais antiga:
   ```sh
   mount /dev/mmcblk0p1 /tmp/emmc_rocknix
   rm -f /tmp/emmc_rocknix/SYSTEM /tmp/emmc_rocknix/SYSTEM.md5   # ver pegadinha abaixo
   rsync -a --delete /flash/ /tmp/emmc_rocknix/
   ```
   > ⚠️ **Pegadinha de espaço:** `rsync` (sem `--inplace`) escreve o arquivo novo num temporário antes de substituir o antigo — com o `SYSTEM` antigo (1,7GB) e o novo (1,36GB) coexistindo, a partição de 2GB não teve espaço e o rsync falhou em "No space left on device". Apagar o `SYSTEM` antigo manualmente antes resolve.

4. **Copiar `/storage`** (configs, saves, roms) pra dentro da `STORAGE` nova da eMMC:
   ```sh
   mount /dev/mmcblk0p2 /tmp/emmc_storage
   rsync -a /storage/ /tmp/emmc_storage/
   ```
   > Nota: `/storage/roms` aparece montado *de novo* em cima de `/storage` (`mount | grep mmcblk` mostra as duas linhas). Investigado e é inofensivo — não é uma segunda árvore recursiva (`ls /storage/roms/roms` não existe), então o `rsync` não duplica nada por causa disso.

5. Desmontar, `sync`, desligar, **tirar o cartão SD**, ligar — bootou direto na eMMC, mesma versão (`20260901`), mesmo IP de rede, `df -h /storage` confirmando as mesmas ROMs e configs.

### Por que essa abordagem em vez de clonar o SD inteiro com `dd`

O SD tinha ~119GB e a eMMC só ~29GB — um `dd` disco-a-disco (como o usado pro Android em [restaura_android_emmc.md](restaura_android_emmc.md)) teria truncado o filesystem `STORAGE` no meio, corrompendo dados reais (diferente do caso do Android, onde a partição que sobrava era só espaço vazio). A saída foi trabalhar em nível de partição/arquivo: usar uma imagem pequena como molde de bootloader+tabela, redimensionar a partição de destino, e copiar o conteúdo real via `rsync` (que naturalmente ignora o quanto o disco de origem é maior, já que só copia os dados que existem).

### Resultado

✅ Rocknix `20260901` rodando da eMMC interna, configs/saves/roms idênticos aos que estavam no cartão, cartão SD livre. Ver [backup_rgds.md](backup_rgds.md) pro backup automático montado na sequência.
