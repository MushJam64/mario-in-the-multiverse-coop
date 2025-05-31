-- name: !  Custom Pause Menu  !
-- description: New pause menu featuring a \nrestart level option\nMade by Blocky

local zero = { x = 0, y = 0, z = 0 }
local m = gMarioStates[0]
local np = gNetworkPlayers[0]
local restartLevelArea = 1

isPaused = false

--* thanks coolio for the hook & function overwriting

local function is_game_paused_modded()
    return isPaused
end

_G.is_game_paused = is_game_paused_modded

local pause_exit_funcs = {}

local real_hook_event = hook_event
local function hook_event_modded(hook, func)
    if hook == HOOK_ON_PAUSE_EXIT then
        table.insert(pause_exit_funcs, func)
    else
        return real_hook_event(hook, func)
    end
end
_G.hook_event = hook_event_modded

local function call_pause_exit_hooks(exitToCastle)
    local allowExit = true
    for _, func in ipairs(pause_exit_funcs) do
        if func(exitToCastle) == false then
            allowExit = false
            break
        end
    end
    return allowExit
end

local play_sound, save_file_get_star_flags, level_trigger_warp, warp_to_warpnode, djui_hud_set_resolution, djui_hud_set_font,
djui_hud_get_screen_height, djui_hud_get_screen_width, djui_hud_set_color, djui_hud_render_rect, course_is_main_course, get_level_name,
get_star_name, save_file_get_course_star_count, get_current_save_file_num, save_file_get_course_coin_score, djui_hud_measure_text,
djui_hud_print_text, obj_count_objects_with_behavior_id, djui_open_pause_menu =
    play_sound, save_file_get_star_flags, level_trigger_warp, warp_to_warpnode, djui_hud_set_resolution,
    djui_hud_set_font,
    djui_hud_get_screen_height, djui_hud_get_screen_width, djui_hud_set_color, djui_hud_render_rect,
    course_is_main_course, get_level_name,
    get_star_name, save_file_get_course_star_count, get_current_save_file_num, save_file_get_course_coin_score,
    djui_hud_measure_text,
    djui_hud_print_text, obj_count_objects_with_behavior_id, djui_open_pause_menu

local selectedOption = 1

local function close_menu()
    if isPaused then
        isPaused = false
        play_sound(SOUND_MENU_PAUSE_HIGHPRIO, zero)
        m.controller.buttonPressed = 0
    end
end

local cooldown = 5
local cooldownCounter = 0

local previousStickY = 0

function loop_var(var, min, max)
    if var > max then
        var = min
    elseif var < min then
        var = max
    end
    return var
end

local function menu_controls(options)
    local stickY = gMarioStates[0].controller.stickY

    if stickY * previousStickY <= 0 then
        cooldownCounter = cooldownCounter // 2
    end

    if cooldownCounter > 0 then
        cooldownCounter = cooldownCounter - 1
    else
        local delta = options and 1 or -1
        if stickY > 0.5 then
            selectedOption = (selectedOption - delta)
            if options then
                selectedOption = loop_var(selectedOption, 1, #options)
            else
                selectedOption = loop_var(selectedOption, 0, COURSE_MAX)
            end
            play_sound(SOUND_MENU_CHANGE_SELECT, zero)
            cooldownCounter = cooldown
        elseif stickY < -0.5 then
            selectedOption = (selectedOption + delta)
            if options then
                selectedOption = loop_var(selectedOption, 1, #options)
            else
                selectedOption = loop_var(selectedOption, 0, COURSE_MAX)
            end
            play_sound(SOUND_MENU_CHANGE_SELECT, zero)
            cooldownCounter = cooldown
        end
    end

    if gMarioStates[0].controller.buttonPressed & A_BUTTON ~= 0 and options then
        play_sound(SOUND_MENU_CLICK_FILE_SELECT, gMarioStates[0].pos)
        local option = options[selectedOption]
        if option and option.func then
            option.func()
        end
    end

    previousStickY = stickY
end


local function is_star_collected(fileIndex, courseIndex, starId)
    if fileIndex < 0 or courseIndex < -1 or starId < 0 then
        return false
    end

    local currentLevelStarFlags = save_file_get_star_flags(fileIndex, courseIndex)

    return (currentLevelStarFlags & (1 << starId)) ~= 0
end

local romhackText = "Mario In The Multiverse"

local function exit_course()
    if call_pause_exit_hooks(false) then
        level_trigger_warp(m, WARP_OP_EXIT)
        close_menu()
    else
        play_sound(SOUND_MENU_CAMERA_BUZZ, zero)
    end
end

local function restart_course()
    if call_pause_exit_hooks(false) then
        --warp_restart_level()
        warp_to_level(gNetworkPlayers[0].currLevelNum, restartLevelArea, gNetworkPlayers[0].currActNum)
        gMarioStates[0].health = 0x880
        close_menu()
    else
        play_sound(SOUND_MENU_CAMERA_BUZZ, zero)
    end
end

local function exit_to_castle()
    if call_pause_exit_hooks(true) then
        -- warp_to_castle(1)  ---- gotta figure this out
        -- gLevelValues.exitCastleWarpNode
        warp_to_warpnode(gLevelValues.exitCastleLevel, gLevelValues.exitCastleArea, 0, gLevelValues.exitCastleWarpNode) -- temporary
        gMarioStates[0].health = 0x880
        close_menu()
    else
        play_sound(SOUND_MENU_CAMERA_BUZZ, zero)
    end
end

local pauseMenuLevelOptions = {
    { name = "CONTINUE",         func = close_menu },
    { name = "CHANGE ABILITIES", func = restart_course },
    { name = "EXIT COURSE",      func = exit_course },
    { name = "EXIT TO CASTLE",   func = exit_to_castle },
}

local function open_cs()
    _G.charSelect.set_menu_open(true)
    close_menu()
end

local function render_options(options, screenHeight, screenWidth, optionPosY)
    local arrowUp = ""
    local arrowDown = ""
    if #options > 4 then
        if selectedOption > 4 then
            arrowUp = "^"
        end
        if selectedOption <= #options - 1 then
            arrowDown = "v"
        end
    end

    local startOptionIndex = math.max(selectedOption - 3, 1)
    local endOptionIndex = math.min(startOptionIndex + 3, #options)

    for i = startOptionIndex, endOptionIndex do
        local option = options[i]
        local optionNameLength = djui_hud_measure_text(option.name)
        local optionPosX = screenWidth * 0.5 - optionNameLength * 0.5

        djui_hud_set_color(0, 0, 0, 128)
        djui_hud_print_text(option.name, optionPosX + 1, optionPosY + 1, 1)
        djui_hud_set_color(255, 255, 255, 255)

        if i == selectedOption then
            djui_hud_set_color(0, 0, 0, 128)
            djui_hud_print_text(">", optionPosX - 15, optionPosY + 1, 1)
            djui_hud_set_color(255, 255, 255, 255)
            djui_hud_print_text(">", optionPosX - 16, optionPosY, 1)
        end

        djui_hud_print_text(option.name, optionPosX, optionPosY, 1)
        optionPosY = optionPosY + 13
    end

    local arrowUpPosY = screenHeight * 0.55 - 10
    local arrowDownPosY = screenHeight - 30
    local arrowDownPosX = screenWidth * 0.5 - djui_hud_measure_text(arrowDown) * 0.5
    local arrowUpPosX = screenWidth * 0.5 - djui_hud_measure_text(arrowUp) * 0.5

    if arrowUp ~= "" then
        djui_hud_print_text(arrowUp, arrowUpPosX, arrowUpPosY, 1)
    end
    if arrowDown ~= "" then
        djui_hud_print_text(arrowDown, arrowDownPosX, arrowDownPosY, 1)
    end
end

local function render_text(text)
    for _, data in ipairs(text) do
        djui_hud_set_font(data.font)
        djui_hud_set_color(0, 0, 0, 128)
        djui_hud_print_text(data.text, data.posX + 1, data.posY + 1, 1)
        if data.color then
            djui_hud_set_color(data.color.r, data.color.g, data.color.b, data.color.a)
        else
            djui_hud_set_color(255, 255, 255, 255)
        end
        djui_hud_print_text(data.text, data.posX, data.posY, 1)
    end
end

local function hud_render()
    if not isPaused then return end

    -- Character Select Support
    if _G.charSelectExists then
        local csOptionExists = false
        for _, option in ipairs(pauseMenuLevelOptions) do
            if option.name == "OPEN CHARACTER SELECT" then
                csOptionExists = true
                break
            end
        end
        if not csOptionExists then
            table.insert(pauseMenuLevelOptions, { name = "OPEN CHARACTER SELECT", func = open_cs })
        end

        if isPaused and _G.charSelect.is_menu_open() then
            close_menu()
        end
    end

    djui_hud_set_resolution(RESOLUTION_N64)
    djui_hud_set_font(FONT_TINY)
    local screenHeight = djui_hud_get_screen_height()
    local screenWidth = djui_hud_get_screen_width()
    local optionPosY = screenHeight * 0.55

    djui_hud_set_color(0, 0, 0, 180)
    local mscale = 0.25
    djui_hud_render_texture(TEX_MAINMENU, get_middle_x_pos(" ", 3.5) - 120, 0, mscale, mscale)
    djui_hud_set_color(255, 255, 255, 255)


    m.freeze = 1
    local course = np.currCourseNum
    local level = np.currLevelNum
    local area = np.currAreaIndex
    local act = np.currActNum
    local levelName
    if course_is_main_course(course) and course ~= COURSE_NONE then
        levelName = get_level_name(course, level, area)
    else
        levelName = "METAXY ISLES"
    end
    local ActName = get_star_name(course, act)
    local starNum = "*@" .. save_file_get_course_star_count(get_current_save_file_num() - 1, course - 1)
    local coinScore = "$@" .. save_file_get_course_coin_score(get_current_save_file_num() - 1, course - 1)
    local isStarCollected = is_star_collected(get_current_save_file_num() - 1, course, act - 1)
    local starString = isStarCollected and "" or "X"
    local redCoinText = "$@" ..
        m.area.numRedCoins - obj_count_objects_with_behavior_id(id_bhvRedCoin) .. "/" .. m.area.numRedCoins

    local textPositions = {
        { text = levelName, font = FONT_TINY, posX = screenWidth * 0.5 - djui_hud_measure_text(levelName) * 0.5, posY = optionPosY - 60 },
        -- { text = ActName,     font = FONT_TINY, posX = screenWidth * 0.5 - djui_hud_measure_text(ActName) * 0.5,   posY = optionPosY - 40 },
        --{ text = starString,  font = FONT_TINY, posX = screenWidth * 0.5 - djui_hud_measure_text(ActName) + 16,    posY = optionPosY - 40 },
        --{ text = starNum,     font = FONT_HUD,  posX = screenWidth * 0.5 + djui_hud_measure_text(ActName) - 16,    posY = optionPosY - 40 },
        --{ text = redCoinText, font = FONT_HUD,  posX = screenWidth * 0.5 + djui_hud_measure_text(ActName) - 16,    posY = optionPosY,      color = { r = 255, g = 25, b = 25, a = 255 } },
        --{ text = coinScore,   font = FONT_HUD,  posX = screenWidth * 0.5 + djui_hud_measure_text(ActName) - 16,    posY = optionPosY - 20 },
        -- { text = "PAUSE",     font = FONT_HUD,  posX = screenWidth * 0.5 - djui_hud_measure_text("PAUSE"),         posY = optionPosY - 80 },
        --{ text = romhackText, font = FONT_HUD,  posX = screenWidth * 0.5 - djui_hud_measure_text(romhackText),     posY = optionPosY - 120 },
    }

    render_text(textPositions)

    djui_hud_set_font(FONT_TINY)
    if (gLevelValues.pauseExitAnywhere or (gMarioStates[0].action & ACT_FLAG_PAUSE_EXIT) ~= 0) then
        menu_controls(pauseMenuLevelOptions)
        render_options(pauseMenuLevelOptions, screenHeight, screenWidth, optionPosY)
    end
end

local function pressed_pause()
    if get_dialog_id() >= 0 or (_G.charSelectExists and _G.charSelect.is_menu_open()) then
        return false
    end

    return gMarioStates[0].controller.buttonPressed & START_BUTTON ~= 0
end

function before_mario_update()
    local rTrigPressed = m.controller.buttonPressed & R_TRIG ~= 0

    if pressed_pause() then
        if not isPaused then
            isPaused = true
            selectedOption = 1
            m.controller.buttonPressed = 0
            play_sound(SOUND_MENU_PAUSE_HIGHPRIO, zero)
        else
            close_menu()
        end
    elseif rTrigPressed and isPaused then
        djui_open_pause_menu()
        m.controller.buttonPressed = 0
        play_sound(SOUND_MENU_EXIT_A_SIGN, zero)
    end
end

real_hook_event(HOOK_ON_HUD_RENDER, hud_render)
real_hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)
real_hook_event(HOOK_ON_WARP, close_menu)
real_hook_event(HOOK_ON_LEVEL_INIT, function()
    restartLevelArea = gNetworkPlayers[0].currAreaIndex
    close_menu()
end)
