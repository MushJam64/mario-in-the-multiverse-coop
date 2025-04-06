-- Custom Geo ASMs and Switch Functions --

function geo_update_mverse_pipe(n, _) -- replace any unused params with `_`
    local objectGraphnode = geo_get_current_object()
    local gfx = cast_graph_node(n.next).displayList
    if objectGraphnode then
        local timer = objectGraphnode.oUnk94
        local grade = (objectGraphnode.oOpacity / 255.0);
        local r = 120 + sins(timer * 0x300 + 0x0000) * 55.0 * grade;
        local g = 120 + sins(timer * 0x300 + 0x5555) * 55.0 * grade;
        local b = 120 + sins(timer * 0x300 + 0xAAAA) * 55.0 * grade;
        gfx_parse(gfx, function(dl, cmd)
            if cmd == G_SETENVCOLOR then
                gfx_set_command(dl, "gsDPSetEnvColor", r, g, b, 255);
            end
        end)
    end
end
