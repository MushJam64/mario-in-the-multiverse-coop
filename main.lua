-- name: Mario In The Multiverse
-- description: this is, elon musk
-- incompatible: romhack

gLevelValues.entryLevel = LEVEL_BOB
gLevelValues.disableActs = true

smlua_audio_utils_replace_sequence(0x25, 42, 80, "25_custom_peanut_plains")