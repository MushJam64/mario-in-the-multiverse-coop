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

UNLOCK_ABILITIES_DEBUG = true

function bhv_ability_init(o)
    o.oBehParams = (12 << 24) | (o.oBehParams2ndByte << 16)
    network_init_object(o, true, { "oAction", "oBehParams2ndByte" })
end

function bhv_ability(o)
    if o.oAction == 0 then
        if save_file_check_ability_unlocked(o.oBehParams2ndByte) then
            -- When debugging, you should always be able to test ability collection
            if UNLOCK_ABILITIES_DEBUG then
                o.oAction = 1
                obj_set_hitbox(o, sCollectAbilityHitbox)
            else
                cur_obj_hide()
                o.oAction = 2
            end
        else
            o.oAction = 1
            obj_set_hitbox(o, sCollectAbilityHitbox)
        end
    elseif o.oAction == 1 then
        if obj_check_hitbox_overlap(o, nearest_player_to_object(o)) then
            --save_file_unlock_song(SEQ_MITM_GET_ABILITY)

            cur_obj_hide()
            if nearest_mario_state_to_object(o).playerIndex == 0 then
                display_ability_hud.display = true
                display_ability_hud.str = ability_struct[o.oBehParams2ndByte].string
            end
            for i = 0, 3 do
                if ability_slot[i] == ABILITY_NONE then
                    ability_slot[i] = o.oBehParams2ndByte
                    if i == 0 then
                        gGlobalSyncTable.ability_slot0 = o.oBehParams2ndByte
                    elseif i == 1 then
                        gGlobalSyncTable.ability_slot1 = o.oBehParams2ndByte
                    elseif i == 2 then
                        gGlobalSyncTable.ability_slot2 = o.oBehParams2ndByte
                    elseif i == 3 then
                        gGlobalSyncTable.ability_slot3 = o.oBehParams2ndByte
                    end
                    break
                end
            end
            --gGlobalSyncTable.ability_slot0 = o.oBehParams2ndByte
            if o.oBehParams2ndByte ~= ABILITY_MARBLE then -- hamsterball is a weird one
                change_ability(o.oBehParams2ndByte)
            end
            if network_is_server() then
                save_file_set_ability_dpad()
            end
            o.oAction = 2
        end
    end
end

local function save_abilities()
    local currSave = get_current_save_file_num() - 1
    --reduce stress
    if get_global_timer() % 32 ~= 0 then return end
    ability_slot[0] = gGlobalSyncTable.ability_slot0
    ability_slot[1] = gGlobalSyncTable.ability_slot1
    ability_slot[2] = gGlobalSyncTable.ability_slot2
    ability_slot[3] = gGlobalSyncTable.ability_slot3
    if network_is_server() then
        save_file_set_ability_dpad()
        mod_storage_save_number("abilities" .. (currSave), gGlobalSyncTable.abilities)
    end
end

hook_event(HOOK_UPDATE, save_abilities)

local function control_ability_dpad(m)
    if m.playerIndex ~= 0 then return end
    local gPlayer1Controller = m.controller
    local picked_ability = -1

    if (gPlayer1Controller.buttonPressed & U_JPAD) ~= 0 then
        picked_ability = 0
    end
    if (gPlayer1Controller.buttonPressed & R_JPAD) ~= 0 then
        picked_ability = 1
    end
    if (gPlayer1Controller.buttonPressed & D_JPAD) ~= 0 then
        picked_ability = 2
    end
    if (gPlayer1Controller.buttonPressed & L_JPAD) ~= 0 then
        picked_ability = 3
    end
    if (m.action & ACT_GROUP_MASK) ~= ACT_GROUP_CUTSCENE then
        if picked_ability > -1 then
            --if check_if_swap_ability_allowed() then
            -- Animate image on DPad HUD
            ability_y_offset[picked_ability] = 5
            ability_gravity[picked_ability] = 2

            change_ability(ability_slot[picked_ability])

            -- Equip Sound Effect
            if ability_slot[picked_ability] == ABILITY_AKU then
                -- play_sound(SOUND_ABILITY_AKU_AKU, gGlobalSoundSource)
            elseif ability_slot[picked_ability] == ABILITY_KNIGHT then
                -- play_sound(SOUND_ABILITY_KNIGHT_EQUIP, gGlobalSoundSource)
            elseif ability_slot[picked_ability] == ABILITY_E_SHOTGUN then
                --  play_sound(SOUND_MITM_ABILITY_E_SHOTGUN_RACK, gGlobalSoundSource)
            elseif ability_slot[picked_ability] == ABILITY_NONE then
                -- Do nothing
            else
                play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
            end
            --[[ else
                play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)
            end]]
        end
    end
end

hook_event(HOOK_MARIO_UPDATE, control_ability_dpad)

local thrownCutter = false

---@param m MarioState
local function ability_functions_update(m)
    local f = gPlayerSyncTable[m.playerIndex]
    if m.playerIndex == 0 then
        if m.action == ACT_PUNCHING or m.action == ACT_MOVE_PUNCHING or m.action == ACT_JUMP_KICK then
            if f.abilityId == ABILITY_CUTTER and not thrownCutter then
                spawn_object_relative(0, 0, 100, 0, m.marioObj, MODEL_CUTTER_BLADE, bhvCutterBlade);
                thrownCutter = true
            end
        else
            thrownCutter = false
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

local function interact_ability_star(m, obj, t)
    if obj_has_behavior_id(obj, bhvAbilityUnlock) ~= 0 then
        -- ability

        save_file_unlock_ability(obj.oBehParams2ndByte)

        --starGrabAction = ACT_ABILITY_DANCE
        if (m.action & ACT_FLAG_AIR) ~= 0 then
            --starGrabAction = ACT_FALL_AFTER_STAR_GRAB
            -- m.actionArg = 2
        end
        --ability_get_confirm = false
        --[[elseif obj_has_behavior_id(obj, bhvCollectablePainting) ~= 0 then
        painting unlock
        local slot = gCurrSaveFileNum - 1
        local paintingByte = obj.oBehParams2ndByte
        gSaveBuffer.files[slot][1].paintings_unlocked =
            gSaveBuffer.files[slot][1].paintings_unlocked | (1 << paintingByte)
        gSaveFileModified = true]]
    else
        --[[ if not level_in_dream_comet_mode() then
            -- power star
            p_rank_stars = p_rank_stars + 1
            save_file_collect_star_or_key(m.numCoins, starIndex)
            m.numStars = save_file_get_total_star_count(gCurrSaveFileNum - 1, COURSE_MIN - 1, COURSE_MAX - 1)
            ability_get_confirm = true
        else
            -- dream catalyst
            set_dream_star(obj.oBehParams2ndByte)
            m.numDreamCatalysts = get_dream_star_count()
        end]]
    end
end

local function celeb_star_override(o)
    obj_set_model_extended(o, MODEL_ABILITY)
    o.oBehParams2ndByte = nearest_mario_state_to_object(o).usedObj.oBehParams2ndByte
end

hook_behavior(id_bhvCelebrationStar, OBJ_LIST_DEFAULT, false, nil, celeb_star_override)

hook_event(HOOK_ON_INTERACT, interact_ability_star)
hook_event(HOOK_MARIO_UPDATE, ability_functions_update)
