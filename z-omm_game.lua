---@diagnostic disable: undefined-field, undefined-global
if _G.OmmEnabled then
    _G.OmmApi.omm_register_game("Mario in The Multiverse ", function() return true end, function()
        ---------------
        -- Game data --
        ---------------

        _G.OmmApi.omm_register_game_data(-1, 0, LEVEL_NONE, true, true, 0xFFFF00, 500)

        -----------------
        -- Level stars --
        -----------------
        
        --------------------
        -- Star behaviors --
        --------------------
        
        _G.OmmApi.omm_register_star_behavior(bhvStarPieceSwitch, "Star Piece", "STAR PIECE", function(bhvParams) return true end)
        _G.OmmApi.omm_register_star_behavior(bhvFightWavesManager, "Fighting Waves", "FIGHTING WAVES", function(bhvParams) return true end)
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
end