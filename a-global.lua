-- Global Constants --

NULL                     = nil -- Defining NULL

-- Level Nums

LEVEL_INK_TEST           = 39
LEVEL_X                  = 40
LEVEL_G                  = 41
LEVEL_B                  = 42
LEVEL_A                  = 43
LEVEL_F                  = 44
LEVEL_E                  = 45
LEVEL_I                  = 46
LEVEL_J                  = 47
LEVEL_M                  = 48
LEVEL_O                  = 49
LEVEL_D                  = 50
LEVEL_N                  = 51
LEVEL_H                  = 52
LEVEL_C                  = 53
LEVEL_BIRTHDAY           = 54
LEVEL_L                  = 55
LEVEL_BOWSER_COURSE      = 56
LEVEL_K                  = 57
LEVEL_SB                 = 58
LEVEL_MC                 = 59
LEVEL_BB                 = 60

-- Ability Enum

ABILITY_DEFAULT          = 0
ABILITY_CUTTER           = 1
ABILITY_BUBBLE_HAT       = 2
ABILITY_SQUID            = 3
ABILITY_SHOCK_ROCKET     = 4
ABILITY_PHASEWALK        = 5
ABILITY_BIG_DADDY        = 6
ABILITY_KNIGHT           = 7
ABILITY_CHRONOS          = 8
ABILITY_E_SHOTGUN        = 9
ABILITY_GADGET_WATCH     = 10
ABILITY_HM_FLY           = 11
ABILITY_AKU              = 12
ABILITY_ESTEEMED_MORTAL  = 13
ABILITY_MARBLE           = 14
ABILITY_DASH_BOOSTER     = 15
ABILITY_UTIL_COMPASS     = 16
ABILITY_UTIL_MILK        = 17
ABILITY_UTIL_MIRROR      = 18
ABILITY_NONE             = 19

-- Menu

LMENU_ABILITY_HUD        = 0
LMENU_HUD_ALPHA          = 20
LMENU_TITLE_CARD         = 21
LMENU_DIALOG_OPEN        = 22
LMENU_DIALOG_SCALE       = 23
LMENU_TRANSITION         = 24
LMENU_PAUSE              = 25
LMENU_FILE_1             = 26
LMENU_FILE_2             = 27
LMENU_FILE_3             = 28
LMENU_FILE_BACKCARD      = 29
LMENU_COUNT              = 30

-- Hud
TEXT_PIPE_NOT_ENOUGH     = ("Needed ★: ....")
TEXT_QUESTION            = ("???")
TEXT_PIPE_ENTER          = (" :Enter   :Cancel")
TEXT_PIPE_A              = (" A")
TEXT_PIPE_B              = ("          B")
TEXT_PIPE_Z              = ("[Z]")

pipe_string_not_enough   = TEXT_PIPE_NOT_ENOUGH
pipe_string_enter        = TEXT_PIPE_ENTER
pipe_string_a            = TEXT_PIPE_A
pipe_string_b            = TEXT_PIPE_B
pipe_string_z            = TEXT_PIPE_Z

-- Dream Data

mitmdd_a                 = { ability_lock = { ABILITY_DEFAULT, ABILITY_MARBLE, ABILITY_NONE, ABILITY_NONE }, dream_star_ct = 5 } ---@type mitm_dream_data
mitmdd_b                 = { ability_lock = { ABILITY_DEFAULT, ABILITY_UTIL_MIRROR, ABILITY_BIG_DADDY, ABILITY_NONE }, dream_star_ct = 6 } ---@type mitm_dream_data
mitmdd_c                 = { ability_lock = { ABILITY_DEFAULT, ABILITY_PHASEWALK, ABILITY_NONE, ABILITY_NONE }, dream_star_ct = 5 } ---@type mitm_dream_data
mitmdd_d                 = { ability_lock = { ABILITY_DEFAULT, ABILITY_UTIL_MIRROR, ABILITY_AKU, ABILITY_NONE }, dream_star_ct = 7 } ---@type mitm_dream_data
mitmdd_e                 = { ability_lock = { ABILITY_DEFAULT, ABILITY_UTIL_MIRROR, ABILITY_E_SHOTGUN, ABILITY_NONE }, dream_star_ct = 8 } ---@type mitm_dream_data
mitmdd_f                 = { ability_lock = { ABILITY_DEFAULT, ABILITY_GADGET_WATCH, ABILITY_PHASEWALK, ABILITY_NONE }, dream_star_ct = 6 } ---@type mitm_dream_data
mitmdd_g                 = { ability_lock = { ABILITY_DEFAULT, ABILITY_UTIL_MIRROR, ABILITY_NONE, ABILITY_NONE }, dream_star_ct = 7 } ---@type mitm_dream_data
mitmdd_h                 = { ability_lock = { ABILITY_DEFAULT, ABILITY_UTIL_MIRROR, ABILITY_PHASEWALK, ABILITY_NONE }, dream_star_ct = 7 } ---@type mitm_dream_data
mitmdd_i                 = { ability_lock = { ABILITY_DEFAULT, ABILITY_CUTTER, ABILITY_NONE, ABILITY_NONE }, dream_star_ct = 7 } ---@type mitm_dream_data
mitmdd_j                 = { ability_lock = { ABILITY_DEFAULT, ABILITY_BUBBLE_HAT, ABILITY_SQUID, ABILITY_NONE }, dream_star_ct = 8 } ---@type mitm_dream_data
mitmdd_k                 = { ability_lock = { ABILITY_DEFAULT, ABILITY_UTIL_MIRROR, ABILITY_CHRONOS, ABILITY_NONE }, dream_star_ct = 7 } ---@type mitm_dream_data
mitmdd_l                 = { ability_lock = { ABILITY_DEFAULT, ABILITY_KNIGHT, ABILITY_NONE, ABILITY_NONE }, dream_star_ct = 4 } ---@type mitm_dream_data
mitmdd_m                 = { ability_lock = { ABILITY_DEFAULT, ABILITY_UTIL_MIRROR, ABILITY_PHASEWALK, ABILITY_KNIGHT }, dream_star_ct = 8 } ---@type mitm_dream_data
mitmdd_n                 = { ability_lock = { ABILITY_DEFAULT, ABILITY_E_SHOTGUN, ABILITY_BUBBLE_HAT, ABILITY_NONE }, dream_star_ct = 7 } ---@type mitm_dream_data
mitmdd_o                 = { ability_lock = { ABILITY_DEFAULT, ABILITY_UTIL_MIRROR, ABILITY_HM_FLY, ABILITY_GADGET_WATCH }, dream_star_ct = 8 } ---@type mitm_dream_data

---@class mitm_dream_data
---@field public ability_lock integer[]
---@field public dream_star_ct integer

---@class mitm_level_data
---@field public name string
---@field public author string|nil
---@field public author_abridged string|nil
---@field public level integer|nil
---@field public course integer
---@field public star_requirement integer
---@field public start_area integer
---@field public return_id integer
---@field public star_count integer
---@field public dream_data mitm_dream_data|nil

--In course order, not alphabetical!
--Only mess with --[[ Level ]] entry, everything else is pre-configured
---@type mitm_level_data[]
mitm_levels              = {
    --[[ Name, Author(s)]]
    --[[Level     StarFlags     StarReq  StartArea  ReturnWarp  StarCt DreamData]]
    [0] = { name = "MARIO SUPER STAR ULTRA", author = "CowQuack", author_abridged = "CowQuack", level = LEVEL_G, course = COURSE_BOB, star_requirement = 0, start_area = 3, return_id = 20, star_count = 8, dream_data = mitmdd_g },
    --[[A]] { name = "MARIO IN BIKINI BOTTOM", author = "JoshTheBosh",           author_abridged = "JoshTheBosh",     level = LEVEL_A,             course = COURSE_WF,    star_requirement = 2,  start_area = 1,        return_id = 21, star_count = 8, dream_data = mitmdd_a },
    --[[C]] { name = "PIRANHA PIT",  author = "Drahnokks, Idea by: Woissil",     author_abridged = "Drahnokks & Co.", level = LEVEL_C,             course = COURSE_JRB,   star_requirement = 2,  start_area = 1,        return_id = 22, star_count = 8, dream_data = mitmdd_c },
    --[[I]] { name = "MUSHROOM HAVOC", author = "Drahnokks",                     author_abridged = "Drahnokks",       level = LEVEL_I,             course = COURSE_CCM,   star_requirement = 5,  start_area = 1,        return_id = 23, star_count = 8, dream_data = mitmdd_i },
    --[[H]] { name = "OPPORTUNITY",  author = "joopii",                          author_abridged = "joopii",          level = LEVEL_H,             course = COURSE_BBH,   star_requirement = 10, start_area = 1,        return_id = 24, star_count = 8, dream_data = mitmdd_h },
    --[[B]] { name = "BIOSHOCK RAPTURE", author = "furyiousfight",               author_abridged = "furyiousfight",   level = LEVEL_B,             course = COURSE_HMC,   star_requirement = 15, start_area = 1,        return_id = 25, star_count = 8, dream_data = mitmdd_b },
    --[[L]] { name = "BEYOND THE CURSED PIZZA", author = "luigiman0640",         author_abridged = "luigiman0640",    level = LEVEL_L,             course = COURSE_LLL,   star_requirement = 20, start_area = 6,        return_id = 26, star_count = 8, dream_data = mitmdd_l },
    --[[K]] { name = "KATANA MARIO NEW MECCA", author = "KeyBlader, Ability by: axollyon", author_abridged = "KeyBlader & Co.", level = LEVEL_K,   course = COURSE_SSL,   star_requirement = 20, start_area = 2,        return_id = 27, star_count = 8, dream_data = mitmdd_k },
    --[[E]] { name = "DOOM",         author = "Dorrieal",                        author_abridged = "Dorrieal",        level = LEVEL_E,             course = COURSE_DDD,   star_requirement = 30, start_area = 1,        return_id = 28, star_count = 8, dream_data = mitmdd_e },
    --[[F]] { name = "FROM RUSSIA WITH LOVE", author = "Aeza",                   author_abridged = "Aeza",            level = LEVEL_F,             course = COURSE_SL,    star_requirement = 30, start_area = 1,        return_id = 29, star_count = 8, dream_data = mitmdd_f },
    --[[J]] { name = "ECRUTEAK CITY", "SpK",                                     author = "SpK",                      author_abridged = NULL,      level = LEVEL_J,       course = COURSE_WDW,   star_requirement = 40, start_area = 1, return_id = 30, star_count = 8,       dream_data = mitmdd_j },
    --[[D]] { name = "NEW N-SANITY ISLAND", author = "JakeDower",                author_abridged = "JakeDower",       level = LEVEL_D,             course = COURSE_TTM,   star_requirement = 50, start_area = 1,        return_id = 31, star_count = 8, dream_data = mitmdd_d },
    --[[O]] { name = "SAINTS, SINNERS, & MARIO", author = "Rovertronic",         author_abridged = "Rovertronic",     level = LEVEL_O,             course = COURSE_THI,   star_requirement = 50, start_area = 1,        return_id = 32, star_count = 8, dream_data = mitmdd_o },
    --[[N]] { name = "MARIO IN HAMSTERBALL", author = "LinCrash",                author_abridged = "LinCrash",        level = LEVEL_N,             course = COURSE_TTC,   star_requirement = 60, start_area = 1,        return_id = 33, star_count = 8, dream_data = mitmdd_n },
    --[[M]] { name = "ENVIRONMENTAL STATION M", author = "Mel",                  author_abridged = "Mel",             level = LEVEL_M,             course = COURSE_RR,    star_requirement = 60, start_area = 1,        return_id = 34, star_count = 8, dream_data = mitmdd_m },
    --[[BC]] { name = "CENTRUM OMNIUM", author = NULL,                           author_abridged = NULL,              level = LEVEL_BOWSER_COURSE, course = COURSE_BITDW, star_requirement = 80, start_area = 0,        return_id = 37, star_count = 1, dream_data = NULL },
    --[[HUB]] { name = "METAXY ISLES", author = NULL,                            author_abridged = NULL,              level = NULL,                course = COURSE_BITFS, star_requirement = 0,  start_area = 0,        return_id = 34, star_count = 2, dream_data = NULL },
    --[[PW]] { name = "PAINTING WORLD", author = NULL,                           author_abridged = NULL,              level = NULL,                course = COURSE_NONE,  star_requirement = 0,  start_area = 0,        return_id = 36, star_count = 0, dream_data = NULL },
    --[[SB]] { name = "GAPS AND HANDS", author = NULL,                           author_abridged = NULL,              level = NULL,                course = COURSE_NONE,  star_requirement = 0,  start_area = 0,        return_id = 36, star_count = 0, dream_data = NULL },
    --[[MC]] { name = "Mute City",   author = "BroDute",                         author_abridged = "BroDute",         level = NULL,                course = COURSE_PSS,   star_requirement = 0,  start_area = 0,        return_id = 36, star_count = 1, dream_data = NULL },
    --[[BB]] { name = "Big Blue",    author = "BroDute",                         author_abridged = "BroDute",         level = NULL,                course = COURSE_WMOTR, star_requirement = 0,  start_area = 0,        return_id = 36, star_count = 1, dream_data = NULL },
};

title_card_data          = {
    [0] = get_texture_info("custom_titlecard_G.rgba16")
    ,
    get_texture_info("custom_titlecard_A.rgba16")
    ,
    get_texture_info("custom_titlecard_C.rgba16")
    ,
    get_texture_info("custom_titlecard_I.rgba16")
    ,
    get_texture_info("custom_titlecard_H.rgba16")
    ,
    get_texture_info("custom_titlecard_B.rgba16")
    ,
    get_texture_info("custom_titlecard_L.rgba16")
    ,
    get_texture_info("custom_titlecard_K.rgba16")
    ,
    get_texture_info("custom_titlecard_E.rgba16")
    ,
    get_texture_info("custom_titlecard_F.rgba16")
    ,
    get_texture_info("custom_titlecard_J.rgba16")
    ,
    get_texture_info("custom_titlecard_D.rgba16")
    ,
    get_texture_info("custom_titlecard_O.rgba16")
    ,
    get_texture_info("custom_titlecard_N.rgba16")
    ,
    get_texture_info("custom_titlecard_M.rgba16")
};

-- Variables

queued_pipe_cutscene     = false
dream_comet_enabled      = false

hub_level_current_index  = 0
hub_level_index          = -1
hub_titlecard_alpha      = 0
hub_returnback_box_alpha = 0
hub_dma_index            = -1
hub_star_string          = {}

local courseToLevel      = {
    [COURSE_NONE] = LEVEL_NONE,
    [COURSE_BOB] = LEVEL_BOB,
    [COURSE_WF] = LEVEL_WF,
    [COURSE_JRB] = LEVEL_JRB,
    [COURSE_CCM] = LEVEL_CCM,
    [COURSE_BBH] = LEVEL_BBH,
    [COURSE_HMC] = LEVEL_HMC,
    [COURSE_LLL] = LEVEL_LLL,
    [COURSE_SSL] = LEVEL_SSL,
    [COURSE_DDD] = LEVEL_DDD,
    [COURSE_SL] = LEVEL_SL,
    [COURSE_WDW] = LEVEL_WDW,
    [COURSE_TTM] = LEVEL_TTM,
    [COURSE_THI] = LEVEL_THI,
    [COURSE_TTC] = LEVEL_TTC,
    [COURSE_RR] = LEVEL_RR,
    [COURSE_BITDW] = LEVEL_BITDW,
    [COURSE_BITFS] = LEVEL_BITFS,
    [COURSE_BITS] = LEVEL_BITS,
    [COURSE_PSS] = LEVEL_PSS,
    [COURSE_COTMC] = LEVEL_COTMC,
    [COURSE_TOTWC] = LEVEL_TOTWC,
    [COURSE_VCUTM] = LEVEL_VCUTM,
    [COURSE_WMOTR] = LEVEL_WMOTR,
    [COURSE_SA] = LEVEL_SA,
    [COURSE_CAKE_END] = LEVEL_ENDING,
}

---@param id integer
---@return integer|nil
function get_hub_level(id)
    return courseToLevel[mitm_levels[id].course]
end

---@param id integer
---@return integer
function get_hub_area(id)
    return mitm_levels[id].start_area
end

---@param id integer
---@return integer
function get_hub_return_id(id)
    return mitm_levels[id].return_id
end

function dream_comet_unlocked()
    return false
end

--levels_unlocked = 1 means first course is open
levels_unlocked = mod_storage_load_number("levels_unlocked_" .. (get_current_save_file_num() - 1)) or 1
if save_file_get_flags() == 0 or levels_unlocked == 0 then -- has nothing
    levels_unlocked = 1
    mod_storage_save_number("levels_unlocked_" .. (get_current_save_file_num() - 1), levels_unlocked)
end
