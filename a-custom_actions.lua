ACT_CUTSCENE_CONTROLLED = allocate_mario_action(ACT_GROUP_CUTSCENE)
ACT_ENTER_HUB_PIPE = allocate_mario_action(ACT_GROUP_CUTSCENE)

local function act_cutscene_controlled(m)
    vec3f_copy(m.marioObj.header.gfx.pos, m.pos)
    vec3s_set(m.marioObj.header.gfx.angle, 0, m.faceAngle.y, 0)
    return 0
end

local function act_enter_hub_pipe(m)
    local gPlayer1Controller = m.controller
    set_mario_animation(m, MARIO_ANIM_A_POSE)
    vec3f_copy(m.marioObj.header.gfx.pos, m.pos)
    vec3s_set(m.marioObj.header.gfx.angle, 0, m.faceAngle.y, 0)
    m.pos.x = approach_f32_asymptotic(m.pos.x, m.interactObj.oPosX, 0.1)
    m.pos.z = approach_f32_asymptotic(m.pos.z, m.interactObj.oPosZ, 0.1)

    if m.actionState == 0 then
        m.pos.y = approach_f32_asymptotic(m.pos.y, m.interactObj.oPosY + 300.0, 0.1)

        if (gPlayer1Controller.buttonPressed & B_BUTTON) ~= 0 then
            m.interactObj.oAction = 2
            set_mario_action(m, ACT_IDLE, 0)
        end

        if (gPlayer1Controller.buttonPressed & A_BUTTON) ~= 0 then
            if m.interactObj.oAction == 3 then
                play_sound(SOUND_MENU_ENTER_PIPE, m.marioObj.header.gfx.cameraToObject)
                m.actionState = 1
                m.interactObj.oAction = 4
            else
                play_sound(SOUND_MENU_CAMERA_BUZZ, m.marioObj.header.gfx.cameraToObject)
            end
        end

        --[[if (gPlayer1Controller.buttonPressed & Z_TRIG) ~= 0 and dream_comet_unlocked() then
            play_sound(SOUND_MENU_CLICK_CHANGE_VIEW, gGlobalSoundSource)
            dream_comet_enabled = not dream_comet_enabled
        end]]
    else
        m.pos.y = approach_f32_asymptotic(m.pos.y, m.interactObj.oPosY + 60.0, 0.1)
        m.actionTimer = m.actionTimer + 1
        if m.actionTimer > 20 then
            if gNetworkPlayers[0].currLevelNum == LEVEL_CASTLE then
                -- Enter a level
                warp_to_warpnode(get_hub_level(m.interactObj.oBehParams2ndByte), get_hub_area(m.interactObj.oBehParams2ndByte), 0, 0x0A)
            else
                -- Exit a level
                warp_to_warpnode(LEVEL_CASTLE, 0x01, 0, get_hub_return_id(hub_level_current_index))
            end
        end
    end

    return 0
end

hook_mario_action(ACT_CUTSCENE_CONTROLLED, act_cutscene_controlled)
hook_mario_action(ACT_ENTER_HUB_PIPE, act_enter_hub_pipe)