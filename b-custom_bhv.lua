-- Custom Behaviors --

-- Custom Fields

define_custom_obj_fields({
    oNPCHasTalkedToMario = "u32", --does nothing lmao
    oUpdateRopeSize = "u32",
    oNumSwitchesLeft = "s32",
})

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

local function obj_set_hitbox(obj, hitbox)
    if not obj or not hitbox then return end
    -- Sets other hitbox values once
    if (obj.oFlags & OBJ_FLAG_30) == 0 then
        obj.oFlags = obj.oFlags | OBJ_FLAG_30
        if hitbox.interactType ~= nil then
            obj.oInteractType = hitbox.interactType
        end
        obj.oDamageOrCoinValue = hitbox.damageOrCoinValue
        obj.oHealth = hitbox.health
        obj.oNumLootCoins = hitbox.numLootCoins

        cur_obj_become_tangible()
    end

    -- Set actual hitboxes
    obj.hitboxRadius = obj.header.gfx.scale.x * hitbox.radius
    obj.hitboxHeight = obj.header.gfx.scale.y * hitbox.height
    obj.hurtboxRadius = obj.header.gfx.scale.x * hitbox.hurtboxRadius
    obj.hurtboxHeight = obj.header.gfx.scale.y * hitbox.hurtboxHeight
    obj.hitboxDownOffset = obj.header.gfx.scale.y * hitbox.downOffset
end


local function obj_handle_attacks(o, hitbox, attackedMarioAction, attackHandlers)
    if not o then return 0 end
    local attackType

    obj_set_hitbox(o, hitbox)

    -- Die immediately if above lava
    if obj_die_if_above_lava_and_health_non_positive() ~= 0 then
        return 1
    elseif (o.oInteractStatus & INT_STATUS_INTERACTED) ~= 0 then
        if (o.oInteractStatus & INT_STATUS_ATTACKED_MARIO) ~= 0 then
            if o.oAction ~= attackedMarioAction then
                o.oAction = attackedMarioAction
                o.oTimer = 0
            end
        else
            attackType = (o.oInteractStatus & INT_STATUS_ATTACK_MASK)

            if attackHandlers[attackType] == ATTACK_HANDLER_NOP then
                -- Do nothing
            elseif attackHandlers[attackType] == ATTACK_HANDLER_DIE_IF_HEALTH_NON_POSITIVE then
                obj_die_if_health_non_positive()
            elseif attackHandlers[attackType] == ATTACK_HANDLER_KNOCKBACK then
                obj_set_knockback_action(attackType)
            elseif attackHandlers[attackType] == ATTACK_HANDLER_SQUISHED then
                obj_set_squished_action()
            elseif attackHandlers[attackType] == ATTACK_HANDLER_SPECIAL_KOOPA_LOSE_SHELL then
                -- shelled_koopa_attack_handler(attackType)
            elseif attackHandlers[attackType] == ATTACK_HANDLER_SET_SPEED_TO_ZERO then
                -- obj_set_speed_to_zero()
            elseif attackHandlers[attackType] == ATTACK_HANDLER_SPECIAL_WIGGLER_JUMPED_ON then
                --  wiggler_jumped_on_attack_handler()
            elseif attackHandlers[attackType] == ATTACK_HANDLER_SPECIAL_HUGE_GOOMBA_WEAKLY_ATTACKED then
                -- huge_goomba_weakly_attacked()
            elseif attackHandlers[attackType] == ATTACK_HANDLER_SQUISHED_WITH_BLUE_COIN then
                o.oNumLootCoins = -1
                obj_set_squished_action()
            end

            o.oInteractStatus = 0
            return attackType
        end
    end

    o.oInteractStatus = 0
    return 0
end

function spawn_object_relative(behaviorParam, relativePosX, relativePosY, relativePosZ,
                               parent, model, behavior)
    local obj = spawn_object(parent, model, behavior);

    obj_copy_pos_and_angle(obj, parent);
    obj_set_parent_relative_pos(obj, relativePosX, relativePosY, relativePosZ);
    obj_build_relative_transform(obj);

    obj.oBehParams2ndByte = behaviorParam;
    obj.oBehParams = (behaviorParam << 16);

    return obj;
end

local function obj_return_home(obj, homeX, y, homeZ, dist)
    local homeDistX = obj.oHomeX - obj.oPosX
    local homeDistZ = obj.oHomeZ - obj.oPosZ
    local angleTowardsHome = atan2s(homeDistZ, homeDistX) -- Convert radians to degrees

    obj.oMoveAngleYaw = approach_s16_symmetric(obj.oMoveAngleYaw, angleTowardsHome, 320)

    return false
end

function approach_s32_symmetric(current, target, inc)
    return approach_s32(current, target, inc, inc)
end

-- bhv function

---@param o Object
function level_pipe_init(o)
    queued_pipe_cutscene = false
    o.oUnk94 = random_u16() -- oUnk94 is used for the geo asm timer
    if (gNetworkPlayers[0].currLevelNum ~= LEVEL_CASTLE) then
        o.oOpacity = 250
        return
    end

    o.oOpacity = 0

    if (gGlobalSyncTable.levels_unlocked & (1 << o.oBehParams2ndByte) ~= 0) then
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
    --djui_chat_message_create(""..levels_unlocked)
    local gMarioState = gMarioStates[0]
    local gMarioObject = gMarioState.marioObj
    local gCurrSaveFileNum = get_current_save_file_num()
    local gCurrSaveFileNumCorrect = get_current_save_file_num() - 1
    local gCurrLevelNum = gNetworkPlayers[0].currLevelNum

    local oPosVec = { x = o.oPosX, y = o.oPosY, z = o.oPosZ }
    if gCurrLevelNum ~= LEVEL_CASTLE then
        level_pipe_in_level_loop(o, gMarioState)
        return
    end

    if gMarioState.numStars >= mitm_levels[o.oBehParams2ndByte].star_requirement and not queued_pipe_cutscene and (gGlobalSyncTable.levels_unlocked & (1 << o.oBehParams2ndByte) == 0) then
        if o.oTimer > 30 then
            queued_pipe_cutscene = true
            o.oAction = 5
            o.oOpacity = 0
            gGlobalSyncTable.levels_unlocked = gGlobalSyncTable.levels_unlocked | (1 << o.oBehParams2ndByte)
            if network_is_server() then
                mod_storage_save_number("levels_unlocked_" .. gCurrSaveFileNumCorrect, gGlobalSyncTable.levels_unlocked) -- i think this should be per savefile
                -- gSaveFileModified = true
            end
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
        -- djui_chat_message_create("" .. o.oTimer)
        if o.oTimer == 0 then
            gMarioState.area.camera.cutscene = 1
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
        if gMarioState.area.camera.cutscene == 1 then
            gMarioState.area.camera.cutscene = 0
            set_mario_action(gMarioState, ACT_IDLE, 0)
            save_file_do_save(gCurrSaveFileNum - 1, 1)
            if network_is_server() then
                mod_storage_save_number("levels_unlocked_" .. gCurrSaveFileNumCorrect, gGlobalSyncTable.levels_unlocked)
            end
        end
        return
    end
end

-- banana dee
NPC_IDLE = 0x0
NPC_ACT_TURN_TO_TALK = 0x2
NPC_TALK = 0x3
NPC_HAS_NOT_TALKED = 0x0
NPC_HAS_TALKED = 0x2

sElderHitbox1 = {
    interactType = INTERACT_TEXT,
    downOffset = 0,
    damageOrCoinValue = 0,
    health = 0,
    numLootCoins = 0,
    radius = 200,
    height = 200,
    hurtboxRadius = 200,
    hurtboxHeight = 200,
}

sElderHitbox2 = {
    interactType = INTERACT_TEXT,
    downOffset = 0,
    damageOrCoinValue = 0,
    health = 0,
    numLootCoins = 0,
    radius = 100,
    height = 100,
    hurtboxRadius = 100,
    hurtboxHeight = 100,
}

function bhv_npc_init(o)
    o.oGravity = 2.5
    o.oFriction = 0.8
    o.oBuoyancy = 1.3
    o.oInteractionSubtype = INT_SUBTYPE_NPC
    o.header.gfx.scale.x = 1.0
    o.header.gfx.scale.y = 1.0
    o.header.gfx.scale.z = 1.0
    o.oGraphYOffset = 0.0
end

function bhv_youngster_init(o)
    o.oGravity = 2.5
    o.oFriction = 0.8
    o.oBuoyancy = 1.3
    o.oInteractionSubtype = INT_SUBTYPE_NPC
    o.header.gfx.scale.x = 1.0
    o.header.gfx.scale.y = 1.0
    o.header.gfx.scale.z = 1.0
    o.oGraphYOffset = 0.0
end

function bhv_elder_init(o)
    local starFlags = save_file_get_course_star_count(get_current_save_file_num() - 1, gNetworkPlayers[0].currCourseNum)
    o.oGravity = 2.5
    o.oFriction = 0.8
    o.oBuoyancy = 1.3
    o.oInteractionSubtype = INT_SUBTYPE_NPC
    o.header.gfx.scale.x = 1.0
    o.header.gfx.scale.y = 1.0
    o.header.gfx.scale.z = 1.0
    o.oGraphYOffset = 0.0
    obj_set_hitbox(o, sElderHitbox1)
    if starFlags >= 7 then
        o.oPosX = 3365.0
        o.oPosY = 0.0
        o.oPosZ = -5175.0
        obj_set_hitbox(o, sElderHitbox2)
    end
end

function bhv_npc_loop(o)
    local starFlags = save_file_get_course_star_count(get_current_save_file_num() - 1, gNetworkPlayers[0].currCourseNum)
    --[[if obj_has_behavior(o, bhvElder) ~= 0 then
        obj_set_hitbox(o, sElderHitbox1)
        if starFlags >= 7 then
            o.oPosX = 3365.0
            o.oPosY = 0.0
            o.oPosZ = -5175.0
            obj_set_hitbox(o, sElderHitbox2)
        end
    end]] --UNIMPLEMENTED

    npc_actions(o)

    o.oInteractStatus = 0
end

function npc_actions(o)
    smlua_anim_util_set_animation(o, "g_banana_dee_anim_idle")
    if o.oAction == NPC_IDLE then
        npc_idle(o)
    elseif o.oAction == NPC_ACT_TURN_TO_TALK then
        npc_act_turn_to_talk(o)
    elseif o.oAction == NPC_TALK then
        npc_talk(o)
    end

    set_object_visibility(o, 3000)
end

function npc_act_turn_to_talk(o)
    o.oMoveAngleYaw = approach_s16_symmetric(o.oMoveAngleYaw, o.oAngleToMario, 0x1000)
    if o.oMoveAngleYaw == o.oAngleToMario then
        o.oAction = NPC_TALK
    end

    -- cur_obj_play_sound_2(SOUND_PEACH_DEAR_MARIO)
end

function npc_talk(o)
    local starFlags = save_file_get_course_star_count(get_current_save_file_num() - 1, gNetworkPlayers[0].currCourseNum)
    --[[if set_mario_npc_dialog(MARIO_DIALOG_LOOK_FRONT) == MARIO_DIALOG_STATUS_SPEAK then
        o.activeFlags = (o.activeFlags|ACTIVE_FLAG_INITIATED_TIME_STOP)
        if obj_has_behavior(o, bhvElder) ~= 0 and starFlags >= 7 then
            if cutscene_object_with_dialog(CUTSCENE_DIALOG, o, DIALOG_ELDER_BELL_TOWER_2) then
                set_mario_npc_dialog(MARIO_DIALOG_STOP)

                o.activeFlags = (o.activeFlags & ~(ACTIVE_FLAG_INITIATED_TIME_STOP))
                o.oNPCHasTalkedToMario = NPC_HAS_TALKED
                o.oInteractStatus = 0
                o.oAction = NPC_IDLE
            end
        else <-----NOT IMPLEMENTED]]

    gMarioStates[0].action = ACT_READING_NPC_DIALOG
    if cutscene_object_with_dialog(CUTSCENE_DIALOG, o, o.oBehParams2ndByte) ~= 0 then
        o.activeFlags = (o.activeFlags & ~(ACTIVE_FLAG_INITIATED_TIME_STOP))
        o.oNPCHasTalkedToMario = NPC_HAS_TALKED
        o.oInteractStatus = 0
        o.oAction = NPC_IDLE
        --end
        --end
    end
end

function npc_idle(o)
    local animFrame = o.header.gfx.animInfo.animFrame

    if o.oDistanceToMario < 1000.0 then
        o.oMoveAngleYaw = approach_s16_symmetric(o.oMoveAngleYaw, o.oAngleToMario, 0x140)
    end

    if o.oInteractStatus == INT_STATUS_INTERACTED then
        o.oAction = NPC_ACT_TURN_TO_TALK
    end
end

-- sprong

function CLAMP(x, low, high)
    if x > high then
        return high
    elseif x < low then
        return low
    else
        return x
    end
end

G_SPRING_ACTION_WAITING = 0
G_SPRING_ACTION_SPRING = 1
G_SPRING_ACTION_COOLDOWN = 2
G_SPRING_ACTION_TIED = 3

function bhv_g_spring_init(o)
    if (o.oBehParams >> 8) & 0xff == 240 then
        o.oAction = G_SPRING_ACTION_TIED
    end
    o.hookRender = 1
    network_init_object(o, true, { "oAction", "oTimer", "oGravity" })
end

function bhv_g_spring_loop(o)
    local gMarioState = nearest_mario_state_to_object(o)
    local gMarioObject = gMarioState.marioObj
    if o.oAction == G_SPRING_ACTION_WAITING then
        obj_scale_xyz(o, 1, 1, 1)
        if gMarioObject.platform == o then
            o.oAction = G_SPRING_ACTION_SPRING
        end
    elseif o.oAction == G_SPRING_ACTION_SPRING then
        obj_scale_xyz(o, 1, 1.0 - CLAMP(sins(o.oTimer * 2348), -1.0, 0.9), 1)
        if o.oTimer == 15 then
            o.oAction = G_SPRING_ACTION_COOLDOWN
        end
        if o.oTimer == 2 and gMarioObject.platform == o then
            gMarioState.action = ACT_TRIPLE_JUMP
            gMarioState.vel.y = 5 * o.oBehParams2ndByte
            cur_obj_play_sound_2(SOUND_GENERAL_BOING1)
        end
    elseif o.oAction == G_SPRING_ACTION_COOLDOWN then
        obj_scale_xyz(o, 1, 1.0 - (CLAMP(sins(o.oTimer * 2348), 0.1, 2) / (o.oTimer + 1.0)), 1)
        if o.oTimer == 30 then
            o.oAction = G_SPRING_ACTION_WAITING
        end
    end

    if o.oAction == G_SPRING_ACTION_TIED then
        o.oGravity = 3.0

        if object_step() & OBJ_COL_FLAG_GROUNDED ~= 0 then
            o.oAction = G_SPRING_ACTION_WAITING
        end
    end
end

-- waddling dee
local sWaddleDeeHitbox = {
    interactType = INTERACT_BOUNCE_TOP,
    downOffset = 0,
    damageOrCoinValue = 1,
    health = 0,
    numLootCoins = 3,
    radius = 80,
    height = 100,
    hurtboxRadius = 70,
    hurtboxHeight = 30,
}

local sWaddleDeeAttackHandlers = {
    [ATTACK_PUNCH] = ATTACK_HANDLER_KNOCKBACK,
    [ATTACK_KICK_OR_TRIP] = ATTACK_HANDLER_KNOCKBACK,
    [ATTACK_FROM_ABOVE] = ATTACK_HANDLER_SQUISHED,
    [ATTACK_GROUND_POUND_OR_TWIRL] = ATTACK_HANDLER_KNOCKBACK,
    [ATTACK_FAST_ATTACK] = ATTACK_HANDLER_KNOCKBACK,
    [ATTACK_FROM_BELOW] = ATTACK_HANDLER_KNOCKBACK,
}

function bhv_g_waddle_dee_init(o)
    o.oGravity = 2.5
    o.oFriction = 0.8
    o.oBuoyancy = 1.3
    o.oHomeX = o.oPosX
    o.oHomeZ = o.oPosZ
    smlua_anim_util_set_animation(o, "g_waddle_dee_anim_ArmatureAction_001")
    network_init_object(o, true, { "oAction", "oGravity", "oForwardVel", "oPosX", "oPosY", "oPosZ" })
end

function bhv_g_waddle_dee_loop(o)
    if obj_update_standard_actions(1.0) ~= 0 then
        o.oForwardVel = 5.0

        object_step()
        cur_obj_update_floor_and_walls()
        obj_return_home(o, o.oHomeX, o.oHomeY, o.oHomeZ, 400)

        obj_handle_attacks(o, sWaddleDeeHitbox, o.oAction, sWaddleDeeAttackHandlers)
    else
        o.oGravity = -2.5
    end
end

--rope
ATTACHABLE_ROPE_DONT_CHECK_CEIL = 1

local sAttachedRopeHitbox = {
    interactType = 0,
    downOffset = 0,
    damageOrCoinValue = 0,
    health = 0,
    numLootCoins = 0,
    radius = 80,
    height = 100,
    hurtboxRadius = 70,
    hurtboxHeight = 100,
}

function bhv_g_attached_rope_init(o)
    o.oGravity = 2.0
    o.oVelY = 0

    local surf
    local originPos = { o.oPosX, o.oPosY, o.oPosZ }
    local raydir = { 0.0, 10000.0, 0.0 }
    local rayResult = 0

    surf = collision_find_surface_on_ray(
        originPos[1], originPos[2], originPos[3],
        raydir[1], raydir[2], raydir[3], 4
    )

    if surf.surface ~= nil then
        rayResult = 3
    end

    if rayResult == 3 then
        o.oBehParams = (o.oBehParams & 0xFFFF0000) | (surf.hitPos.y - o.oPosY);
    else
        obj_mark_for_deletion(o)
    end

    obj_set_hitbox(o, sAttachedRopeHitbox)
    o.oUpdateRopeSize = 1
    --TODO SYNC
    --network_init_object(o, true, { "oUpdateRopeSize", "oBehParams", "oAction", "oTimer" })
end

local function mario_can_cut_rope()
    --[[ if using_ability(ABILITY_CUTTER) then
        if gMarioState.action == ACT_FINAL_CUTTER_SEQUENCE or gMarioState.action == ACT_CUTTER_DASH or
            gMarioState.action == ACT_DIVE or gMarioState.action == ACT_DIVE_SLIDE then
            return true
        end
    end
    if using_ability(ABILITY_CHRONOS) then
        if gMarioState.action == ACT_MOVE_PUNCHING or gMarioState.action == ACT_PUNCHING then
            return true
        end
    end
    if using_ability(ABILITY_ESTEEMED_MORTAL) then
        if gMarioState.action == ACT_ABILITY_AXE_JUMP then
            return true
        end
    end
]]
    return false
    --return true
end

function bhv_g_attached_rope_loop(o)
    local gMarioState = nearest_mario_state_to_object(o)
    --[[for i = 1, o.numCollidedObjs - 1 do
        local other = o.collidedObjs[i]
        local marioHigherPos = gMarioState.pos.y + 100
         if (obj_has_behavior(other, bhvCutterBlade) and other.oPosY - 30 > o.oPosY) or
            (other == gMarioState.marioObj and marioHigherPos - 30 > o.oPosY and mario_can_cut_rope()) then
            local otherObjY = (other == gMarioState.marioObj) and marioHigherPos or other.oPosY
            play_sound(SOUND_ABILITY_CUTTER_CATCH, o.header.gfx.cameraToObject)
            local cutRope = spawn_object_relative(0, 0, otherObjY - o.oPosY, 0, o, MODEL_ATTACHED_ROPE, bhvGAttachedRope)
            o.oBehParams = (o.oBehParams & 0xFFFF0000) | (otherObjY - o.oPosY);
            o.parentObj.oBehParams = (o.oBehParams & 0xFFFF00FF) | 0x0000;
            cur_obj_become_intangible()
            o.oUpdateRopeSize = 1
            o.oAction = 1
            o.oTimer = 0
        end
    end]]

    if o.oUpdateRopeSize == 1 then
        local ropeHeight = GET_BPARAM34(o.oBehParams)
        o.hitboxHeight = ropeHeight + 10
        o.hurtboxHeight = ropeHeight
        o.oUpdateRopeSize = 0
    end

    -- this is just billboard lmao
    o.oFaceAngleYaw = atan2s(gMarioStates[0].area.camera.pos.z - o.oPosZ, gMarioStates[0].area.camera.pos.x - o.oPosX)

    if o.oAction == 1 then
        o.oVelY = o.oVelY - o.oGravity
        o.oPosY = o.oPosY + o.oVelY

        if o.oTimer >= 60 then
            obj_mark_for_deletion(o)
        end
    end
end

--hub
function bhv_hub_platform_loop(o)
    local gMarioObject = gMarioStates[0].marioObj
    if o.oTimer == 0 then
        o.oFaceAngleYaw = random_u16()
    end
    if gMarioObject.platform == o then
        o.oFaceAngleYaw = o.oFaceAngleYaw + 80
        o.oPosY = approach_f32_asymptotic(o.oPosY, o.oHomeY - 50.0, 0.2)
    else
        o.oPosY = approach_f32_asymptotic(o.oPosY, o.oHomeY, 0.2)
        o.oFaceAngleYaw = o.oFaceAngleYaw + 40
    end
end

--- bronto
local sBrontoBurtHitbox = {
    interactType = INTERACT_BOUNCE_TOP,
    downOffset = 0,
    damageOrCoinValue = 1,
    health = 0,
    numLootCoins = 3,
    radius = 80,
    height = 100,
    hurtboxRadius = 70,
    hurtboxHeight = 30,
}

local sBrontoBurtAttackHandlers = {
    [ATTACK_PUNCH] = ATTACK_HANDLER_KNOCKBACK,
    [ATTACK_KICK_OR_TRIP] = ATTACK_HANDLER_KNOCKBACK,
    [ATTACK_FROM_ABOVE] = ATTACK_HANDLER_KNOCKBACK,
    [ATTACK_GROUND_POUND_OR_TWIRL] = ATTACK_HANDLER_KNOCKBACK,
    [ATTACK_FAST_ATTACK] = ATTACK_HANDLER_KNOCKBACK,
    [ATTACK_FROM_BELOW] = ATTACK_HANDLER_KNOCKBACK,
}

function bhv_g_bronto_burt_init(o)
    smlua_anim_util_set_animation(o, "g_bronto_burt_anim_ArmatureAction")
    if o.oBehParams2ndByte % 2 == 0 then
        o.oMoveAngleYaw = o.oFaceAngleYaw + 0x4000 + (0x4000 * o.oBehParams2ndByte)
    end
    network_init_object(o, true, { "oAction", "oGravity", "oForwardVel", "oPosX", "oPosY", "oPosZ" })
end

function bhv_g_bronto_burt_loop(o)
    if obj_update_standard_actions(1.0) ~= 0 then
        if o.oBehParams2ndByte % 2 == 0 then
            o.oForwardVel = 20.0 * coss(o.oTimer * 0x222)
            cur_obj_move_xz_using_fvel_and_yaw()
            cur_obj_update_floor_and_walls()
        else
            o.oPosY = o.oHomeY + 50.0 * coss(o.oTimer * 0x222)
        end

        obj_handle_attacks(o, sBrontoBurtHitbox, o.oAction, sBrontoBurtAttackHandlers)
    else
        o.oGravity = -2.5
    end
end

-- cannon g
function bhv_g_cannon_init(o)
    o.oNumSwitchesLeft = 3
    o.oFaceAnglePitch = 0x8000
    o.oMoveAnglePitch = 0x8000
    --TODO sync?
end

function bhv_g_cannon_loop(o)
    local gMarioState = gMarioStates[0]
    if o.oAction == 0 then
        if o.oNumSwitchesLeft <= 0 then
            o.oAction = 1
            cur_obj_play_sound_2(SOUND_OBJ_CANNON1)
        end
    elseif o.oAction == 1 then
        o.oFaceAnglePitch = approach_s32_symmetric(o.oFaceAnglePitch, 0, 0x200)
        o.oMoveAnglePitch = approach_s32_symmetric(o.oMoveAnglePitch, 0, 0x200)

        if o.oFaceAnglePitch == 0 or o.oTimer >= 120 then
            o.oAction = 2
        end
    elseif o.oAction == 2 then
        if o.oDistanceToMario < 100 and gMarioState.pos.y - o.oPosY < 50 then
            o.oAction = 3
            gMarioState.area.camera.cutscene = 1
            gMarioState.pos.x = o.oPosX
            gMarioState.pos.y = o.oPosY
            gMarioState.pos.z = o.oPosZ
            set_mario_action(gMarioState, ACT_CUTSCENE_CONTROLLED, 0)
            gMarioState.marioObj.header.gfx.node.flags = (gMarioState.marioObj.header.gfx.node.flags & ~(GRAPH_RENDER_ACTIVE))
            play_sound(SOUND_GENERAL_METAL_POUND, gMarioState.marioObj.header.gfx.cameraToObject)
            cur_obj_play_sound_2(SOUND_OBJ_CANNON2)
        end
    elseif o.oAction == 3 then
        o.oFaceAnglePitch = o.oFaceAnglePitch + 0x800
        o.oMoveAnglePitch = o.oMoveAnglePitch + 0x800
        if o.oTimer == 35 then
            o.oAction = 4
        end
    elseif o.oAction == 4 then
        obj_scale_xyz(o, 1.0 + (0.5 * sins(o.oTimer * 0x444)),
            1.0 - (0.5 * sins(o.oTimer * 0x444)),
            1.0 + (0.5 * sins(o.oTimer * 0x444)))
        o.oCollisionDistance = 0
        if o.oTimer == 30 then
            gMarioState.faceAngle.y = o.oFaceAngleYaw
            gMarioState.pos.y = gMarioState.pos.y + 110.0
            gMarioState.vel.y = 80.0
            gMarioState.forwardVel = 70.0
            gMarioState.area.camera.cutscene = 0
            gMarioState.marioObj.header.gfx.node.flags = (gMarioState.marioObj.header.gfx.node.flags | GRAPH_RENDER_ACTIVE)
            play_sound(SOUND_ACTION_FLYING_FAST, gMarioState.marioObj.header.gfx.cameraToObject)
            play_sound(SOUND_OBJ_POUNDING_CANNON, gMarioState.marioObj.header.gfx.cameraToObject)
            set_mario_action(gMarioState, ACT_SHOT_FROM_CANNON, 0)
        end

        if o.oTimer == 40 then
            o.oAction = 5
        end
    elseif o.oAction == 5 then
        o.oCollisionDistance = 3000
        o.oFaceAnglePitch = approach_s32_symmetric(o.oFaceAnglePitch, 0, 0x400)
        o.oMoveAnglePitch = approach_s32_symmetric(o.oMoveAnglePitch, 0, 0x400)
        cur_obj_scale(1.0)

        if o.oFaceAnglePitch == 0 or o.oTimer >= 120 then
            o.oAction = 1
        end
    end
end
