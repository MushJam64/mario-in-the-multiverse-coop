-- Custom Behaviors --

MODEL_LEVEL_PIPE = smlua_model_util_get_id("level_pipe_geo") -- Extended because it can be used anywhere i think

-- utils

---@param parent Object
---@param modelId ModelExtendedId
---@param behaviorId BehaviorId
---@return Object
function spawn_object(parent, modelId, behaviorId)
    local obj = spawn_non_sync_object(behaviorId, modelId, 0, 0, 0, nil)
    if not obj then return nil end

    obj_copy_pos_and_angle(obj, parent)
    return obj
end

---@param parent Object
---@param modelId ModelExtendedId
---@param behaviorId BehaviorId
---@return Object
function spawn_object2(parent, modelId, behaviorId)
    local obj = spawn_sync_object(behaviorId, modelId, 0, 0, 0, nil)
    if not obj then return nil end

    obj_copy_pos_and_angle(obj, parent)
    return obj
end

---@param o Object
function level_pipe_init(o)
    queued_pipe_cutscene = false
    o.oUnk94 = random_u16() -- oUnk94 is used for the geo asm timer
    if (gNetworkPlayers[0].currLevelNum ~= LEVEL_CASTLE) then
        o.oOpacity = 250
        return
    end

    o.oOpacity = 0

    if (levels_unlocked & (1 << o.oBehParams2ndByte) ~= 0) then
        o.oOpacity = 250
    end
end

local function level_pipe_in_level_loop(o, m)
    if o.oAction == 0 then
        if (lateral_dist_between_objects(o, m.marioObj) < 120) and (m.pos.y < o.oPosY + 500) and (m.pos.y > o.oPosY) then
            m.interactObj = o

            if (m.action ~= ACT_ENTER_HUB_PIPE) then
                set_mario_action(m, ACT_ENTER_HUB_PIPE, 0)
                o.oAction = 3
            end
        end

        load_object_collision_model()
    elseif o.oAction == 3 or o.oAction == 2 then
        if (lateral_dist_between_objects(o, m.marioObj) > 120) then
            o.oAction = 0
        end
        load_object_collision_model()
    else
        return
    end
end

---@param o Object
function level_pipe_loop(o)
    o.oUnk94 = o.oUnk94 + 1

    local gMarioState = gMarioStates[0]
    local gMarioObject = gMarioState.marioObj
    local gCurrSaveFileNum = get_current_save_file_num()
    local gCurrLevelNum = gNetworkPlayers[0].currLevelNum

    local oPosVec = { x = o.oPosX, y = o.oPosY, z = o.oPosZ }
    if gCurrLevelNum ~= LEVEL_CASTLE then
        level_pipe_in_level_loop(o, gMarioState)
        return
    end

    if gMarioState.numStars >= mitm_levels[o.oBehParams2ndByte].star_requirement and not queued_pipe_cutscene and (levels_unlocked & (1 << o.oBehParams2ndByte) == 0) then
        if o.oTimer > 30 then
            queued_pipe_cutscene = true
            o.oAction = 5
            o.oOpacity = 0
            levels_unlocked = levels_unlocked | (1 << o.oBehParams2ndByte)
            mod_storage_save_number("levels_unlocked", levels_unlocked) -- i think this should be per savefile
            -- gSaveFileModified = true
        end
        return
    end

    if o.oAction == 0 then
        if lateral_dist_between_objects(o, gMarioObject) < 120.0 and gMarioState.pos.y < o.oPosY + 500.0 and gMarioState.pos.y > o.oPosY then
            hub_level_index = o.oBehParams2ndByte
            gMarioState.interactObj = o

            if gMarioState.action ~= ACT_ENTER_HUB_PIPE then
                set_mario_action(gMarioState, ACT_ENTER_HUB_PIPE, 0)
                o.oAction = 1
                -- Uncomment for debug
                -- mitm_levels[o.oBehParams2ndByte].star_requirement = 0
                if gMarioState.numStars >= mitm_levels[o.oBehParams2ndByte].star_requirement then
                    o.oAction = 3
                end
            end
        end

        load_object_collision_model()
    elseif o.oAction == 1 or o.oAction == 3 then
        hub_level_index = o.oBehParams2ndByte
    elseif o.oAction == 2 then
        if lateral_dist_between_objects(o, gMarioObject) > 120.0 then
            o.oAction = 0
        end
        load_object_collision_model()
    elseif o.oAction == 4 then
        hub_level_index = -1
        hub_level_current_index = o.oBehParams2ndByte
    elseif o.oAction == 5 then
        djui_chat_message_create("" .. o.oTimer)
        if o.oTimer == 0 then
            gCamera.cutscene = 1
            o.oHomeX = 0.0
            o.oHomeZ = 0.0
            o.oMoveAngleYaw = cur_obj_angle_to_home()
            set_mario_action(gMarioState, ACT_CUTSCENE_CONTROLLED, 0)
            vec3f_copy(gLakituState.goalFocus, oPosVec)
            vec3f_copy(gLakituState.goalPos, oPosVec)
            gLakituState.goalPos.x = gLakituState.goalPos.x + sins(o.oMoveAngleYaw) * 2000.0
            gLakituState.goalPos.z = gLakituState.goalPos.z + coss(o.oMoveAngleYaw) * 2000.0

            gLakituState.goalFocus.y = gLakituState.goalFocus.y + 200.0
            gLakituState.goalPos.y = gLakituState.goalPos.y + 2000.0
        elseif o.oTimer == 15 then
            spawn_object(o, E_MODEL_STAR, id_bhvUnlockDoorStar)
        elseif o.oTimer == 140 then
            queued_pipe_cutscene = false
        end
        if o.oTimer > 30 and o.oOpacity < 240 then
            o.oOpacity = o.oOpacity + 3
        end
    end

    if not queued_pipe_cutscene and o.oAction == 5 then
        o.oAction = 0
        if gCamera.cutscene == 1 then
            gCamera.cutscene = 0
            set_mario_action(gMarioState, ACT_IDLE, 0)
            save_file_do_save(gCurrSaveFileNum - 1, 1)
        end
        return
    end
end
