-- Global Variables --

NULL                        = nil -- Defining NULL

-- Level Nums

LEVEL_INK_TEST              = 39
LEVEL_X                     = 40
LEVEL_G                     = 41
LEVEL_B                     = 42
LEVEL_A                     = 43
LEVEL_F                     = 44
LEVEL_E                     = 45
LEVEL_I                     = 46
LEVEL_J                     = 47
LEVEL_M                     = 48
LEVEL_O                     = 49
LEVEL_D                     = 50
LEVEL_N                     = 51
LEVEL_H                     = 52
LEVEL_C                     = 53
LEVEL_BIRTHDAY              = 54
LEVEL_L                     = 55
LEVEL_BOWSER_COURSE         = 56
LEVEL_K                     = 57
LEVEL_SB                    = 58
LEVEL_MC                    = 59
LEVEL_BB                    = 60

-- Ability Enum

ABILITY_DEFAULT             = 0
ABILITY_CUTTER              = 1
ABILITY_BUBBLE_HAT          = 2
ABILITY_SQUID               = 3
ABILITY_SHOCK_ROCKET        = 4
ABILITY_PHASEWALK           = 5
ABILITY_BIG_DADDY           = 6
ABILITY_KNIGHT              = 7
ABILITY_CHRONOS             = 8
ABILITY_E_SHOTGUN           = 9
ABILITY_GADGET_WATCH        = 10
ABILITY_HM_FLY              = 11
ABILITY_AKU                 = 12
ABILITY_ESTEEMED_MORTAL     = 13
ABILITY_MARBLE              = 14
ABILITY_DASH_BOOSTER        = 15
ABILITY_UTIL_COMPASS        = 16
ABILITY_UTIL_MILK           = 17
ABILITY_UTIL_MIRROR         = 18
ABILITY_NONE                = 19

-- Menu

LMENU_ABILITY_HUD           = 0
LMENU_HUD_ALPHA             = 20
LMENU_TITLE_CARD            = 21
LMENU_DIALOG_OPEN           = 22
LMENU_DIALOG_SCALE          = 23
LMENU_TRANSITION            = 24
LMENU_PAUSE                 = 25
LMENU_FILE_1                = 26
LMENU_FILE_2                = 27
LMENU_FILE_3                = 28
LMENU_FILE_BACKCARD         = 29
LMENU_COUNT                 = 30

-- Hud
TEXT_PIPE_NOT_ENOUGH        = ("Needed ★: ....")
TEXT_QUESTION               = ("???")
TEXT_PIPE_ENTER             = (" :Enter   :Cancel")
TEXT_PIPE_A                 = (" A")
TEXT_PIPE_B                 = ("          B")
TEXT_PIPE_Z                 = ("[Z]")

pipe_string_not_enough      = TEXT_PIPE_NOT_ENOUGH
pipe_string_enter           = TEXT_PIPE_ENTER
pipe_string_a               = TEXT_PIPE_A
pipe_string_b               = TEXT_PIPE_B
pipe_string_z               = TEXT_PIPE_Z

-- Behavior
MODEL_LEVEL_PIPE            = smlua_model_util_get_id("level_pipe_geo")
MODEL_G_BANANA_DEE          = smlua_model_util_get_id("g_banana_dee_geo")
MODEL_G_SPRING              = smlua_model_util_get_id("g_spring_geo")
MODEL_G_WADDLE_DEE          = smlua_model_util_get_id("g_waddle_dee_geo")
MODEL_ATTACHED_ROPE         = smlua_model_util_get_id("attached_rope_geo")
MODEL_HUBPLATFORM           = smlua_model_util_get_id("hub_platform_geo")
MODEL_G_BRONTO_BURT         = smlua_model_util_get_id("g_bronto_burt_geo")
MODEL_G_CANNON              = smlua_model_util_get_id("g_cannon_geo")
MODEL_G_CHECKER_BLOCK_1     = smlua_model_util_get_id("checker_block_1_geo")
MODEL_G_SIR_KIBBLE          = smlua_model_util_get_id("sir_kibble_geo")
MODEL_CUTTER_BLADE          = smlua_model_util_get_id("cutter_blade_geo")
MODEL_G_STAR_PROJECTILE     = smlua_model_util_get_id("star_projectile_geo")
MODEL_G_STAR_BLOCK          = smlua_model_util_get_id("star_block_geo")
MODEL_ABILITY               = smlua_model_util_get_id("ability_unlock_geo")
MODEL_G_CUT_ROCK = smlua_model_util_get_id("g_cut_rock_geo")
MODEL_G_CUT_ROCK2 = smlua_model_util_get_id("g_cut_rock2_geo")
MODEL_G_CUT_ROCK3 = smlua_model_util_get_id("g_cut_rock3_geo")

BP3_ATTACH_ROPE             = 0xF0

OBJ_FLAG_ATTACHABLE_BY_ROPE = (OBJ_FLAG_30 + 16)

-- Music
SEQ_CUSTOM_KIRBY_BOSS       = 0x26

local function BIT(i) return (1 << (i)) end
local function BITMASK(size) return ((BIT(size)) - 1) end

-- Number of bparams in oBehParams
NUM_BPARAMS = 4
-- Number of bits in one bparam
BPARAM_SIZE = 8
-- Number of bits in bparam bitmask
local function BPARAM_MASK_SIZE(num) return (BPARAM_SIZE * (num)) end
-- bparam bitmask ('num' 1 -> 0xFF, 'num' 2 -> 0xFFFF, etc.)
local function BPARAM_MASK(num) return BITMASK(BPARAM_MASK_SIZE(num)) end
-- Returns the amount of bits to shift a bparam value ('index' == bparam index)
local function BPARAM_NSHIFT(index, num) return (((NUM_BPARAMS - ((num) - 1)) - (index)) * BPARAM_SIZE) end
-- Returns the bparam(s) value from the index location in oBehParams
local function GET_BPARAMS(behParams, index, num) return ((behParams >> BPARAM_NSHIFT((index), (num))) & BPARAM_MASK(num)) end

-- Read 2 bparams as a single value

function GET_BPARAM34(behParams) return GET_BPARAMS((behParams), 3, 2) end

-- Dream Data

mitmdd_a                       = { ability_lock = { ABILITY_DEFAULT, ABILITY_MARBLE, ABILITY_NONE, ABILITY_NONE }, dream_star_ct = 5 } ---@type mitm_dream_data
mitmdd_b                       = { ability_lock = { ABILITY_DEFAULT, ABILITY_UTIL_MIRROR, ABILITY_BIG_DADDY, ABILITY_NONE }, dream_star_ct = 6 } ---@type mitm_dream_data
mitmdd_c                       = { ability_lock = { ABILITY_DEFAULT, ABILITY_PHASEWALK, ABILITY_NONE, ABILITY_NONE }, dream_star_ct = 5 } ---@type mitm_dream_data
mitmdd_d                       = { ability_lock = { ABILITY_DEFAULT, ABILITY_UTIL_MIRROR, ABILITY_AKU, ABILITY_NONE }, dream_star_ct = 7 } ---@type mitm_dream_data
mitmdd_e                       = { ability_lock = { ABILITY_DEFAULT, ABILITY_UTIL_MIRROR, ABILITY_E_SHOTGUN, ABILITY_NONE }, dream_star_ct = 8 } ---@type mitm_dream_data
mitmdd_f                       = { ability_lock = { ABILITY_DEFAULT, ABILITY_GADGET_WATCH, ABILITY_PHASEWALK, ABILITY_NONE }, dream_star_ct = 6 } ---@type mitm_dream_data
mitmdd_g                       = { ability_lock = { ABILITY_DEFAULT, ABILITY_UTIL_MIRROR, ABILITY_NONE, ABILITY_NONE }, dream_star_ct = 7 } ---@type mitm_dream_data
mitmdd_h                       = { ability_lock = { ABILITY_DEFAULT, ABILITY_UTIL_MIRROR, ABILITY_PHASEWALK, ABILITY_NONE }, dream_star_ct = 7 } ---@type mitm_dream_data
mitmdd_i                       = { ability_lock = { ABILITY_DEFAULT, ABILITY_CUTTER, ABILITY_NONE, ABILITY_NONE }, dream_star_ct = 7 } ---@type mitm_dream_data
mitmdd_j                       = { ability_lock = { ABILITY_DEFAULT, ABILITY_BUBBLE_HAT, ABILITY_SQUID, ABILITY_NONE }, dream_star_ct = 8 } ---@type mitm_dream_data
mitmdd_k                       = { ability_lock = { ABILITY_DEFAULT, ABILITY_UTIL_MIRROR, ABILITY_CHRONOS, ABILITY_NONE }, dream_star_ct = 7 } ---@type mitm_dream_data
mitmdd_l                       = { ability_lock = { ABILITY_DEFAULT, ABILITY_KNIGHT, ABILITY_NONE, ABILITY_NONE }, dream_star_ct = 4 } ---@type mitm_dream_data
mitmdd_m                       = { ability_lock = { ABILITY_DEFAULT, ABILITY_UTIL_MIRROR, ABILITY_PHASEWALK, ABILITY_KNIGHT }, dream_star_ct = 8 } ---@type mitm_dream_data
mitmdd_n                       = { ability_lock = { ABILITY_DEFAULT, ABILITY_E_SHOTGUN, ABILITY_BUBBLE_HAT, ABILITY_NONE }, dream_star_ct = 7 } ---@type mitm_dream_data
mitmdd_o                       = { ability_lock = { ABILITY_DEFAULT, ABILITY_UTIL_MIRROR, ABILITY_HM_FLY, ABILITY_GADGET_WATCH }, dream_star_ct = 8 } ---@type mitm_dream_data

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
mitm_levels                    = {
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

-- Ability struct
ability_struct                 = {
    --           HAND DISPLAY LIST        HAT DISPLAY LIST     MARIO MODEL ID     STRING
    --Default
    [0] = { hand = mario_right_hand_closed, hat = nil, model_id = nil, string = abstr_def },
    --G
    { hand = mario_right_hand_closed,                hat = cutter_hat_Circle_mesh_layer_1, model_id = nil,                string = abstr_g },
    --A
    { hand = net_hand_2_hand_mesh,                   hat = bubble_hat_bhat_mesh,           model_id = nil,                string = abstr_a },
    --C
    { hand = mario_right_hand_closed,                hat = squid_hat_lunette_mesh,         model_id = nil,                string = abstr_c },
    --I
    { hand = rocket_hand_RaymanMissile_mesh_layer_1, hat = nil,                            model_id = nil,                string = abstr_i },
    --H
    { hand = phasewalk_hand_hand_mesh,               hat = nil,                            model_id = nil,                string = abstr_h },
    --B
    { hand = bigdaddyhand_Plane_mesh,                hat = bigdaddyhat_bigdaddy_mesh,      model_id = nil,                string = abstr_b },
    --L
    { hand = mario_right_hand_closed,                hat = nil,                            model_id = MODEL_KNIGHT_MARIO, string = abstr_l },
    --K
    { hand = mario_right_hand_closed,                hat = nil,                            model_id = nil_K,              string = abstr_k },
    --E
    { hand = mario_right_hand_closed,                hat = nil,                            model_id = MODEL_E__MARIO,     string = abstr_e },
    --F
    { hand = hand_f_hand_mesh,                       hat = hat_f_hat_mesh,                 model_id = nil,                string = abstr_f },
    --J
    { hand = pokeball_hand_hand_mesh,                hat = nil,                            model_id = nil,                string = abstr_j },
    --D
    { hand = mario_right_hand_closed,                hat = ability_d_mask_hat_mesh,        model_id = nil,                string = abstr_d },
    --O
    { hand = mario_right_hand_closed,                hat = nil,                            model_id = MODEL_SAWAXE_MARIO, string = abstr_o },
    --N
    { hand = mario_right_hand_closed,                hat = nil,                            model_id = nil,                string = abstr_n },
    --M
    { hand = hand_m_hand_mesh,                       hat = nil,                            model_id = nil,                string = abstr_m },

    --Util1
    { hand = compass_hand_hand_mesh,                 hat = nil,                            model_id = nil,                string = abstr_util_1 },
    --Util2
    { hand = milk_hand_hand_mesh,                    hat = nil,                            model_id = nil,                string = abstr_util_2 },
    --Util3
    { hand = mirror_hand_hand_mesh,                  hat = nil,                            model_id = nil,                string = abstr_util_3 },
}

title_card_data                = {
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

ability_images                 = {
    [0] = { --[[Default]]
        get_texture_info("custom_ability_default.rgba16")
    },
    { --[[Ability G]]
        get_texture_info("custom_ability_g.rgba16")
    },
    { --[[Ability A]]
        get_texture_info("custom_ability_a.rgba16")
    },
    { --[[Ability C]]
        get_texture_info("custom_ability_c.rgba16")
    },
    { --[[Ability I]]
        get_texture_info("custom_ability_i.rgba16")
    },
    { --[[Ability H]]
        get_texture_info("custom_ability_h.rgba16")
    },
    { --[[Ability B]]
        get_texture_info("custom_ability_b.rgba16")
    },
    { --[[Ability L]]
        get_texture_info("custom_ability_l.rgba16")
    },
    { --[[Ability K]]
        get_texture_info("custom_ability_k.rgba16")
    },
    { --[[Ability E]]
        get_texture_info("custom_ability_e.rgba16")
    },
    { --[[Ability F]]
        get_texture_info("custom_ability_f.rgba16")
    },
    { --[[Ability J]]
        get_texture_info("custom_ability_j.rgba16")
    },
    { --[[Ability D]]
        get_texture_info("custom_ability_d.rgba16")
    },
    { --[[Ability O]]
        get_texture_info("custom_ability_o.rgba16")
    },
    { --[[Ability N]]
        get_texture_info("custom_ability_n.rgba16")
    },
    { --[[Ability M]]
        get_texture_info("custom_ability_m.rgba16")
    },
    { --[[Utility 1]]
        get_texture_info("custom_ability_u1.rgba16")
    },
    { --[[Utility 2]]
        get_texture_info("custom_ability_u2.rgba16")
    },
    { --[[Utility 3]]
        get_texture_info("custom_ability_u3.rgba16")
    },
    { --[[None]]
        get_texture_info("custom_ability_default.rgba16")
    },
    { --[[Locked]]
        get_texture_info("custom_ability_locked.rgba16")
    },
    { --[[Utility 2 Used]]
        get_texture_info("custom_ability_u2_used.rgba16")
    }
};

-- Variables

queued_pipe_cutscene           = false
dream_comet_enabled            = false

hub_level_current_index        = 0
hub_level_index                = -1
hub_titlecard_alpha            = 0
hub_returnback_box_alpha       = 0
hub_dma_index                  = -1
hub_star_string                = {}

sCutsceneSplineSegment         = 0
sCutsceneSplineSegmentProgress = 0

for i = 0, (MAX_PLAYERS - 1) do
    gPlayerSyncTable[i].abilityId = 0
end

local courseToLevel = {
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

---@return boolean
function dream_comet_unlocked()
    return false
end

function change_ability(picked_ability)
    if (picked_ability == ABILITY_NONE) then return end;

    -- Set Mario's Ability Variable
    gPlayerSyncTable[0].abilityId = picked_ability;
    local gMarioState = gMarioStates[0]

    -- Hand Display List
    --gSPDisplayList(&gfx_ability_hand[0], ability_struct[gPlayerSyncTable[0].abilityId].hand);
    --gSPEndDisplayList(&gfx_ability_hand[1]);

    --Hat Display List
    local hat_dl_head = 0;
    if (ability_struct[gPlayerSyncTable[0].abilityId].hat ~= NULL) then
        --gSPDisplayList(&gfx_ability_hat[hat_dl_head++], ability_struct[gPlayerSyncTable[0].abilityId].hat);
    end
    if ((gNetworkPlayers[0].currLevelNum == LEVEL_F) and (gPlayerSyncTable[0].abilityId ~= ABILITY_GADGET_WATCH)) then
        --  gSPDisplayList(&gfx_ability_hat[hat_dl_head++], &hat_f_hat_mesh);
    end
    --gSPEndDisplayList(&gfx_ability_hat[hat_dl_head++]);

    --Mario Model
    gPlayerSyncTable[0].modelId = ability_struct[gPlayerSyncTable[0].abilityId].model_id
end

-- Saving

--levels_unlocked = 1 means first course is open

gGlobalSyncTable.levels_unlocked = 1 ---default

ability_slot                     = { [0] = ABILITY_NONE, ABILITY_NONE, ABILITY_NONE, ABILITY_NONE };
gGlobalSyncTable.ability_slot0   = ABILITY_NONE
gGlobalSyncTable.ability_slot1   = ABILITY_NONE
gGlobalSyncTable.ability_slot2   = ABILITY_NONE
gGlobalSyncTable.ability_slot3   = ABILITY_NONE

function save_unlocked_levels()
    mod_storage_save_number("levels_unlocked_" .. (get_current_save_file_num() - 1), gGlobalSyncTable.levels_unlocked)
end

function load_unlocked_levels()
    gGlobalSyncTable.levels_unlocked = mod_storage_load_number("levels_unlocked_" .. (get_current_save_file_num() - 1)) or
    1
    return gGlobalSyncTable.levels_unlocked
end

function save_ability_slots()
    local currSave = get_current_save_file_num() - 1
    mod_storage_save_number("ability_slot0" .. (currSave), gGlobalSyncTable.ability_slot0)
    mod_storage_save_number("ability_slot1" .. (currSave), gGlobalSyncTable.ability_slot1)
    mod_storage_save_number("ability_slot2" .. (currSave), gGlobalSyncTable.ability_slot2)
    mod_storage_save_number("ability_slot3" .. (currSave), gGlobalSyncTable.ability_slot3)
end

function load_ability_slots()
    local currSave = get_current_save_file_num() - 1
    gGlobalSyncTable.ability_slot0 = mod_storage_load_number("ability_slot0" .. (currSave)) or ABILITY_NONE
    gGlobalSyncTable.ability_slot1 = mod_storage_load_number("ability_slot1" .. (currSave)) or ABILITY_NONE
    gGlobalSyncTable.ability_slot2 = mod_storage_load_number("ability_slot2" .. (currSave)) or ABILITY_NONE
    gGlobalSyncTable.ability_slot3 = mod_storage_load_number("ability_slot3" .. (currSave)) or ABILITY_NONE
    ability_slot[0] = gGlobalSyncTable.ability_slot0
    ability_slot[1] = gGlobalSyncTable.ability_slot1
    ability_slot[2] = gGlobalSyncTable.ability_slot2
    ability_slot[3] = gGlobalSyncTable.ability_slot3
end

if network_is_server() then
    load_unlocked_levels()
    load_ability_slots()
    if save_file_get_flags() == 0 or gGlobalSyncTable.levels_unlocked == 0 then -- has nothing
        gGlobalSyncTable.levels_unlocked = 1
        save_unlocked_levels()
    end
end
