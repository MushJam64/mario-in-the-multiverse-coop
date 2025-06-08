---@diagnostic disable: undefined-field, undefined-global

local truth_and_real = false

local function update_omm()
    if _G.OmmEnabled and not truth_and_real then
        --djui_popup_create("s", 1)
        _G.OmmApi.omm_register_game("Mario in The Multiverse ", function() return true end, function()
            ---------------
            -- Game data --
            ---------------

            _G.OmmApi.omm_register_game_data(-1, 0, LEVEL_NONE, true, true, 0xFFFF00, 500)
            _G.OmmApi.omm_force_setting("hud", 3)

            -----------------
            -- Level stars --
            -----------------

            --------------------
            -- Star behaviors --
            --------------------

            _G.OmmApi.omm_register_star_behavior(bhvStarPieceSwitch, "Star Piece", "STAR PIECE",
                function(bhvParams) return true end)
            _G.OmmApi.omm_register_star_behavior(bhvFightWavesManager, "Fighting Waves", "FIGHTING WAVES",
                function(bhvParams) return true end)
            _G.OmmApi.omm_register_star_behavior(bhvCrane, "Crane", "CRANE", function(bhvParams) return true end)

            --------------------
            -- Camera presets --
            --------------------

            -------------------------
            -- Camera no-col boxes --
            -------------------------

            ----------------
            -- Warp pipes --
            ----------------

            -------------------
            -- Non-Stop mode --
            -------------------
        end)
        truth_and_real = true
    end
end

hook_event(HOOK_UPDATE, update_omm)
