# Instalação do GammaOS Next no RG DS

> Sessão de **2026-09-01**. Terceiro capítulo, depois de [instala_emmc.md](instala_emmc.md) (Rocknix) e [restaura_android_emmc.md](restaura_android_emmc.md) (Android de fábrica).

## Resultado

✅ **GammaOS Next Lite v1.2.2 rodando**, instalado pelo **método Fastboot**.

O método SD Card Install — que a documentação oficial chama de "preferred" — **não funciona neste aparelho**. Detalhes abaixo.

---

## ⚠️ O SD Card Install não funciona no RG DS

Sintoma: com o cartão inserido, **nenhum sinal de vida**. Nem o logo da Anbernic (que sem cartão aparece em 3 segundos), nem LED, nada.

Foi testado exaustivamente e **descartado** como problema nosso:

| Verificação | Resultado |
|---|---|
| SHA256 das 3 partes `.7z` | ✓ batem com os hashes oficiais do release |
| MBR da imagem vs. do cartão gravado | ✓ idênticos (tipo `0x07`, LBA 387072, 7.265 MB) |
| Loader no setor 64 | ✓ `RKNS` |
| `rksdfw.tag` (arquivo-gatilho) | ✓ presente |
| `sd_boot_config.config` | ✓ **`fw_update = 1`** |
| `sdupdate.img` | ✓ 5.746.190.922 bytes |
| Cartão SDXC 119 GB | ❌ tela preta |
| Cartão SDHC 32 GB | ❌ tela preta |
| Ambiente com bootloader de fábrica | ❌ tela preta |

### A observação que fechou o diagnóstico

**Sem cartão, o logo aparece em 3 s. Com cartão, nunca aparece.** Como o logo é desenhado pelo loader, a travada acontece **antes** dele — no estágio BootROM/TPL. E prova que o **SD é lido antes da eMMC** (se a eMMC tivesse prioridade, um cartão ruim seria irrelevante).

### O detalhe que elimina as explicações fáceis

O loader do cartão e o loader da eMMC são **os mesmos bytes** (comparado o setor 68 das duas imagens — idênticos, `01 00 00 14 e0 13 bf a9 fd 7b bf a9…`, que é `stp x29, x30, [sp, #-16]!` em ARM64). A imagem do GammaOS reusa o loader de fábrica da Anbernic.

Ou seja: **o mesmo código funciona rodando da eMMC e trava rodando do SD.**

Não é a imagem, não é a gravação, não é o cartão, não é resíduo do Rocknix, não é capacidade. É o caminho de boot-por-SD do loader de fábrica que não funciona nesta unidade. **Sem console serial (`ttyS2` a 1500000 baud) não dá pra ir além disso** — é onde a investigação por eliminação se esgota.

> Vale abrir issue no repositório do GammaOS. O wiki deles pede exatamente isso, e os dados acima são um relatório bem mais completo que a média.

---

## ✅ Método Fastboot — o que funcionou

### Pré-requisito: Android de fábrica funcionando

O `adb reboot fastboot` só existe rodando de dentro do Android. Com Rocknix instalado, esse caminho é **impossível** — foi por isso que a restauração do firmware de fábrica ([restaura_android_emmc.md](restaura_android_emmc.md)) deixou de ser opcional.

### O que o script realmente faz

Lendo o `FlashPartitions.bat`, ele **só substitui três partições**:

```
flash boot     ← boot_custom.img    (64 MB)
flash vendor   ← vendor_custom.img  (352 MB)
flash system   ← system_custom.img  (3.386 MB no Lite)
```

Antes disso, remove partições lógicas (`system_ext`, `product` e as `-cow`, variantes `_a`/`_b`).

**Não toca** em bootloader, `dtbo`, `vbmeta`, `trust`, `misc` nem na GPT. Ele foi desenhado pra assentar **por cima do firmware de fábrica** — o que confirma que restaurar o stock não foi burocracia, foi a fundação que o instalador assume existir.

### Preflight (com `adb`, antes de reiniciar)

```sh
adb shell getprop ro.boot.flash.locked        # 0 = destravado, pode gravar
adb shell getprop ro.boot.verifiedbootstate   # orange = não-verificado
adb shell getprop ro.build.type               # userdebug
adb shell getprop ro.boot.slot_suffix         # vazio = aparelho SEM A/B
```

### Sequência

1. Extrair o pacote FASTBOOT (senha abaixo). São **8,7 GB descompactados** — não cabe no `C:` deste PC, usar o `D:`.
2. Ativar **Depuração USB** no Android e autorizar o PC.
3. Rodar `FlashPartitions.bat` — ele detecta o device, pede confirmação e faz o `adb reboot fastboot` sozinho.
4. Rodar `EraseUserData.bat` (obrigatório em instalação limpa vinda do stock).
5. Ligar **sem cartão SD**.

Tempo de gravação do `system`: **~130 s** (14 partes sparse).

---

## 🔌 A saga dos drivers USB

Esta foi a parte mais custosa, e nada disso está na documentação oficial.

### O aparelho tem TRÊS identidades USB diferentes

| Modo | ID USB | Driver que funciona |
|---|---|---|
| Android (adb) | `VID_2207&PID_0006` | Rockchip **DriverAssistant** (`ADBDriver/android_winusb.inf`) |
| fastbootd | `VID_18D1&PID_D001` | **Google USB Driver** |
| bootloader fastboot | `VID_18D1&PID_4EE0` | **Google USB Driver** (`Android Bootloader Interface`) |

`VID_2207` é Rockchip; `VID_18D1` é Google. O ID **muda conforme o modo**, e cada um precisa do seu driver — por isso "o adb funciona mas o fastboot não vê nada" é o estado normal no meio do caminho, não um defeito.

### ❌ Os drivers que vêm no pacote oficial não servem

O wiki do GammaOS manda instalar os `UnisocDrivers` incluídos no pacote (`DPInst64.exe`). Eles cobrem `VID_0525`, `VID_1782` e alguns PIDs de celular da `VID_18D1` — **nenhum dos três IDs do RG DS**. Quem seguir a instrução oficial ao pé da letra trava exatamente aqui, sem mensagem de erro útil.

### Os drivers que funcionam

| Driver | Origem | Cobre |
|---|---|---|
| Google USB Driver | `https://dl.google.com/android/repository/usb_driver_r13-windows.zip` | `18D1/4EE0` e `18D1/D001` |
| Rockchip DriverAssistant v5.14 | `https://dl.radxa.com/tools/windows/DriverAssitant_v5.14.zip` | `2207/0006` (adb) |

Ambos assinados (`.cat` presente). Instalar por **Gerenciador de Dispositivos → Atualizar driver → apontar para a pasta** (o `pnputil` às vezes ignora dispositivos que já têm algum driver ligado).

### 🔁 Replug obrigatório depois de instalar o driver

Sintoma: driver instalado, `Status = OK`, `DriverDesc = Android Bootloader Interface`, `DeviceInterfaceGUIDs = {F72FE0D4-CBCB-407d-8814-9ED673D0DD6B}` — **e mesmo assim `fastboot devices` vazio**.

Causa: o `fastboot` enumera pelo **GUID de interface do Android**, e essa interface só é publicada quando o driver carrega. Se o dispositivo já estava enumerado quando o driver foi instalado, o `SymbolicName` fica registrado só com o GUID genérico de USB.

**Desconectar e reconectar o cabo resolve.** Foi o passo que destravou a detecção.

---

## 🐛 `semaphore timeout` — controladora USB 3.x da AMD

Com o dispositivo já detectado (`fastboot devices` listando), toda transferência falhava:

```
FAILED (AdbWriteEndpointSync failed: O tempo limite do semáforo expirou. (121))
Finished. Total time: 5.011s
```

Consistente, sempre em exatos 5 s. A controladora era:

```
USB Root Hub (USB 3.0)
AMD USB 3.10 eXtensible Host Controller
```

**Fastboot + USB 3.x da AMD é incompatibilidade conhecida.** A *detecção* passa pelo driver e funciona; a *transferência* passa pela controladora e quebra.

**Solução: trocar para uma porta USB 2.0** (as pretas). Se todas forem 3.x, um hub USB 2.0 no meio força negociação em high-speed e contorna.

---

## 🔧 Correções necessárias nos scripts

Os `.bat` do pacote usam `adb`/`fastboot` sem caminho e imagens em caminho relativo (`flash/boot_custom.img`). Ao rodar **como Administrador**, o Windows define o diretório de trabalho como `C:\Windows\System32` e **nada é encontrado** — o script fica em loop de "No ADB or Fastboot device detected".

Correção aplicada nos dois scripts:

```bat
@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"        <- adicionado
```

E copiar `adb.exe`, `fastboot.exe`, `AdbWinApi.dll` e `AdbWinUsbApi.dll` para a pasta do script (o `cmd` procura no diretório atual antes do PATH).

> Não precisa de Administrador. `adb` e `fastboot` rodam como usuário comum — elevar só cria o problema acima.

### Erros do `EraseUserData.bat` que são normais

```
Erasing 'metadata'   FAILED (remote: 'Partition doesn't exist')
                     FAILED (remote: 'Could not open partition')
```

Esperado — o próprio script avisa "Ignore any errors". A `metadata` existe na eMMC (`mmcblk0p11`), só não fica exposta com esse nome nesse modo. O passo que importa é o `fastboot -w` no final.

---

## 📦 Versões disponíveis

| Versão | Data | Senha | Pacotes |
|---|---|---|---|
| **v1.4.1** *(latest)* | 13/08/2026 | ❌ só Patreon | Core / Core NO_OC_UV / Full / Full NO_OC_UV |
| v1.4.0 | 29/07/2026 | ❌ só Patreon | Nano |
| **v1.2.2** ← instalada | 01/02/2026 | ✅ pública | SDCARDINSTALL + **FASTBOOT** |

**Senha da v1.2.2** (pública desde 02/04/2026):
```
b2fc6ffcb76fabc91024563a0b94f83be089c60aac4aa8f1a540a11d463d6bfc
```

### Sobre migrar para a v1.4.x

A v1.4 ("GammaOS Nano") não é update incremental — é um micro-OS que boota no tema **DSi System Menu** nas duas telas, com Control Center na tela de baixo, DraStic otimizado com RetroAchievements e sem overhead de launcher Android.

**Dois obstáculos:**
1. A senha dos `.7z` é exclusiva do Patreon (tier "GammaOS Insider") até liberação pública.
2. **Não existe asset `_FASTBOOT` na v1.4.x** — só imagem. Como o SD Card Install não funciona neste aparelho, a v1.4.x seria **ininstalável** por aqui a menos que eles publiquem um pacote fastboot.

A v1.2.2 é a única que traz pacote fastboot, e por isso é a única viável nesta unidade hoje.

---

## Artefatos

| Caminho | O que é |
|---|---|
| `D:\GammaOS_Fastboot\RG_DS_GammaOS_Lite_v1.2.2_FASTBOOT\` | pacote extraído, com os `.bat` já corrigidos |
| `C:\Users\rodig\Downloads\usb_driver\` | Google USB Driver (fastboot/fastbootd) |
| `C:\Users\rodig\Downloads\DriverAssistant_v5.14\` | Rockchip DriverAssistant (adb) |
| `C:\Users\rodig\Downloads\platform-tools\` | `adb` / `fastboot` oficiais |
| `D:\RGDS_Android_v1.18_upgradecard.img` | imagem do Android de fábrica — **o caminho de volta** |

> Guardar essa última. Ela é o que torna qualquer experimento futuro reversível: restaurar o stock virou rotina de ~20 min ([restaura_android_emmc.md](restaura_android_emmc.md)).

---

## Lição transversal do dia

Três métodos falharam com **tela preta e nenhuma mensagem**, e cada um consumiu horas de hipóteses que morreram uma a uma (`SDBoot.bin` ausente, Rufus gravando errado, cartão SDXC grande demais, ordem de boot invertida — todas descartadas por evidência).

O fastboot resolveu em uma fração do tempo não por ser tecnicamente superior, mas porque **falha com mensagem**: `Partition doesn't exist`, `semaphore timeout (121)`, `No ADB device detected`. Cada erro apontou o próximo passo.

**Quando houver dois caminhos, preferir o que reporta erro ao que falha em silêncio** — mesmo que o silencioso seja o "oficialmente recomendado".
