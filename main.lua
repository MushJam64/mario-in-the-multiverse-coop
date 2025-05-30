-- name: \\#0865de\\Mario \\#ffffff\\In The \\#3b348a\\Multiverse
-- description: \\#0865de\\Mario \\#ffffff\\In The \\#3b348a\\Multiverse\\#ffffff\\ is a Collaborative Major Hack brought to you by an all-star team of ROMhackers, each representing a given series through a unique level and ability to make this a journey like no other.\n\nPorted By:\n\\#00ff00\\I'mYourCat\\#FF0000\\2 (Creator)\n\\#dcdcdc\\x\\#00FF00\\Luigi\\#434343\\Gamer\\#dcdcdc\\x (Programmer)\n\\#FFC0CB\\MaiskX3 (Music Porter, Tester)\n\\#105009\\Emeraldsniper (Tester)\n\\#FF004C\\CitraDreamPainter (Tester)\n\\#00FFFF\\WBmarioo (Tester)
-- incompatible: romhack
if save_file_check_ability_unlocked(ABILITY_CUTTER) then
    gLevelValues.entryLevel = LEVEL_CASTLE
else
    gLevelValues.entryLevel = LEVEL_BOB
end
gLevelValues.disableActs = true
gLevelValues.fixCollisionBugs = true
gLevelValues.fixCollisionBugsPickBestWall = true
gBehaviorValues.ShowStarMilestones = false
gBehaviorValues.ShowStarDialog = false
gServerSettings.skipIntro = true
gServerSettings.stayInLevelAfterStar = 1
gLevelValues.exitCastleWarpNode = 1

smlua_audio_utils_replace_sequence(0x25, 42, 80, "25_custom_peanut_plains")
smlua_audio_utils_replace_sequence(0x27, 42, 80, "27_custom_save_hut")
smlua_audio_utils_replace_sequence(0x28, 42, 80, "28_custom_crystal_field")
smlua_audio_utils_replace_sequence(SEQ_CUSTOM_KIRBY_BOSS, 42, 80, "26_custom_kirby_boss")
smlua_audio_utils_replace_sequence(0x39, 19, 80, "39_jellyfish_fields")
smlua_audio_utils_replace_sequence(0x3A, 19, 80, "3A_jellyfish_secret")
smlua_audio_utils_replace_sequence(0x4a, 42, 80, "4A_downtown_bb")
smlua_audio_utils_replace_sequence(0x4b, 19, 80, "4B_c_sea_me_now")
smlua_audio_utils_replace_sequence(0x4e, 42, 80, "4E_mitm_hub")
smlua_audio_utils_replace_sequence(0x50, 42, 80, "50_mitm_ability_get")

local function mario_update(m)
    if m.playerIndex == 0 then
        if (gPlayerSyncTable[0].abilityId == ABILITY_CUTTER) or using_ability(m, ABILITY_GADGET_WATCH) then
            m.marioBodyState.capState = m.marioBodyState.capState | MARIO_HAS_DEFAULT_CAP_OFF
        end
        if m.action == ACT_TWIRLING and (m.controller.buttonDown & Z_TRIG) ~= 0 then
            m.vel.y = m.vel.y + -15
            gPlayerSyncTable[0].rotAngle = gPlayerSyncTable[0].rotAngle + 8500
            m.marioObj.header.gfx.angle.y = gPlayerSyncTable[0].rotAngle
        end

        m.peakHeight = m.pos.y
        m.numLives = 99
    end
end
hook_event(HOOK_MARIO_UPDATE, mario_update)
