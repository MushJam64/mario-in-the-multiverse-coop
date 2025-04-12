-- name: [WIP] \\#0865de\\Mario \\#ffffff\\In The \\#3b348a\\Multiverse
-- description: this is, elon musk \n\nPorted By:\n\\#00ff00\\I'mYourCat\\#FF0000\\2 (Creator)\n\\#dcdcdc\\x\\#00FF00\\Luigi\\#434343\\Gamer\\#dcdcdc\\x (Programmer)\n\\#FFC0CB\\MaiskX3 (Music Porter, Tester)\n\\#105009\\Emeraldsniper (Tester)\n\\#FF004C\\CitraDreamPainter (Tester)
-- incompatible: romhack

gLevelValues.entryLevel = LEVEL_CASTLE --LEVEL CASTLE and bob if no stars
gLevelValues.disableActs = true

smlua_audio_utils_replace_sequence(0x25, 19, 80, "25_custom_peanut_plains") --OG BANK EXTENDED (42)
smlua_audio_utils_replace_sequence(SEQ_CUSTOM_KIRBY_BOSS, 19, 80, "26_custom_kirby_boss") --OG BANK EXTENDED (42)
smlua_audio_utils_replace_sequence(0x4e, 42, 80, "4E_mitm_hub")
smlua_audio_utils_replace_sequence(0x27, 42, 80, "27_custom_save_hut")

