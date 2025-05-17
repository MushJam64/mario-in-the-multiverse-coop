-- Custom Behaviors --

-- Custom Fields

define_custom_obj_fields({
    oNPCHasTalkedToMario = "u32", --does nothing lmao
    oUpdateRopeSize = "u32",
    oNumSwitchesLeft = "s32",
    oShotByShotgun = "s32",
})

-- utils

local function evaluate_cubic_spline(u, Q, spline1, spline2, spline3, spline4)
    local B = {}
    if u > 1.0 then u = 1.0 end

    local nu = 1.0 - u
    local su = u * u
    local hcu = (su * u) / 2.0

    B[1] = (nu ^ 3) / 6.0
    B[2] = hcu - su + (2.0 / 3.0)
    B[3] = -hcu + (su / 2.0) + (u / 2.0) + (1.0 / 6.0)
    B[4] = hcu / 3.0

    Q.x = (B[1] * spline1[1]) + (B[2] * spline2[1]) + (B[3] * spline3[1]) + (B[4] * spline4[1])
    Q.y = (B[1] * spline1[2]) + (B[2] * spline2[2]) + (B[3] * spline3[2]) + (B[4] * spline4[2])
    Q.z = (B[1] * spline1[3]) + (B[2] * spline2[3]) + (B[3] * spline3[3]) + (B[4] * spline4[3])
end

local function move_point_along_spline(p, spline, splineSegment, progress)
    local finished = false
    local controlPoints = {}
    for i = 1, 4 do
        controlPoints[i] = {}
    end
    local u = progress
    local progressChange
    local firstSpeed = 0
    local secondSpeed = 0
    local segment = splineSegment

    if splineSegment < 0 then
        segment = 0
        u = 0
    end
    if spline[segment].index == -1 or spline[segment + 1].index == -1 or spline[segment + 2].index == -1 then
        return 1
    end

    for i = 0, 3 do
        controlPoints[i + 1][1] = spline[segment + i].point[1]
        controlPoints[i + 1][2] = spline[segment + i].point[2]
        controlPoints[i + 1][3] = spline[segment + i].point[3]
    end
    evaluate_cubic_spline(u, p, controlPoints[1], controlPoints[2], controlPoints[3], controlPoints[4])

    if spline[splineSegment + 1].speed ~= 0 then
        firstSpeed = 1.0 / spline[splineSegment + 1].speed
    end
    if spline[splineSegment + 2].speed ~= 0 then
        secondSpeed = 1.0 / spline[splineSegment + 2].speed
    end
    progressChange = (secondSpeed - firstSpeed) * progress + firstSpeed
    progressChange = progressChange * 0.93 -- hacky way to slow down the credits due to slightly longer scenes

    if 1 <= (progress + progressChange) then
        splineSegment = splineSegment + 1
        if spline[splineSegment + 3].index == -1 then
            splineSegment = 0
            finished = true
        end
        progress = progress - 1
    end
    return finished
end

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

function obj_set_hitbox(obj, hitbox)
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

local function attack_object(obj, interaction)
    local attackType = 0

    if interaction == INT_GROUND_POUND_OR_TWIRL then
        attackType = ATTACK_GROUND_POUND_OR_TWIRL
    elseif interaction == INT_PUNCH then
        attackType = ATTACK_PUNCH
        -- elseif interaction == INT_SLASH then
        obj.oIntangibleTimer = 4
        --  -- fall through
    elseif interaction == INT_KICK or interaction == INT_TRIP then
        attackType = ATTACK_KICK_OR_TRIP
    elseif interaction == INT_SLIDE_KICK or interaction == INT_FAST_ATTACK_OR_SHELL then
        attackType = ATTACK_FAST_ATTACK
    elseif interaction == INT_HIT_FROM_ABOVE then
        attackType = ATTACK_FROM_ABOVE
    elseif interaction == INT_HIT_FROM_BELOW then
        attackType = ATTACK_FROM_BELOW
        --[[elseif interaction == INT_HIT_STUN then
        attackType = ATTACK_HIT_STUN]]
    end

    obj.oInteractStatus = attackType + (INT_STATUS_INTERACTED + INT_STATUS_WAS_ATTACKED)

    --[[ if interaction == INT_SLASH then
        obj.oInteractStatus = bit.bor(obj.oInteractStatus, INT_STATUS_CHRONOS_SLASHED)
    end
]]
    return attackType
end

function spawn_object_relative(behaviorParam, relativePosX, relativePosY, relativePosZ,
                               parent, model, behavior)
    local obj = spawn_object(parent, model, behavior)

    obj_copy_pos_and_angle(obj, parent)
    obj_set_parent_relative_pos(obj, relativePosX, relativePosY, relativePosZ)
    obj_build_relative_transform(obj)

    obj.oBehParams2ndByte = behaviorParam
    obj.oBehParams = (behaviorParam << 16)

    return obj
end

function spawn_object_relative2(behaviorParam, relativePosX, relativePosY, relativePosZ,
                                parent, model, behavior)
    local obj = spawn_object2(parent, model, behavior)

    obj_copy_pos_and_angle(obj, parent)
    obj_set_parent_relative_pos(obj, relativePosX, relativePosY, relativePosZ)
    obj_build_relative_transform(obj)

    obj.oBehParams2ndByte = behaviorParam
    obj.oBehParams = (behaviorParam << 16)

    return obj
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
    --o.header.gfx.skipInViewCheck = true
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
                save_unlocked_levels()
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
                save_unlocked_levels()
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
    o.header.gfx.skipInViewCheck = true

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
        o.oBehParams = (o.oBehParams & 0xFFFF0000) | math.floor(surf.hitPos.y - o.oPosY)
    else
        obj_mark_for_deletion(o)
    end

    obj_set_hitbox(o, sAttachedRopeHitbox)
    o.oUpdateRopeSize = 1
    --todo sync?
    --network_init_object(o, true, { "oUpdateRopeSize", "oBehParams", "oAction", "oTimer" })
end

local function mario_can_cut_rope(gMarioState)
    if using_ability(gMarioState, ABILITY_CUTTER) then
        --if gMarioState.action == ACT_FINAL_CUTTER_SEQUENCE or gMarioState.action == ACT_CUTTER_DASH or
        if gMarioState.action == ACT_DIVE or gMarioState.action == ACT_DIVE_SLIDE then
            return true
        end
    end
    if using_ability(gMarioState, ABILITY_CHRONOS) then
        if gMarioState.action == ACT_MOVE_PUNCHING or gMarioState.action == ACT_PUNCHING then
            return true
        end
    end
    if using_ability(gMarioState, ABILITY_ESTEEMED_MORTAL) then
        if gMarioState.action == ACT_ABILITY_AXE_JUMP then
            return true
        end
    end
    return true
end

function bhv_g_attached_rope_loop(o)
    local gMarioState = nearest_mario_state_to_object(o)

    for i = 1, o.numCollidedObjs - 1 do
        local other = o.collidedObjs[i]
        local marioHigherPos = gMarioState.pos.y + 100
        if (obj_has_behavior_id(other, bhvCutterBlade) ~= 0 and other.oPosY - 30 > o.oPosY) or
            (other == gMarioState.marioObj and marioHigherPos - 30 > o.oPosY and mario_can_cut_rope(gMarioState)) then
            local otherObjY = (other == gMarioState.marioObj) and math.floor(marioHigherPos) or math.floor(other.oPosY)
            --play_sound(SOUND_ABILITY_CUTTER_CATCH, o.header.gfx.cameraToObject)
            local cutRope = spawn_object_relative(0, 0, otherObjY - o.oPosY, 0, o, MODEL_ATTACHED_ROPE, bhvGAttachedRope)
            o.oBehParams = (o.oBehParams & 0xFFFF0000) | (otherObjY - o.oPosY)
            o.parentObj.oBehParams = (o.parentObj.oBehParams & ~(BP3_ATTACH_ROPE << 8))
            cur_obj_become_intangible()
            o.oUpdateRopeSize = 1
            o.oAction = 1
            o.oTimer = 0
        end
    end

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
    network_init_object(o, true, { "oAction", "oNumSwitchesLeft", "oCollisionDistance", "oTimer" })
end

function bhv_g_cannon_loop(o)
    local gMarioState = nearest_mario_state_to_object(o)
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
        if dist_between_objects(o, gMarioState.marioObj) < 100 and gMarioState.pos.y - o.oPosY < 50 then
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

-- attahced block
function bhv_g_attached_block_init(o)
    -- o.parentObj = spawn_object_relative(0, 0, 200, 0, o, MODEL_ATTACHED_ROPE, bhvGAttachedRope)

    o.oGravity = 2.0
    o.oBounciness = 2.0

    o.oHomeY = find_floor_height(o.oPosX, o.oPosY, o.oPosZ)

    o.hookRender = 1
    network_init_object(o, true, { "oPosY", "oHomeY", "oAction", "oVelY" })
end

function bhv_g_attached_block_loop(o)
    --[[
    if o.parentObj.oAction == 1 then
        o.oAction = 1
    end

    if o.oAction == 1 then
        object_step()

        if o.oTimer == 120 then
            o.oAction = 2
        end
    end
    --]]

    -- object_step()

    o.oPosY = o.oPosY + o.oVelY

    if o.oPosY < o.oHomeY then
        if o.oVelY < -0.5 then
            -- bounce if y velocity is faster than -0.5
            o.oVelY = -o.oVelY * 0.4
        else
            o.oVelY = 0.0
        end
        o.oPosY = o.oHomeY
        if o.oAction == 0 then
            cur_obj_play_sound_2(SOUND_GENERAL_METAL_POUND)
            o.oAction = o.oAction + 1
        end
    else
        o.oVelY = o.oVelY - 2.0
    end
end

--that fucking bird that i hate
local SIR_KIBBLE_ACT_CUTSCENE = 0
local SIR_KIBBLE_ACT_IDLE = 1
local SIR_KIBBLE_ACT_THROWING = 2
local SIR_KIBBLE_ACT_HURT = 3

local sSirKibbleHitbox = {
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

local sBossSirKibbleHitbox = {
    interactType = INTERACT_DAMAGE,
    downOffset = 0,
    damageOrCoinValue = 1,
    health = 0,
    numLootCoins = 0,
    radius = 80,
    height = 100,
    hurtboxRadius = 70,
    hurtboxHeight = 30,
}

local sSirKibbleAttackHandlers = {
    [ATTACK_PUNCH] = ATTACK_HANDLER_KNOCKBACK,
    [ATTACK_KICK_OR_TRIP] = ATTACK_HANDLER_KNOCKBACK,
    [ATTACK_FROM_ABOVE] = ATTACK_HANDLER_SET_SPEED_TO_ZERO,
    [ATTACK_GROUND_POUND_OR_TWIRL] = ATTACK_HANDLER_SET_SPEED_TO_ZERO,
    [ATTACK_FAST_ATTACK] = ATTACK_HANDLER_KNOCKBACK,
    [ATTACK_FROM_BELOW] = ATTACK_HANDLER_KNOCKBACK,
}

function bhv_sir_kibble_init(o)
    o.oFlags = (OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE | OBJ_FLAG_COMPUTE_DIST_TO_MARIO | OBJ_FLAG_SET_FACE_YAW_TO_MOVE_YAW) --OR OBJ_FLAG_E__SG_CUSTOM also
    o.oAction = SIR_KIBBLE_ACT_CUTSCENE
    if o.oBehParams2ndByte == 1 then
        obj_set_hitbox(o, sBossSirKibbleHitbox)
        play_secondary_music(SEQ_CUSTOM_KIRBY_BOSS, 0, 127, 5)
    else
        o.oAction = SIR_KIBBLE_ACT_IDLE
    end
    smlua_anim_util_set_animation(o, "sir_kibble_anim_idle")
    o.oGravity = -4.0
    network_init_object(o, true, { "oAction", "oTimer", "oHealth", "oForwardVel", "oVelY", "oInteractStatus" })
end

-- sir_kibble_anim_throw and sir_kibble_anim_idle

function bhv_sir_kibble_loop(o)
    local gMarioObject = nearest_player_to_object(o)
    if obj_update_standard_actions(1.0) ~= 0 then
        obj_turn_toward_object(o, gMarioObject, 0x10, 0x400)
        if o.oBehParams2ndByte == 1 then o.oInteractStatus = 0 end
        if o.oAction == SIR_KIBBLE_ACT_CUTSCENE then
            if o.oTimer > 10 then
                smlua_anim_util_set_animation(o, "sir_kibble_anim_throw")
                o.oAction = SIR_KIBBLE_ACT_THROWING
            end
        elseif o.oAction == SIR_KIBBLE_ACT_IDLE then
            if o.oTimer >= 90 then
                o.oAction = SIR_KIBBLE_ACT_THROWING
                smlua_anim_util_set_animation(o, "sir_kibble_anim_throw")
            end
        elseif o.oAction == SIR_KIBBLE_ACT_THROWING then
            if o.oTimer == 17 then
                spawn_object_relative2(2, 0, 100, 0, o, MODEL_CUTTER_BLADE, bhvCutterBlade) --todo sync?

                --cutterblade.activeFlags = (cutterblade.activeFlags | ACTIVE_FLAG_INITIATED_TIME_STOP)
            end

            if o.oTimer == 32 then
                o.oAction = SIR_KIBBLE_ACT_IDLE
                smlua_anim_util_set_animation(o, "sir_kibble_anim_idle")
            end
        end

        if o.oBehParams2ndByte == 1 then
            local star = obj_get_nearest_object_with_behavior_id(o, bhvStarProjectile)
            if star and dist_between_objects(star, o) < 200 and o.oAction < 5 then
                o.oAction = OBJ_ACT_HORIZONTAL_KNOCKBACK
                o.oForwardVel = -50.0
                o.oVelY = 30.0
                o.oHealth = 0
            end
        else
            obj_handle_attacks(o, sSirKibbleHitbox, o.oAction, sSirKibbleAttackHandlers)
        end
    end
    if o.oShotByShotgun > 0 then
        --cur_obj_play_sound_2(SOUND_ACTION_SNUFFIT_BULLET_HIT_METAL)
        o.oShotByShotgun = 0
    end
end

bhvSirKibble = hook_behavior(nil, OBJ_LIST_GENACTOR, true, bhv_sir_kibble_init, bhv_sir_kibble_loop, "bhvSirKibble")

-- cutter for ability and that guy above
local sCutterBladeHitbox = {
    interactType = 0,
    downOffset = 50,
    damageOrCoinValue = 1,
    health = 0,
    numLootCoins = 0,
    radius = 80,
    height = 100,
    hurtboxRadius = 20,
    hurtboxHeight = 20,
}

local sEnemyCutterBladeHitbox = {
    interactType = INTERACT_DAMAGE,
    downOffset = 50,
    damageOrCoinValue = 2,
    health = 0,
    numLootCoins = 0,
    radius = 80,
    height = 100,
    hurtboxRadius = 70,
    hurtboxHeight = 30,
}

function bhv_cutter_blade_init(o)
    o.oForwardVel = 70.0
    o.oGravity = 0.0

    --play_sound(SOUND_ABILITY_CUTTER_THROW, o.header.gfx.cameraToObject)

    network_init_object(o, true, { "oAction", "oTimer", "oForwardVel", "oFaceAngleYaw" })
end

---@param o Object
function bhv_cutter_blade_loop(o)
    local gMarioObject = nearest_player_to_object(o)
    --djui_chat_message_create("" .. o.oBehParams2ndByte)
    if o.oBehParams2ndByte == 0 then
        obj_set_hitbox(o, sCutterBladeHitbox)
    else
        obj_set_hitbox(o, sEnemyCutterBladeHitbox)
    end
    if o.oAction == 0 then
        o.oFaceAngleYaw = o.oFaceAngleYaw + 0x2000
        o.oForwardVel = o.oForwardVel - 3.0
        if o.oForwardVel <= 0 then
            o.oForwardVel = 0.0
            o.oAction = o.oAction + 1
        end
    elseif o.oAction == 1 then
        o.oFaceAngleYaw = o.oFaceAngleYaw + 0x2000
        if o.oTimer >= 15 then
            o.oAction = o.oAction + 1
        end
    elseif o.oAction == 2 then
        o.oFaceAngleYaw = o.oFaceAngleYaw + 0x2000
        o.oForwardVel = o.oForwardVel - 2.0
        if o.oTimer >= 50 or dist_between_objects(o, gMarioObject) > 2000 then
            o.oAngleVelYaw = 0x800
            o.oAngleVelPitch = random_u16() / 64
            o.oAngleVelRoll = random_u16() / 64
            o.oAction = o.oAction + 1
        end
    elseif o.oAction == 3 then
        o.oGravity = 1.0
        o.oForwardVel = o.oForwardVel * 0.8

        o.oFaceAngleYaw = o.oFaceAngleYaw + o.oAngleVelYaw
        o.oFaceAngleRoll = o.oFaceAngleRoll + o.oAngleVelRoll
        o.oFaceAnglePitch = o.oFaceAnglePitch + o.oAngleVelPitch

        o.oAngleVelYaw = o.oAngleVelYaw * 0.9
        o.oAngleVelRoll = o.oAngleVelRoll * 0.9
        o.oAngleVelPitch = o.oAngleVelPitch * 0.9

        if o.oTimer == 30 then
            spawn_mist_particles_variable(8, 10, 5.0)
            obj_mark_for_deletion(o)
        end
    end

    --[[local surf
    local originPos = { o.oPosX, o.oPosY, o.oPosZ }
    local hitpos = { 0.0, 0.0, 0.0 }
    local raydir = { math.sin(o.oMoveAngleYaw) * o.oForwardVel, 0.0, math.cos(o.oMoveAngleYaw) * o.oForwardVel }
    local rayResult = 0

     wall check
    find_surface_on_ray(originPos, raydir, surf, hitpos, 2)
    if surf ~= nil then
        rayResult = 1
    end
    -- ceil check
    raydir[2] = raydir[2] + 40.0
    find_surface_on_ray(originPos, raydir, surf, hitpos, 4)
    if surf ~= nil then
        rayResult = 3
    end]]

    -- floor check
    --[[ raydir[2] = raydir[2] - 20.0
    surf = collision_find_surface_on_ray(
        originPos[1], originPos[2], originPos[3],
        raydir[1], raydir[2], raydir[3]
    ).surface
    if surf ~= nil then
        rayResult = 2
    end

    if rayResult > 0 then
        if o.oAction == 0 then
            o.oForwardVel = 0.0
            o.oAction = 1
        elseif o.oAction == 2 then
            o.oAction = 3
            if rayResult == 2 then
                o.oVelY = 10.0
            elseif rayResult == 3 then
                o.oVelY = -10.0
            end
            o.oAngleVelYaw = 0x800
            o.oAngleVelPitch = random_u16() / 64
            o.oAngleVelRoll = random_u16() / 64
            o.oForwardVel = o.oForwardVel * -0.05
        end
    end
]]
    if object_step() & OBJ_COL_FLAG_HIT_WALL ~= 0 then
        o.oForwardVel = o.oForwardVel * -0.05
        o.oAngleVelYaw = 0x800
        o.oAngleVelPitch = random_u16() / 64
        o.oAngleVelRoll = random_u16() / 64
        o.oAction = 3
    end

    o.oInteractStatus = 0
    for i = 1, o.numCollidedObjs - 1 do
        local other = o.collidedObjs[i]
        if other ~= o.parentObj then
            if other ~= gMarioObject then
                attack_object(other, 2)
            end
        end
    end

    if o.oAction >= 2 and obj_check_hitbox_overlap(gMarioObject, o) then
        --play_sound(SOUND_ABILITY_CUTTER_CATCH, o.header.gfx.cameraToObject)
        spawn_object_relative2(0, 0, 100, 0, o.parentObj, E_MODEL_NONE, id_bhvSparkleSpawn)
        obj_mark_for_deletion(o)
    end
end

--star proj

function bhv_respawner_loop2(o)
    local spawnedObject
    if (is_point_within_radius_of_mario(o.oPosX, o.oPosY, o.oPosZ, o.oRespawnerMinSpawnDist) == 0) then
        if spawnedObject then
            spawnedObject = spawn_object2(o, o.oRespawnerModelToRespawn, o.oHealth)
            spawnedObject.oBehParams = o.oBehParams
            o.activeFlags = ACTIVE_FLAG_DEACTIVATED
        end
    end
end

function create_respawner(o, model, behToSpawn, minSpawnDist)
    local respawner = spawn_sync_object(bhvRespawner2, E_MODEL_NONE, o.oHomeX, o.oHomeY, o.oHomeZ, nil)
    respawner.oBehParams = o.oBehParams
    respawner.oRespawnerModelToRespawn = model
    respawner.oRespawnerMinSpawnDist = minSpawnDist
    respawner.oHealth = behToSpawn
end

bhvRespawner2 = hook_behavior(nil, OBJ_LIST_SPAWNER, true, function(s)
    network_init_object(s, true, { "oHealth", "oRespawnerMinSpawnDist", "oRespawnerModelToRespawn", "oBehParams" })
end, bhv_respawner_loop2)

local sStarProjectileHitbox = {
    interactType = INTERACT_GRABBABLE,
    downOffset = 0,
    damageOrCoinValue = 0,
    health = 1,
    numLootCoins = 0,
    radius = 100,
    height = 190,
    hurtboxRadius = 100,
    hurtboxHeight = 190,
}

function bhv_star_projectile_init(o)
    o.oGravity = 0.0
    o.oFriction = 0.99
    o.oBuoyancy = 1.4
    obj_set_hitbox(o, sStarProjectileHitbox)
    cur_obj_scale(0.8)
    --o.oAnimState = BREAKABLE_BOX_ANIM_STATE_CORK_BOX
    o.activeFlags = (o.activeFlags | ACTIVE_FLAG_UNK9)
    network_init_object(o, true, nil)
end

---@param o Object
function star_projectile_act_move(o)
    local collisionFlags = object_step()

    obj_attack_collided_from_other_object(o)

    if (collisionFlags & OBJ_COL_FLAG_HIT_WALL) ~= 0 then
        spawn_mist_particles()
        spawn_triangle_break_particles(20, 0x8B, 0.2, 3)
        create_sound_spawner(SOUND_GENERAL_EXPLOSION6)
        create_respawner(o, MODEL_G_STAR_BLOCK, bhvStarProjectile, 1000)
        o.activeFlags = ACTIVE_FLAG_DEACTIVATED
    end
    if o.oFloor then
        obj_check_floor_death(collisionFlags, o.oFloor)
    end
end

function star_projectile_released_loop(o)
    o.oBreakableBoxSmallFramesSinceReleased = o.oBreakableBoxSmallFramesSinceReleased + 1

    -- Begin flashing
    if (o.oBreakableBoxSmallFramesSinceReleased > 810) then
        if (o.oBreakableBoxSmallFramesSinceReleased & 1) ~= 0 then
            o.header.gfx.node.flags = o.header.gfx.node.flag | GRAPH_RENDER_INVISIBLE
        else
            o.header.gfx.node.flags = o.header.gfx.node.flags & ~GRAPH_RENDER_INVISIBLE
        end
    end
    -- Despawn, and create a corkbox respawner
    if o.oBreakableBoxSmallFramesSinceReleased > 900 then
        create_respawner(o, MODEL_G_STAR_BLOCK, bhvStarProjectile, 1000)
        o.activeFlags = ACTIVE_FLAG_DEACTIVATED
    end
end

function star_projectile_idle_loop(o)
    if o.oAction == 0 then
        star_projectile_act_move(o)
    elseif o.oAction == OBJ_ACT_LAVA_DEATH then
        obj_lava_death()
    elseif o.oAction == OBJ_ACT_DEATH_PLANE_DEATH then
        o.activeFlags = ACTIVE_FLAG_DEACTIVATED
        create_respawner(o, MODEL_G_STAR_BLOCK, bhvStarProjectile, 1000)
    end

    if o.oBreakableBoxSmallReleased == 1 then
        star_projectile_released_loop(o)
    end
end

function star_projectile_get_dropped(o)
    cur_obj_become_tangible()
    cur_obj_enable_rendering()
    cur_obj_get_dropped()
    o.header.gfx.node.flags = (o.header.gfx.node.flags & ~(GRAPH_RENDER_INVISIBLE))
    o.oHeldState = HELD_FREE
    o.oBreakableBoxSmallReleased = true
    o.oBreakableBoxSmallFramesSinceReleased = 0
end

function star_projectile_get_thrown(o)
    cur_obj_become_tangible()
    cur_obj_enable_rendering()
    obj_set_model_extended(o, MODEL_G_STAR_PROJECTILE)
    o.header.gfx.node.flags = (o.header.gfx.node.flags & ~(GRAPH_RENDER_INVISIBLE))
    o.oHeldState = HELD_FREE
    o.oFlags = (o.oFlags & ~(OBJ_FLAG_SET_FACE_YAW_TO_MOVE_YAW))
    o.oForwardVel = 40.0
    o.oBreakableBoxSmallReleased = true
    o.oBreakableBoxSmallFramesSinceReleased = 0
    o.activeFlags = (o.activeFlags & ~(ACTIVE_FLAG_UNK9))
end

function bhv_star_projectile_loop(o)
    if o.oHeldState == HELD_FREE then
        star_projectile_idle_loop(o)
    elseif o.oHeldState == HELD_HELD then
        cur_obj_disable_rendering()
        cur_obj_become_intangible()
    elseif o.oHeldState == HELD_THROWN then
        star_projectile_get_thrown(o)
    elseif o.oHeldState == HELD_DROPPED then
        star_projectile_get_thrown(o)
    end

    o.oInteractStatus = 0
end

-- level g cutscenes
g_area_2_spline_KibbleFocus = {
    { index = 0,  speed = 1,  point = { 64, 606, 1474 } },
    { index = 1,  speed = 20, point = { -36, 606, 1424 } },
    { index = 2,  speed = 10, point = { -238, 631, 775 } },
    { index = 3,  speed = 5,  point = { -250, 633, 314 } },
    { index = 4,  speed = 10, point = { -203, 565, -414 } },
    { index = 5,  speed = 60, point = { 17, 541, -760 } },
    { index = 6,  speed = 10, point = { 112, 503, -845 } },
    { index = -1, speed = 1,  point = { 220, 485, -901 } },
}
function bhv_level_g_cutscenes_init(o)
    network_init_object(o, true, nil)
end

function bhv_level_g_cutscenes_loop(o)
    if o.oBehParams2ndByte == 0 then
        --set_time_stop_flags(TIME_STOP_ENABLED | TIME_STOP_MARIO_AND_DOORS)
        --o.activeFlags = (o.activeFlags | ACTIVE_FLAG_INITIATED_TIME_STOP)
        --local sirKibble = obj_get_nearest_object_with_behavior_id(bhvSirKibble)
        --sirKibble.activeFlags = (sirKibble.activeFlags | ACTIVE_FLAG_INITIATED_TIME_STOP)
        --[[for mi = 0, MAX_PLAYERS - 1 do
            local m = gMarioStates[mi]

            m.area.camera.cutscene = 1
            gLakituState.goalPos.x = 749
            gLakituState.goalPos.y = 800
            gLakituState.goalPos.z = 446
            --if move_point_along_spline(gLakituState.goalFocus, (g_area_2_spline_KibbleFocus), sCutsceneSplineSegment, sCutsceneSplineSegmentProgress) then
            m.area.camera.cutscene = 0
            --clear_time_stop_flags(TIME_STOP_ENABLED | TIME_STOP_MARIO_AND_DOORS)

        end]]
        -- end
        obj_mark_for_deletion(o)
    elseif o.oBehParams2ndByte == 1 then
        if o.oAction == 0 then
            local sirKibble = obj_get_nearest_object_with_behavior_id(o, bhvSirKibble)

            if not sirKibble or (sirKibble and (sirKibble.activeFlags & ACTIVE_FLAG_DEACTIVATED) ~= 0) then
                spawn_non_sync_object(bhvStarDrop, MODEL_G_STAR_PROJECTILE, o.oHealth, o.oAnimState + 100, o.oDoorUnk100,
                    nil)
                o.oAction = 1
            else
                o.oHealth = sirKibble.oPosX
                o.oAnimState = sirKibble.oPosY
                o.oDoorUnk100 = sirKibble.oPosZ
            end
        end
    end
end

--star drop
function bhv_star_drop_init(o)
    -- gMarioStates[0].area.camera.cutscene = 1
    stop_secondary_music(180)
    --network_init_object(o, true, nil) no syncing
end

function bhv_star_drop_loop(o)
    o.oFaceAngleYaw = o.oFaceAngleYaw + 0x400

    o.oFaceAnglePitch = o.oFaceAnglePitch + 0x800

    if o.oTimer >= 30 and o.oTimer < 90 then
        --[[gLakituState.goalFocus.x = o.oPosX
        gLakituState.goalFocus.y = o.oPosY
        gLakituState.goalFocus.z = o.oPosZ]]
        o.oPosY = o.oPosY + 20 * coss(0x222 * (o.oTimer - 30))
        o.oPosX = approach_f32_asymptotic(o.oPosX, 0, 0.8)
        o.oPosZ = approach_f32_asymptotic(o.oPosZ, 0, 0.8)
    elseif o.oTimer >= 90 then
        o.oPosY = o.oPosY + 4 * coss(0x222 * (o.oTimer - 90))

        if o.oTimer == 110 then
            spawn_object_relative2(ABILITY_CUTTER, 0, 0, 0, o, MODEL_ABILITY, bhvAbilityUnlock)
            cur_obj_hide()
            spawn_mist_particles()
            spawn_triangle_break_particles(20, 0x8B, 0.2, 3)
            create_sound_spawner(SOUND_GENERAL_SHORT_STAR)
        end
        if o.oTimer == 140 then
            --gMarioStates[0].area.camera.cutscene = 0
            obj_mark_for_deletion(o)
            obj_mark_for_deletion(o.parentObj)
        end
    end
end

function bhv_g_cut_rock_init(o)
    o.oGravity = 2.0
    o.oBounciness = 2.0
    o.hookRender = 1
    network_init_object(o, true, { "oAction", "oTimer" })
end

function bhv_g_cut_rock_loop(o)
    o.oAction = 1

    if o.oAction == 1 then
        object_step()

        if o.oTimer == 120 then
            o.oAction = 2
        end
    end
end

function bhv_g_cannon_switch_init(o)
    network_init_object(o, true, { "oAction", "oTimer", "oShotByShotgun" })
end

function bhv_g_cannon_switch_loop(o)
    local dist
    local rock, cannon
    local gMarioObject = nearest_player_to_object(o)

    if o.oAction == 0 then
        obj_set_model_extended(o, E_MODEL_PURPLE_SWITCH)
        cur_obj_scale(1.5)

        --rock, dist = cur_obj_find_nearest_object_with_behavior(get_behavior_from_id(bhvGCutRock))
        rock = obj_get_nearest_object_with_behavior_id(o, bhvGCutRock)
        if (rock and (rock.oPosY - o.oPosY) < 100 and lateral_dist_between_objects(o, rock) < 127.5)
            or (o.oShotByShotgun == 2) then
            o.oAction = 1
            cannon = obj_get_nearest_object_with_behavior_id(o, (bhvGCannon))
            if cannon then
                cannon.oNumSwitchesLeft = cannon.oNumSwitchesLeft - 1
            end
        end
    elseif o.oAction == 1 then
        cur_obj_scale_over_time(2, 3, 1.5, 0.2)
        if o.oTimer == 3 then
            cur_obj_play_sound_2(SOUND_GENERAL2_PURPLE_SWITCH)
            o.oAction = 2
            cur_obj_shake_screen(SHAKE_POS_SMALL)
            -- #ifdef ENABLE_RUMBLE
            queue_rumble_data(5, 80)
            -- #endif
        end
    elseif o.oAction == 2 then
        if o.oBehParams2ndByte ~= 0 then
            if o.oBehParams2ndByte == 1 and gMarioObject.platform ~= o then
                o.oAction = o.oAction + 1
            else
                if o.oTimer < 360 then
                    play_sound(SOUND_GENERAL2_SWITCH_TICK_FAST, gGlobalSoundSource)
                else
                    play_sound(SOUND_GENERAL2_SWITCH_TICK_SLOW, gGlobalSoundSource)
                end
                if o.oTimer > 400 then
                    o.oAction = 4
                end
            end
        end
    elseif o.oAction == 3 then
        cur_obj_scale_over_time(2, 3, 0.2, 1.5)
        if o.oTimer == 3 then
            o.oAction = 0
        end
    elseif o.oAction == 4 then
        if cur_obj_is_any_player_on_platform() ~= 0 then
            o.oAction = 3
        end
    end

    o.oShotByShotgun = 0
end

local sCollectablePaintingHitbox = {
    interactType = INTERACT_STAR_OR_KEY,
    downOffset = 0,
    damageOrCoinValue = 0,
    health = 0,
    numLootCoins = 0,
    radius = 80,
    height = 50,
    hurtboxRadius = 0,
    hurtboxHeight = 0,
}

function bhv_collectable_painting(obj)
    local paintingIndex = obj.oBehParams2ndByte

    if obj.oAction == 0 then
        -- active at all times in port
        -- Decide if the painting should be active
        --if gSaveBuffer.files[gCurrSaveFileNum - 1][1].paintings_unlocked & (1 << paintingIndex) ~= 0 then
        -- mark_obj_for_deletion(obj)
        -- else
        obj.oAction = 1
        --end
    elseif obj.oAction == 1 then
        -- Initialization
        --[[local texture = segmented_to_virtual(collectable_painting_painting_rgba16)
        local rom_location = painting_data + paintingIndex * 2048
        dma_read(texture, rom_location, rom_location + 2048)

        obj.header.gfx.sharedChild = gLoadedGraphNodes[MODEL_PAINTING]]
        obj_set_model_extended(obj, MODEL_PAINTING)
        obj_set_hitbox(obj, sCollectablePaintingHitbox)
        obj.oAction = 2
    elseif obj.oAction == 2 then
        -- Behavior loop
        obj.oFaceAngleYaw = obj.oFaceAngleYaw + 0x800

        if (obj.oInteractStatus & INT_STATUS_INTERACTED) ~= 0 then
            cur_obj_become_intangible()
            cur_obj_hide()
            obj.oInteractStatus = 0
            obj.oAction = 3
        end
    end
end
