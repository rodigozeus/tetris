# Backup automático do RG DS

> Quarto capítulo da série: [instala_emmc.md](instala_emmc.md) → [restaura_android_emmc.md](restaura_android_emmc.md) → [instala_gammaos.md](instala_gammaos.md) → **este**.

## ⚠️ Lembrete

**Antes de testar qualquer maluquice no console** (trocar de OS, atualizar o Rocknix, brincar com partições, etc.) — esperar um ciclo do backup rodar (até 15min) ou forçar um manualmente. É o que evita perder saves de novo.

Forçar um backup manual (do PC, via damaceno):
```bash
ssh -i C:/Users/rodig/.ssh/id_ed25519 -p 2222 rodigozeus@localhost "bash ~/scripts/backup_rgds.sh"
```

## O que existe

Desde 2026-09-22, o `/storage` do console (roms, saves, savestates, configs) é sincronizado automaticamente:

```
console RG DS  --(rsync/ssh, a cada 15min)-->  damaceno  --(rclone, diário)-->  OneDrive
```

- Só funciona com o console ligado na mesma rede local do damaceno (`192.168.68.x`).
- Console inacessível → o script pula o ciclo sem erro, tenta de novo em 15min.
- Se o console estiver desligado por muito tempo, o backup mais recente no damaceno/OneDrive é de quando ele esteve online por último — não é tempo real fora da rede de casa.

Detalhes técnicos completos (script, cron, chave SSH, decisão de sincronizar `/storage` inteiro em vez de só `roms/`+`saves/`) estão documentados no repo `infra`: [backup-rgds-console.md](../infra/backup-rgds-console.md).

## Onde ver o estado do backup

```bash
# Último log do ciclo de 15min (no damaceno)
ssh -i C:/Users/rodig/.ssh/id_ed25519 -p 2222 rodigozeus@localhost "cat ~/logs/backup-rgds-\$(date +%Y-%m-%d).log"

# O que já subiu pro OneDrive
ssh -i C:/Users/rodig/.ssh/id_ed25519 -p 2222 rodigozeus@localhost "rclone lsd onedrive:Backups/projetos/rgds-backup"
```
