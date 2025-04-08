-- name: [WIP] \\#0865de\\Mario \\#ffffff\\In The \\#3b348a\\Multiverse
-- description: this is, elon musk
-- incompatible: romhack

gLevelValues.entryLevel = LEVEL_CASTLE --LEVEL CASTLE and bob if no stars
gLevelValues.disableActs = true

smlua_audio_utils_replace_sequence(0x25, 19, 80, "25_custom_peanut_plains") --OG BANK EXTENDED (42)
smlua_audio_utils_replace_sequence(0x4e, 42, 80, "4E_mitm_hub")
smlua_audio_utils_replace_sequence(0x27, 42, 80, "27_custom_save_hut")

