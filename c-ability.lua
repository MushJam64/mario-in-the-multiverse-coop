local sCollectAbilityHitbox = {
    interactType = INTERACT_STAR_OR_KEY,
    downOffset = 0,
    damageOrCoinValue = 0,
    health = 0,
    numLootCoins = 0,
    radius = 80,
    height = 80,
    hurtboxRadius = 0,
    hurtboxHeight = 0,
}

UNLOCK_ABILITIES_DEBUG = false

function bhv_ability(o)
    if o.oAction == 0 then
        --[[   if save_file_check_ability_unlocked(o.oBehParams2ndByte) then
            -- When debugging, you should always be able to test ability collection
            if UNLOCK_ABILITIES_DEBUG then
                o.oAction = 1
                obj_set_hitbox(o, sCollectAbilityHitbox)
            else
                cur_obj_hide()
                o.oAction = 2
            end
        else]]
        o.oAction = 1
        obj_set_hitbox(o, sCollectAbilityHitbox)
        -- end
    elseif o.oAction == 1 then
        if obj_check_hitbox_overlap(o, gMarioStates[0].marioObj) then
            --save_file_unlock_song(SEQ_MITM_GET_ABILITY)

            cur_obj_hide()
            for i = 0, 3 do
                if ability_slot[i] == ABILITY_NONE then
                    ability_slot[i] = o.oBehParams2ndByte
                    break
                end
            end
            if o.oBehParams2ndByte ~= ABILITY_MARBLE then -- hamsterball is a weird one
                change_ability(o.oBehParams2ndByte)
            end
            --save_file_set_ability_dpad()
            o.oAction = 2
        end
    end
end

---@param m MarioState
local function ability_functions_update(m)
    local f = gPlayerSyncTable[m.playerIndex]
    if m.playerIndex == 0 then
        if m.action == ACT_PUNCHING or m.action == ACT_MOVE_PUNCHING or m.action == ACT_JUMP_KICK then
            if f.abilityId == ABILITY_CUTTER then
               if (m.actionTimer == 1) then
                    spawn_object_relative2(0, 0, 100, 0, m.marioObj, MODEL_CUTTER_BLADE, bhvCutterBlade);
                    
                end
            end
        end
    end
end

hook_event(HOOK_OBJECT_SET_MODEL, function(o)
    if obj_has_behavior_id(o, id_bhvMario) ~= 0 then
        local i = network_local_index_from_global(o.globalPlayerIndex)
        if gPlayerSyncTable[i].modelId ~= nil and obj_has_model_extended(o, gPlayerSyncTable[i].modelId) == 0 then
            obj_set_model_extended(o, gPlayerSyncTable[i].modelId)
        end
    end
end)

hook_event(HOOK_MARIO_UPDATE, ability_functions_update)
