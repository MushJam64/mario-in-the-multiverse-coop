-- Custom Geo ASMs and Switch Functions --

local function make_vertex(gfx, n, x, y, z, tx, ty, r, g, b, a)
    local vtx = gfx_get_vtx(gfx, n)
    if vtx then
        vtx.ob[1] = x;
        vtx.ob[2] = y;
        vtx.ob[3] = z;

        vtx.flag = 0;

        vtx.tc[1] = tx;
        vtx.tc[2] = ty;

        vtx.cn[1] = r;
        vtx.cn[2] = g;
        vtx.cn[3] = b;
        vtx.cn[4] = a;
    end
end

-- scroll ported from ex alo
local SCROLL_X = 0
local SCROLL_Y = 1
local SCROLL_Z = 2
local SCROLL_UV_X = 4
local SCROLL_UV_Y = 5
local MODE_SCROLL_UV = 0
local MODE_SCROLL_SINE = 1
local MODE_SCROLL_JUMP = 2

local function shift_UV_NORMAL(gfx, vertcount, speed, bhv, cycle)
    local overflownum = 0x1000;
    --Vtx* *verts = get_scroll_targets(vtxIndex);
    local correction = 0;
    local vtx0 = gfx_get_vtx(gfx, 0)

    if (bhv < SCROLL_UV_X) then
        if (vtx0.flag >= cycle) then
            correction = vtx0.flag * speed;
            vtx0.flag = 0;
        end

        for i = 0, vertcount do
            local vtxi = gfx_get_vtx(gfx, i)
            if (correction == 0) then
                vtxi.ob[math.min(bhv, 2)] = vtxi.ob[math.min(bhv, 2)] + speed;
            else
                vtxi.ob[math.min(bhv, 2)] = vtxi.ob[math.min(bhv, 2)] - correction;
            end
        end
    else
        if (vtx0.flag * math.abs(speed) > overflownum) then
            correction = overflownum * signum_positive(speed);
            vtx0.flag = 0;
        end
        local infix = 1
        for i = 0, vertcount do
            local vtxi = gfx_get_vtx(gfx, i)
            if (correction == 0) then
                vtxi.tc[math.min(bhv - SCROLL_UV_X, 1) + (infix)] = vtxi.tc
                    [math.min(bhv - SCROLL_UV_X, 1) + (infix)] + speed;
            else
                vtxi.tc[math.min(bhv - SCROLL_UV_X, 1) + (infix)] = vtxi.tc
                    [math.min(bhv - SCROLL_UV_X, 1) + (infix)] - correction;
            end
        end
    end

    if (correction == 0) then
        vtx0.flag = vtx0.flag + 1;
    end
end

function geo_update_mverse_pipe(n, m)
    local objectGraphnode = geo_get_current_object()
    local gfx = cast_graph_node(n.next).displayList
    if objectGraphnode then
        local timer = objectGraphnode.oUnk94
        local grade = (objectGraphnode.oOpacity / 255.0)
        local r = 120 + sins(timer * 0x300 + 0x0000) * 55.0 * grade
        local g = 120 + sins(timer * 0x300 + 0x5555) * 55.0 * grade
        local b = 120 + sins(timer * 0x300 + 0xAAAA) * 55.0 * grade
        gfx_parse(gfx, function(dl, cmd)
            if cmd == G_SETENVCOLOR then
                gfx_set_command(dl, "gsDPSetEnvColor", r, g, b, 255)
            end
        end)
    end

    -- custom for coop stuff
    local starsdl = cast_graph_node(n.next.next).displayList
    -- for some reason, coop makes this run more than once if theres more than 1 pipe,
    -- the more pipes you look at, the more faster it scrolls
    gfx_parse(starsdl, function(dl, cmd)
        if cmd == G_VTX then
            shift_UV_NORMAL(dl,
                31,     --VERTCOUNT - 1
                6,
                SCROLL_UV_X,
                1)
        end
    end)
end

---!TODO
function e__shotgun_effects(n, m)

end

---!TODO
function geo_update_hub_sky(n, m)

end

function geo_generate_attached_rope(n, m)
    local vertexBuffer
    local dlStart, dlHead
    local obj
    local objDispX
    local objDispY
    local s, t
    local startS, startT
    local offsetS
    local offsetT

    local dl = cast_graph_node(n.next).displayList

    obj = geo_get_current_object()

    objDispY = GET_BPARAM34(obj.oBehParams)
    startS = 0
    startT = -32000
    offsetS = 1
    offsetT = -objDispY / 100
    s = startS - ((offsetS * 16) * 32)
    t = startT - ((offsetT * 32) * 32)
    --graphNode.flags = (graphNode.flags & 0xFF) | (LAYER_ALPHA << 8)

    gfx_parse(dl, function(dls, op)
        if op == G_VTX then
            make_vertex(dls, 0, -20, objDispY, 0, startS, t, 0xFF, 0xE8, 0xBE, 0xFF)
            make_vertex(dls, 1, 20, objDispY, 0, s, t, 0xFF, 0xE8, 0xBE, 0xFF)
            make_vertex(dls, 2, 20, 0, 0, s, startT, 0xFF, 0xE8, 0xBE, 0xFF)
            make_vertex(dls, 3, -20, 0, 0, startS, startT, 0xFF, 0xE8, 0xBE, 0xFF)
        end
    end)

    --dlHead = alloc_display_list(sizeof(Gfx) * (32 + 4))
    --dlStart = dlHead

    --gSPDisplayList(dlHead++, mat_attached_rope_f3dlite_material_013)
    --gSPVertex(dlHead++, VIRTUAL_TO_PHYSICAL(vertexBuffer), 4, 0)

    --gSP2Triangles(dlHead++, 0, 1, 2, 0, 0, 2, 3, 0)
    --gSPDisplayList(dlHead++, mat_revert_attached_rope_f3dlite_material_013)
    --gSPEndDisplayList(dlHead++)
end

function geo_ability_material(n, m)
end