#!/bin/bash
CFG=/storage/.config/drastic/config/drastic.cfg

sed -i 's/^screen_swap = .*/screen_swap = 1/' "$CFG"
sed -i 's/^mirror_touch = .*/mirror_touch = 1/' "$CFG"

pactl set-default-source alsa_input._sys_devices_platform_sound_sound_card0.HiFi__Mic__source
export SDL_AUDIODRIVER=pulse

/usr/bin/start_drastic.sh "/storage/roms/nds/Zelda_PH_PTBR_Dpad_Final.nds"

sed -i 's/^screen_swap = .*/screen_swap = 0/' "$CFG"
sed -i 's/^mirror_touch = .*/mirror_touch = 0/' "$CFG"
