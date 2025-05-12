-- name: [WIP] \\#0865de\\Mario \\#ffffff\\In The \\#3b348a\\Multiverse
-- description: this is, elon musk \n\nPorted By:\n\\#00ff00\\I'mYourCat\\#FF0000\\2 (Creator)\n\\#dcdcdc\\x\\#00FF00\\Luigi\\#434343\\Gamer\\#dcdcdc\\x (Programmer)\n\\#FFC0CB\\MaiskX3 (Music Porter, Tester)\n\\#105009\\Emeraldsniper (Tester)\n\\#FF004C\\CitraDreamPainter (Tester)
-- incompatible: romhack

gLevelValues.entryLevel = LEVEL_CASTLE --LEVEL CASTLE and bob if no stars
gLevelValues.disableActs = true

smlua_audio_utils_replace_sequence(0x25, 42, 80, "25_custom_peanut_plains")               --OG BANK EXTENDED (42)
smlua_audio_utils_replace_sequence(SEQ_CUSTOM_KIRBY_BOSS, 42, 80, "26_custom_kirby_boss") --OG BANK EXTENDED (42)
smlua_audio_utils_replace_sequence(0x4e, 42, 80, "4E_mitm_hub")
smlua_audio_utils_replace_sequence(0x27, 42, 80, "27_custom_save_hut")

local levelInited

local function level_init()
    levelInited = true
end

local function spawn_point(m)
    if levelInited and m.playerIndex == 0 and save_file_check_ability_unlocked(ABILITY_CUTTER) then
        if gNetworkPlayers[0].currLevelNum == LEVEL_BOB and
            gNetworkPlayers[0].currAreaIndex == 1 then
            warp_to_level(LEVEL_CASTLE, 1, 1)
        end
    end
end

hook_event(HOOK_MARIO_UPDATE, spawn_point)
hook_event(HOOK_ON_LEVEL_INIT, level_init)
