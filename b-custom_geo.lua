-- Custom Geo ASMs and Switch Functions --

local cast_graph_node = cast_graph_node
local vtx_get_vertex = vtx_get_vertex
local gfx_parse = gfx_parse
local gfx_get_from_name = gfx_get_from_name
local vtx_get_from_name = vtx_get_from_name
local gfx_set_command = gfx_set_command

local function make_vertex(gfx, n, x, y, z, tx, ty, r, g, b, a)
    local vtx = vtx_get_vertex(gfx, n)
    if vtx then
        vtx.x = x;
        vtx.y = y;
        vtx.z = z;

        vtx.flag = 0;

        vtx.tu = tx;
        vtx.tv = ty;

        vtx.nx = r;
        vtx.ny = g;
        vtx.nz = b;
        vtx.a = a;
    end
end

local mversepipe_mat = gfx_get_from_name("mat_level_pipe_MversePipe1_layer1")
local mversepipe_mat2 = gfx_get_from_name("mat_level_pipe_MversePipe2_layer1")

function geo_update_mverse_pipe(n, m)
    local objectGraphnode = geo_get_current_object()
    local gfx = cast_graph_node(n.next)

    local ptr
    ptr = objectGraphnode._pointer

    local dlHead = gfx_get_from_name("mitm_g" .. ptr)
    local dlHead2 = gfx_get_from_name("mitm_gx" .. ptr)

    if not dlHead then
        dlHead = gfx_create("mitm_g" .. ptr, 14)
        dlHead2 = gfx_create("mitm_gx" .. ptr, 14)
        gfx_copy(dlHead, mversepipe_mat, gfx_get_length(mversepipe_mat))
        gfx_copy(dlHead2, mversepipe_mat2, gfx_get_length(mversepipe_mat2))
    end
    if objectGraphnode then
        local timer = objectGraphnode.oUnk94
        local grade = (objectGraphnode.oOpacity / 255.0)
        local r = 120 + sins(timer * 0x300 + 0x0000) * 55.0 * grade
        local g = 120 + sins(timer * 0x300 + 0x5555) * 55.0 * grade
        local b = 120 + sins(timer * 0x300 + 0xAAAA) * 55.0 * grade
        gfx_set_command(gfx_get_command(dlHead, 6), "gsDPSetEnvColor(%i, %i, %i, 255)", r, g, b)
        gfx_set_command(gfx_get_command(dlHead2, 3), "gsDPSetEnvColor(255, 255, 255, %i)", grade * 255.0 - 255.0)
    end
    gfx.displayList = dlHead
    cast_graph_node(n.next.next.next).displayList = dlHead2
end

---!TODO
function e__shotgun_effects(n, m)

end

---!TODO
function geo_update_hub_sky(n, m)

end

local rope_mat1 = gfx_get_from_name("mat_attached_rope_f3dlite_material_013")
local rope_mat2 = gfx_get_from_name("mat_revert_attached_rope_f3dlite_material_013")
function geo_generate_attached_rope(node, m)
    local vertexBuffer
    local dlHead
    local obj
    local graphNode
    local objDispY
    local s, t
    local startS, startT
    local offsetS
    local offsetT
    graphNode = node
    local ptr

    obj = geo_get_current_object()
    ptr = obj._pointer

    objDispY = GET_BPARAM34(obj.oBehParams)
    startS = 0
    startT = -32000
    offsetS = 1
    offsetT = -objDispY / 100
    s = startS - ((offsetS * 16) * 32)
    t = startT - ((offsetT * 32) * 32)
    graphNode.flags = (graphNode.flags & 0xFF) | (LAYER_ALPHA << 8);
    dlHead = gfx_get_from_name("mitm_g" .. ptr)
    vertexBuffer = vtx_get_from_name("mitm_v" .. ptr)

    if not dlHead then
        dlHead = gfx_create("mitm_g" .. ptr, 32)
    end

    if not vertexBuffer then
        vertexBuffer = vtx_create("mitm_v" .. ptr, 32)
    end

    make_vertex(vertexBuffer, 0, -20, objDispY, 0, startS, t, 0xFF, 0xE8, 0xBE, 0xFF)
    make_vertex(vertexBuffer, 1, 20, objDispY, 0, s, t, 0xFF, 0xE8, 0xBE, 0xFF)
    make_vertex(vertexBuffer, 2, 20, 0, 0, s, startT, 0xFF, 0xE8, 0xBE, 0xFF)
    make_vertex(vertexBuffer, 3, -20, 0, 0, startS, startT, 0xFF, 0xE8, 0xBE, 0xFF)

    local gfx_mat1 = gfx_get_command(dlHead, 0)
    gfx_set_command(gfx_mat1, "gsSPDisplayList(%g)", rope_mat1)
    local gfx_vtx2 = gfx_get_command(dlHead, 1)
    gfx_set_command(gfx_vtx2, "gsSPVertex(%v, 4, 0)", vertexBuffer)
    local gfx_tri3 = gfx_get_command(dlHead, 2)
    gfx_set_command(gfx_tri3, "gsSP2Triangles(0, 1, 2, 0, 0, 2, 3, 0)")
    local gfx_mat4 = gfx_get_command(dlHead, 3)
    gfx_set_command(gfx_mat4, "gsSPDisplayList(%g)", rope_mat2)

    cast_graph_node(graphNode.next).displayList = dlHead
end

local ability_mat = gfx_get_from_name("mat_ability_unlock_ability")
local ability_mat2 = gfx_get_from_name("mat_ability_sign_ability")

function geo_ability_material(n, m)
    local ptr
    local obj = geo_get_current_object()
    ptr = obj._pointer

    local dlHead = gfx_get_from_name("mitm_gAA" .. ptr)

    if not dlHead then
        dlHead = gfx_create("mitm_gAA" .. ptr, 15)
        if cast_graph_node(n).parameter == 1 then
            gfx_copy(dlHead, ability_mat2, gfx_get_length(ability_mat2))
        else
            gfx_copy(dlHead, ability_mat, gfx_get_length(ability_mat))
        end
    end

    local cmdt = gfx_get_command(dlHead, 3)
    gfx_set_command(cmdt, "gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_32b, 1, %t),",
        ability_images[obj.oBehParams2ndByte][1].texture)
    cast_graph_node(n.next).displayList = dlHead
end

function geo_ability_hand(n, mi)
    local m = geo_get_mario_state()
    local cNode = cast_graph_node(n.next)


    --[[if gPlayerSyncTable[m.playerIndex].abilityId == ABILITY_BUBBLE_HAT then
        n.flags = (n.flags & 0xFF) | (LAYER_ALPHA << 8);
    end]]

    cNode.displayList = ability_struct[gPlayerSyncTable[m.playerIndex].abilityId].hand

    if using_ability(m, ABILITY_CUTTER) then
        if m.action == ACT_MOVE_PUNCHING then
            m.actionTimer = m.actionTimer + 1
        end

        if m.actionTimer <= 3 and m.action == ACT_CUTTER_THROW_AIR or (m.actionTimer >= 3 and m.action == ACT_PUNCHING or m.actionTimer >= 3 and m.actionTimer < 6 and m.action == ACT_MOVE_PUNCHING) or m.action == ACT_CUTTER_DASH then
            cNode.displayList = cutter_hand_right_hand_open_mesh_layer_1
        end
    elseif using_ability(m, ABILITY_BUBBLE_HAT) then
        if m.action == ACT_BUBBLE_HAT_JUMP then
            cNode.displayList = bubblehat_hand_hand_mesh
        end
    end
end

function geo_ability_hat(n, m)
    local cNode = cast_graph_node(n.next)
    local mid = geo_get_mario_state()
    local abilityHat = ability_struct[gPlayerSyncTable[mid.playerIndex].abilityId].hat
    cNode.displayList = abilityHat
    if using_ability(mid, ABILITY_BUBBLE_HAT) then
        if mid.action == ACT_BUBBLE_HAT_JUMP then
            cNode.displayList = gfx_empty
        end
    end
end

function geo_override_handscale(n, mi)

end

local function delete_mod_data(obj)
    local ptr = obj._pointer

    local gfx = gfx_get_from_name("mitm_g" .. ptr)
    if gfx then gfx_delete(gfx) end

    local gfxx = gfx_get_from_name("mitm_gx" .. ptr)
    if gfxx then gfx_delete(gfxx) end

    local gfaa = gfx_get_from_name("mitm_gAA" .. ptr)
    if gfaa then gfx_delete(gfaa) end

    local vtx = vtx_get_from_name("mitm_v" .. ptr)
    if vtx then vtx_delete(vtx) end
end

hook_event(HOOK_ON_OBJECT_UNLOAD, delete_mod_data)
